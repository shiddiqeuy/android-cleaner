$ADB = Join-Path $PSScriptRoot "platform-tools\adb.exe"
if (-not (Test-Path $ADB)) { $ADB = "adb" }

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    SCANNING CACHE APLIKASI & VIDEO WHATSAPP GROUP (OPPO A54)     " -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

# 1. Check ADB Connection
$devices = & $ADB devices | Select-String -Pattern "\tdevice$"
if (-not $devices) {
    Write-Host "[!] Error: Perangkat tidak terdeteksi via ADB." -ForegroundColor Red
    exit 1
}

# 2. Scan App Caches in /sdcard/Android/data/*/cache
Write-Host "`n[1/3] Memindai Cache Aplikasi Terbesar..." -ForegroundColor White
$cacheCmd = & $ADB shell "du -sk /sdcard/Android/data/*/cache 2>/dev/null | sort -nr | head -n 15"
$appCaches = @()

foreach ($line in $cacheCmd) {
    $parts = $line.Trim() -split '\s+'
    if ($parts.Count -ge 2 -and $parts[0] -match '^\d+$') {
        $kb = [double]$parts[0]
        $mb = [math]::Round($kb / 1024, 2)
        $gb = [math]::Round($kb / 1MB, 2)
        $pkgPath = $parts[1]
        $pkgName = $pkgPath -replace '/sdcard/Android/data/', '' -replace '/cache', ''
        
        if ($mb -gt 5) {
            $appCaches += [PSCustomObject]@{
                "Nama Paket / Aplikasi" = $pkgName
                "Ukuran MB" = $mb
                "Ukuran GB" = $gb
                RawKB = $kb
            }
        }
    }
}

if ($appCaches) {
    $appCaches | Sort-Object RawKB -Descending | Format-Table -AutoSize "Nama Paket / Aplikasi", "Ukuran MB", "Ukuran GB"
} else {
    Write-Host "  -> Cache aplikasi utama relatif bersih." -ForegroundColor Green
}

# 3. Scan WhatsApp Videos (Video Group & Chat)
Write-Host "`n[2/3] Memindai File Video WhatsApp Terbesar (>10MB)..." -ForegroundColor White
$vidCmd = & $ADB shell "find '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video' -type f -size +10M -exec du -sk {} + 2>/dev/null | sort -nr | head -n 15"
$waVideos = @()

foreach ($line in $vidCmd) {
    $parts = $line.Trim() -split '\s+', 2
    if ($parts.Count -ge 2 -and $parts[0] -match '^\d+$') {
        $kb = [double]$parts[0]
        $mb = [math]::Round($kb / 1024, 2)
        $filePath = $parts[1]
        $fileName = Split-Path $filePath -Leaf
        
        $waVideos += [PSCustomObject]@{
            "Nama File Video" = $fileName
            "Ukuran MB" = $mb
            "Lokasi Path" = $filePath
            RawKB = $kb
        }
    }
}

if ($waVideos) {
    $waVideos | Sort-Object RawKB -Descending | Format-Table -AutoSize "Nama File Video", "Ukuran MB"
} else {
    Write-Host "  -> Tidak ditemukan video tunggal >10MB di WhatsApp Video." -ForegroundColor Gray
}

# 4. Total WhatsApp Media Summary
Write-Host "`n[3/3] Ringkasan Total Folder WhatsApp Media..." -ForegroundColor White
$waSummaryCmd = & $ADB shell "du -sk '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video' '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents' '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images' '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Audio' 2>/dev/null"

$waFolders = @()
foreach ($line in $waSummaryCmd) {
    $parts = $line.Trim() -split '\s+', 2
    if ($parts.Count -ge 2 -and $parts[0] -match '^\d+$') {
        $kb = [double]$parts[0]
        $mb = [math]::Round($kb / 1024, 2)
        $gb = [math]::Round($kb / 1MB, 2)
        $folderName = Split-Path $parts[1] -Leaf
        
        $waFolders += [PSCustomObject]@{
            "Kategori Media WhatsApp" = $folderName
            "Ukuran MB" = $mb
            "Ukuran GB" = $gb
            RawKB = $kb
        }
    }
}

$waFolders | Sort-Object RawKB -Descending | Format-Table -AutoSize "Kategori Media WhatsApp", "Ukuran MB", "Ukuran GB"
