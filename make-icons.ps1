Add-Type -AssemblyName System.Drawing

function New-Icon {
    param([int]$Size, [string]$OutPath, [bool]$Maskable = $false)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    $bgColor = [System.Drawing.ColorTranslator]::FromHtml('#5b8a72')
    $bg = New-Object System.Drawing.SolidBrush($bgColor)

    if ($Maskable) {
        $g.FillRectangle($bg, 0, 0, $Size, $Size)
    } else {
        $r = [int]($Size * 0.22)
        $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $gp.AddArc(0, 0, $r*2, $r*2, 180, 90)
        $gp.AddArc($Size - $r*2, 0, $r*2, $r*2, 270, 90)
        $gp.AddArc($Size - $r*2, $Size - $r*2, $r*2, $r*2, 0, 90)
        $gp.AddArc(0, $Size - $r*2, $r*2, $r*2, 90, 90)
        $gp.CloseFigure()
        $g.FillPath($bg, $gp)
        $gp.Dispose()
    }

    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

    $safe = if ($Maskable) { 0.6 } else { 0.72 }
    $bodyW = [single]($Size * $safe)
    $bodyH = [single]($bodyW * 0.55)
    $cx = [single]($Size / 2)
    $cy = [single]($Size / 2)
    $left = [single]($cx - $bodyW / 2)
    $top = [single]($cy - $bodyH / 2)

    # Fish body
    $g.FillEllipse($whiteBrush, $left, $top, $bodyW * 0.78, $bodyH)

    # Tail triangle
    $tailX = [single]($left + $bodyW * 0.78)
    [System.Drawing.PointF[]]$tail = @(
        [System.Drawing.PointF]::new($tailX, $cy),
        [System.Drawing.PointF]::new($left + $bodyW, $top),
        [System.Drawing.PointF]::new($left + $bodyW, $top + $bodyH)
    )
    $g.FillPolygon($whiteBrush, $tail)

    # Eye
    $eyeR = [single]($bodyH * 0.10)
    $eyeX = [single]($left + $bodyW * 0.15)
    $eyeY = [single]($cy - $eyeR - $bodyH * 0.10)
    $darkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#2a4738'))
    $g.FillEllipse($darkBrush, $eyeX, $eyeY, $eyeR * 2, $eyeR * 2)

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    $whiteBrush.Dispose()
    $darkBrush.Dispose()
    $bg.Dispose()
    Write-Host "Wrote $OutPath"
}

$dir = Split-Path -Parent $MyInvocation.MyCommand.Definition
New-Icon -Size 192 -OutPath (Join-Path $dir 'icon-192.png') -Maskable $false
New-Icon -Size 512 -OutPath (Join-Path $dir 'icon-512.png') -Maskable $false
New-Icon -Size 512 -OutPath (Join-Path $dir 'icon-512-maskable.png') -Maskable $true
New-Icon -Size 180 -OutPath (Join-Path $dir 'apple-touch-icon.png') -Maskable $false
New-Icon -Size 32  -OutPath (Join-Path $dir 'favicon-32.png') -Maskable $false
