/* Gambit service worker.
 *
 * Bump CACHE when you ship a change — the name is the cache-busting key.
 * Strategy is deliberately split:
 *   - navigations  -> network-first, so a new version is picked up as soon as
 *                     the device is online; falls back to cache when offline.
 *   - other assets -> cache-first, since icons and the manifest rarely change
 *                     and this keeps launches instant.
 */
const CACHE = "gambit-v24";

const ASSETS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/icon-maskable-512.png",
  "./icons/apple-touch-icon.png",
  "./icons/favicon-32.png"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE)
      // addAll fails atomically if any single request fails, which would leave
      // the SW uninstalled; tolerate individual misses instead.
      .then((cache) => Promise.allSettled(ASSETS.map((u) => cache.add(u))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET") return;

  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;   // let Google Fonts etc. go to the network

  /* Archived snapshots under /archive/ are frozen builds kept for comparison.
     The worker's scope covers them, and its navigation fallback would happily
     hand back the CURRENT index.html for an archive URL when offline — which
     would silently show the wrong game. Never touch them. */
  if (url.pathname.includes("/archive/")) return;

  if (req.mode === "navigate") {
    event.respondWith(
      fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put("./index.html", copy));
          return res;
        })
        .catch(() => caches.match("./index.html").then((r) => r || caches.match("./")))
    );
    return;
  }

  event.respondWith(
    caches.match(req).then((hit) => hit || fetch(req).then((res) => {
      if (res && res.ok && res.type === "basic") {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(req, copy));
      }
      return res;
    }))
  );
});
