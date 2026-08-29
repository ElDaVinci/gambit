#!/usr/bin/env bash
# Builds gambit.artifact.html from index.html.
#
# The Artifact host wraps the file in its own <!doctype>/<html>/<head>/<body>,
# so the wrapper tags are stripped. The PWA tags are stripped too: there is no
# manifest or icon directory alongside a published artifact, so leaving them in
# would only produce 404s.
set -euo pipefail
cd "$(dirname "$0")/.."

grep -vE \
  -e '^<!doctype html>$' \
  -e '^<html lang="en">$' \
  -e '^<head>$' \
  -e '^</head>$' \
  -e '^<body>$' \
  -e '^</body>$' \
  -e '^</html>$' \
  -e '^<meta charset' \
  -e '^<meta name="viewport"' \
  -e '^<meta name="color-scheme"' \
  -e '^<!-- installable web app -->$' \
  -e '^<link rel="manifest"' \
  -e '^<link rel="icon"' \
  -e '^<link rel="apple-touch-icon"' \
  -e '^<meta name="theme-color"' \
  -e '^<meta name="apple-mobile-web-app' \
  -e '^<meta name="mobile-web-app-capable"' \
  index.html > gambit.artifact.html

echo "built gambit.artifact.html ($(wc -l < gambit.artifact.html) lines)"

# The service-worker registration is harmless in an artifact (it is guarded and
# simply finds no sw.js), but warn if anything else PWA-ish slipped through.
if grep -qE 'manifest\.webmanifest|apple-touch-icon' gambit.artifact.html; then
  echo "WARNING: PWA references still present in the artifact build" >&2
  exit 1
fi
