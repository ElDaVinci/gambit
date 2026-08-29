# Generates Gambit's app icons as real PNGs via System.Drawing.
# Run once; the PNGs are committed, so this script is only needed if the mark changes.
Add-Type -AssemblyName System.Drawing

$OutDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'icons'
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# palette (matches the app's dark theme)
$cBg     = [System.Drawing.ColorTranslator]::FromHtml('#2B3830')
$cPawn   = [System.Drawing.ColorTranslator]::FromHtml('#F7F3E6')
$cBrass  = [System.Drawing.ColorTranslator]::FromHtml('#C8A24A')
$cChecker= [System.Drawing.Color]::FromArgb(14, 240, 236, 220)
$cShadow = [System.Drawing.Color]::FromArgb(70, 0, 0, 0)

# The pawn lives in a 45-unit box; its real bounding box is x 8.5..36.5, y 5..35.2
$CX = 22.5; $CY = 20.1

function New-Icon {
    param([int]$Size, [double]$Factor, [bool]$Mask, [string]$Path)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # ground
    $g.FillRectangle((New-Object System.Drawing.SolidBrush($cBg)), 0, 0, $Size, $Size)

    # quiet 4x4 board pattern
    $cell = $Size / 4.0
    $bChk = New-Object System.Drawing.SolidBrush($cChecker)
    for ($r = 0; $r -lt 4; $r++) {
        for ($c = 0; $c -lt 4; $c++) {
            if ((($r + $c) % 2) -eq 0) {
                $g.FillRectangle($bChk, [single]($c*$cell), [single]($r*$cell), [single]$cell, [single]$cell)
            }
        }
    }

    # unit -> pixel mapping, centred on the pawn's true bbox centre
    $s = $Size / 45.0 * $Factor
    function ToX([double]$u) { return [single](($u - $CX) * $s + $Size/2.0) }
    function ToY([double]$u) { return [single](($u - $CY) * $s + $Size/2.0) }
    function ToS([double]$u) { return [single]($u * $s) }

    # The pawn is three overlapping shapes filled separately with one colour.
    # They must NOT go into a single GraphicsPath: the default Alternate fill
    # mode XORs the overlaps into holes, which shows as a dark seam at the neck.
    $bPawn = New-Object System.Drawing.SolidBrush($cPawn)

    # head
    $g.FillEllipse($bPawn, (ToX 16.5), (ToY 5.0), (ToS 12.0), (ToS 12.0))

    # body: shoulders flaring out of the neck
    $body = New-Object System.Drawing.Drawing2D.GraphicsPath
    $body.AddBezier((ToX 18.9), (ToY 15.0), (ToX 16.5), (ToY 17.4),
                    (ToX 14.7), (ToY 20.4), (ToX 14.2), (ToY 24.2))
    $body.AddLine((ToX 14.2), (ToY 24.2), (ToX 13.4), (ToY 30.6))
    $body.AddLine((ToX 13.4), (ToY 30.6), (ToX 31.6), (ToY 30.6))
    $body.AddLine((ToX 31.6), (ToY 30.6), (ToX 30.8), (ToY 24.2))
    $body.AddBezier((ToX 30.8), (ToY 24.2), (ToX 30.3), (ToY 20.4),
                    (ToX 28.5), (ToY 17.4), (ToX 26.1), (ToY 15.0))
    $body.CloseFigure()
    $g.FillPath($bPawn, $body)

    # base
    $pts = @(
        (New-Object System.Drawing.PointF((ToX 10.0), (ToY 30.2))),
        (New-Object System.Drawing.PointF((ToX 35.0), (ToY 30.2))),
        (New-Object System.Drawing.PointF((ToX 36.5), (ToY 35.2))),
        (New-Object System.Drawing.PointF((ToX 8.5),  (ToY 35.2)))
    )
    $g.FillPolygon($bPawn, $pts)

    # three brass pips, top-right, clear of the pawn
    if ($Mask) { $pipR = $Size*0.026; $step = $Size*0.052; $ox = $Size*0.700; $oy = $Size*0.300 }
    else       { $pipR = $Size*0.029; $step = $Size*0.062; $ox = $Size*0.800; $oy = $Size*0.200 }
    $bPip = New-Object System.Drawing.SolidBrush($cBrass)
    for ($i = 0; $i -lt 3; $i++) {
        $x = $ox - $i*$step; $y = $oy + $i*$step
        $g.FillEllipse($bPip, [single]($x-$pipR), [single]($y-$pipR), [single]($pipR*2), [single]($pipR*2))
    }

    $g.Dispose()
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output ("  {0}  ({1}x{1})" -f (Split-Path $Path -Leaf), $Size)
}

Write-Output 'Writing icons:'
New-Icon -Size 192 -Factor 0.80 -Mask $false -Path (Join-Path $OutDir 'icon-192.png')
New-Icon -Size 512 -Factor 0.80 -Mask $false -Path (Join-Path $OutDir 'icon-512.png')
New-Icon -Size 512 -Factor 0.58 -Mask $true  -Path (Join-Path $OutDir 'icon-maskable-512.png')
New-Icon -Size 180 -Factor 0.78 -Mask $false -Path (Join-Path $OutDir 'apple-touch-icon.png')
New-Icon -Size 32  -Factor 0.88 -Mask $false -Path (Join-Path $OutDir 'favicon-32.png')
Write-Output 'Done.'
