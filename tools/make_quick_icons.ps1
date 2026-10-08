Add-Type -AssemblyName System.Drawing

$src = 'C:\Users\Webtin\.cursor\projects\d-application-Android-cakeyousef\assets'
$dst = 'D:\application\Android\cakeyousef\assets\images\quick'
New-Item -ItemType Directory -Force -Path $dst | Out-Null

$map = @{
  'qa_shop.png'    = 'shop.png'
  'qa_courses.png' = 'courses.png'
  'qa_free.png'    = 'free.png'
  'qa_support.png' = 'support.png'
  'qa_calc.png'    = 'calculator.png'
  'qa_color.png'   = 'color.png'
}

foreach ($key in $map.Keys) {
  $inPath = Join-Path $src $key
  if (-not (Test-Path $inPath)) { Write-Host "missing $inPath"; continue }

  $bmp = New-Object System.Drawing.Bitmap($inPath)
  $w = $bmp.Width
  $h = $bmp.Height

  $work = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($work)
  $g.DrawImage($bmp, 0, 0, $w, $h)
  $g.Dispose()
  $bmp.Dispose()

  $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
  $data = $work.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $stride = $data.Stride
  $bytes = New-Object byte[] ($stride * $h)
  [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)

  # flood fill background from borders (near-white only) so interior whites stay opaque
  $visited = New-Object bool[] ($w * $h)
  $queue = New-Object System.Collections.Generic.Queue[int]
  for ($x = 0; $x -lt $w; $x++) {
    foreach ($y in @(0, $h - 1)) {
      $idx = $y * $w + $x
      if (-not $visited[$idx]) { $visited[$idx] = $true; $queue.Enqueue($idx) }
    }
  }
  for ($y = 0; $y -lt $h; $y++) {
    foreach ($x in @(0, $w - 1)) {
      $idx = $y * $w + $x
      if (-not $visited[$idx]) { $visited[$idx] = $true; $queue.Enqueue($idx) }
    }
  }

  $threshold = 238
  $clear = New-Object bool[] ($w * $h)

  while ($queue.Count -gt 0) {
    $idx = $queue.Dequeue()
    $y = [math]::Floor($idx / $w)
    $x = $idx - ($y * $w)
    $o = $y * $stride + $x * 4
    $b = $bytes[$o]; $gr = $bytes[$o + 1]; $r = $bytes[$o + 2]
    if ($b -lt $threshold -or $gr -lt $threshold -or $r -lt $threshold) { continue }
    $clear[$idx] = $true
    foreach ($d in @(@(1, 0), @(-1, 0), @(0, 1), @(0, -1))) {
      $nx = $x + $d[0]; $ny = $y + $d[1]
      if ($nx -lt 0 -or $ny -lt 0 -or $nx -ge $w -or $ny -ge $h) { continue }
      $nidx = $ny * $w + $nx
      if ($visited[$nidx]) { continue }
      $visited[$nidx] = $true
      $queue.Enqueue($nidx)
    }
  }

  for ($i = 0; $i -lt $clear.Length; $i++) {
    if (-not $clear[$i]) { continue }
    $y = [math]::Floor($i / $w)
    $x = $i - ($y * $w)
    $o = $y * $stride + $x * 4
    $bytes[$o + 3] = 0
  }

  [System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $data.Scan0, $bytes.Length)
  $work.UnlockBits($data)

  $size = 320
  $out = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g2 = [System.Drawing.Graphics]::FromImage($out)
  $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g2.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g2.DrawImage($work, 0, 0, $size, $size)
  $g2.Dispose()

  $outPath = Join-Path $dst $map[$key]
  $out.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $out.Dispose()
  $work.Dispose()
  Write-Host "saved $outPath"
}
