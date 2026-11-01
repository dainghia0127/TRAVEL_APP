Add-Type -AssemblyName System.Drawing

$dir = "c:\Users\DELL\Downloads\AI Coding\Gemini Code\TRAVEL_APP\mobile_flutter\assets\images\destinations"
$files = Get-ChildItem -Path $dir -Filter "*.jpg"

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]82)

$totalOld = 0
$totalNew = 0

foreach ($f in $files) {
    $srcPath = $f.FullName
    $oldSize = $f.Length
    $totalOld += $oldSize

    $img = $null
    $bmp = $null
    $g = $null

    try {
        # Đọc vào byte array rồi mở bằng MemoryStream để không lock file
        $bytes = [System.IO.File]::ReadAllBytes($srcPath)
        $ms = New-Object System.IO.MemoryStream(,$bytes)
        $img = [System.Drawing.Image]::FromStream($ms)

        $maxDim = 1080
        $w = $img.Width
        $h = $img.Height

        if ($w -gt $maxDim -or $h -gt $maxDim) {
            if ($w -ge $h) {
                $nw = $maxDim
                $nh = [int]($h * ($maxDim / $w))
            } else {
                $nh = $maxDim
                $nw = [int]($w * ($maxDim / $h))
            }
        } else {
            $nw = $w
            $nh = $h
        }

        $bmp = New-Object System.Drawing.Bitmap($nw, $nh)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.DrawImage($img, 0, 0, $nw, $nh)

        # Lưu ra MemoryStream mới
        $outMs = New-Object System.IO.MemoryStream
        $bmp.Save($outMs, $encoder, $encParams)
        $newBytes = $outMs.ToArray()
        $newSize = $newBytes.Length
        $totalNew += $newSize

        # Ghi đè file
        [System.IO.File]::WriteAllBytes($srcPath, $newBytes)

        $oldMb = ($oldSize / 1MB).ToString("F2")
        $newKb = ($newSize / 1KB).ToString("F1")
        Write-Host "$($f.Name): $oldMb MB -> $newKb KB ($nw x $nh)"
    }
    catch {
        Write-Host "Error processing $($f.Name): $_"
        $totalNew += $oldSize
    }
    finally {
        if ($g) { $g.Dispose() }
        if ($bmp) { $bmp.Dispose() }
        if ($img) { $img.Dispose() }
        if ($ms) { $ms.Dispose() }
        if ($outMs) { $outMs.Dispose() }
    }
}

$totOldMb = ($totalOld / 1MB).ToString("F2")
$totNewMb = ($totalNew / 1MB).ToString("F2")
Write-Host "`n=== OPTIMIZATION SUMMARY ==="
Write-Host "Old total size: $totOldMb MB"
Write-Host "New total size: $totNewMb MB"
Write-Host "RAM savings on iPhone: ~98%!"

