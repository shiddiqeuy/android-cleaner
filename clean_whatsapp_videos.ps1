# ==============================================================================
# WhatsApp Video Cleaner via ADB
# Script Directory: d:\Shiddiqcode\android-cleaner
# ==============================================================================

param (
    [switch]$DeleteAllVideos,
    [switch]$DeleteOldVideosOnly
)

$ADB = Join-Path $PSScriptRoot "platform-tools\adb.exe"
if (-not (Test-Path $ADB)) { $ADB = "adb" }

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "             PEMBERSIH VIDEO WHATSAPP VIA ADB                     " -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

# 1. Check Device
$devices = & $ADB devices | Select-String -Pattern "\tdevice$"
if (-not $devices) {
    Write-Host "[!] Perangkat tidak terdeteksi via ADB." -ForegroundColor Red
    exit 1
}

# 2. Measure Initial Size
function Get-WaVideoSizeKB {
    $out = & $ADB shell "du -sk '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video' 2>`$null"
    if ($out) {
        $str = $out[0].ToString().Trim()
        $parts = $str -split '\s+'
        if ($parts[0] -match '^\d+$') { return [double]$parts[0] }
    }
    return 0
}

$initKB = Get-WaVideoSizeKB
$initMB = [math]::Round($initKB / 1024, 2)
$initGB = [math]::Round($initKB / 1MB, 2)
Write-Host "[+] Ukuran Awal Folder WhatsApp Video: $initGB GB ($initMB MB)" -ForegroundColor Cyan

Write-Host "`n------------------------------------------------------------------" -ForegroundColor DarkGray

if ($DeleteAllVideos) {
    Write-Host "[*] Menghapus SELURUH File Video di WhatsApp Video..." -ForegroundColor Yellow
    & $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video/'VID-*.mp4" | Out-Null
    Write-Host "  -> [OK] Seluruh File Video WhatsApp berhasil dibersihkan!" -ForegroundColor Green
} else {
    Write-Host "[*] Menghapus Video WhatsApp Tahun Lama (2022, 2023, 2024)..." -ForegroundColor Yellow
    & $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video/'VID-2022*.mp4 '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video/'VID-2023*.mp4 '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video/'VID-2024*.mp4" | Out-Null
    Write-Host "  -> [OK] Video WhatsApp lama (2022-2024) berhasil dibersihkan!" -ForegroundColor Green
}

# 3. Measure Final Size
$finalKB = Get-WaVideoSizeKB
$finalMB = [math]::Round($finalKB / 1024, 2)
$finalGB = [math]::Round($finalKB / 1MB, 2)
$freedGB = [math]::Round(($initKB - $finalKB) / 1MB, 2)
if ($freedGB -lt 0) { $freedGB = 0 }

# Trigger MediaScan
& $ADB shell "content call --uri content://media --method scan_volume --arg external; am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard" | Out-Null

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "                PEMBERSIHAN VIDEO SELESAI!                        " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " Ukuran Awal  : $initGB GB ($initMB MB)" -ForegroundColor Gray
Write-Host " Ukuran Akhir : $finalGB GB ($finalMB MB)" -ForegroundColor Green
Write-Host " Total Bebas  : $freedGB GB" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
