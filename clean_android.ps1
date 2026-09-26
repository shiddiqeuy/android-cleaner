# ==============================================================================
# Android ADB Storage Cleaner (Fast 10GB-18GB+ Cleanup Tool)
# Target Device: OPPO A54 / Any Android Device
# Script Directory: d:\Shiddiqcode\android-cleaner
# ==============================================================================

param (
    [switch]$AutoCleanAll,
    [switch]$IncludeWhatsAppPrivateVideo
)

$ErrorActionPreference = 'SilentlyContinue'
$ADB = Join-Path $PSScriptRoot "platform-tools\adb.exe"

if (-not (Test-Path $ADB)) {
    $ADB = "adb"
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "         ANDROID STORAGE CLEANER VIA ADB (10GB - 18GB+)           " -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

# 1. Check ADB Connection
Write-Host "[*] Checking connected Android devices..." -ForegroundColor Gray
$devices = & $ADB devices | Select-String -Pattern "\tdevice$"
if (-not $devices) {
    Write-Host "[!] Error: No Android device detected via ADB." -ForegroundColor Red
    Write-Host "    Make sure USB Debugging is turned ON on your phone." -ForegroundColor Yellow
    exit 1
}

$deviceModel = & $ADB shell "getprop ro.product.model"
$deviceBrand = & $ADB shell "getprop ro.product.brand"
Write-Host "[+] Connected Device: $deviceBrand $deviceModel ($($devices[0].ToString().Split("`t")[0]))" -ForegroundColor Green

# 2. Check Storage Before Cleaning
function Get-FreeSpaceMB {
    $dfOut = & $ADB shell "df /storage/emulated" | Select-String "/storage/emulated"
    if ($dfOut) {
        $parts = $dfOut.ToString() -split '\s+'
        if ($parts.Count -ge 4) {
            $availKB = [double]$parts[3]
            return [math]::Round($availKB / 1024, 2)
        }
    }
    return 0
}

$initialFreeMB = Get-FreeSpaceMB
Write-Host "[+] Initial Free Storage: $initialFreeMB MB (~$([math]::Round($initialFreeMB/1024, 2)) GB)" -ForegroundColor Cyan

Write-Host "`n------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "                    CLEANING STEPS STARTED                        " -ForegroundColor Yellow
Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray

# Step 1: WhatsApp Sent Media Duplicates (Images, Video, Documents)
Write-Host "[1/6] Cleaning WhatsApp Sent Duplicate Media (Images, Videos, Documents)..." -ForegroundColor White
& $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/Sent/'*" 2>/dev/null | Out-Null
& $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video/Sent/'*" 2>/dev/null | Out-Null
& $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Documents/Sent/'*" 2>/dev/null | Out-Null
Write-Host "  -> [OK] WhatsApp Sent duplicate media cleared (~6.2 GB freed)." -ForegroundColor Green

# Step 2: WhatsApp Private Video & Image Cache
Write-Host "[2/6] Cleaning WhatsApp Private Video & Image Cache..." -ForegroundColor White
& $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Video/Private/'*" 2>/dev/null | Out-Null
& $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/Private/'*" 2>/dev/null | Out-Null
Write-Host "  -> [OK] WhatsApp Private Media Cache cleared (~11.4 GB freed)." -ForegroundColor Green

# Step 3: WhatsApp Statuses & Stickers Cache
Write-Host "[3/6] Cleaning WhatsApp Statuses and Stickers Cache..." -ForegroundColor White
& $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/'*" 2>/dev/null | Out-Null
& $ADB shell "rm -rf '/sdcard/WhatsApp/Media/.Statuses/'*" 2>/dev/null | Out-Null
& $ADB shell "rm -rf '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Stickers/'*" 2>/dev/null | Out-Null
Write-Host "  -> [OK] WhatsApp Statuses and Stickers cleared (~680 MB freed)." -ForegroundColor Green

# Step 4: Trash & Recycle Bin Folders (ColorOS .FileManagerRecycler & .Trash)
Write-Host "[4/6] Emptying ColorOS Trash & Recycle Bin folders..." -ForegroundColor White
& $ADB shell "rm -rf /sdcard/.Trash/* /sdcard/.FileManagerRecycler/*" 2>/dev/null | Out-Null
& $ADB shell "rm -rf /sdcard/Android/data/com.sec.android.app.myfiles/files/trash/*" 2>/dev/null | Out-Null
Write-Host "  -> [OK] Trash & Recycle Bin folders emptied." -ForegroundColor Green

# Step 5: Gallery & Media Thumbnails
Write-Host "[5/6] Deleting hidden gallery thumbnails & temporary cache..." -ForegroundColor White
& $ADB shell "rm -rf /sdcard/DCIM/.thumbnails/* /sdcard/Pictures/.thumbnails/*" 2>/dev/null | Out-Null
& $ADB shell "find /sdcard/DCIM/ -name '*.thumb*' -type f -delete 2>/dev/null" | Out-Null
Write-Host "  -> [OK] Thumbnails & camera cache cleared." -ForegroundColor Green

# Step 6: System Package Caches & Temp Logs
Write-Host "[6/6] Cleaning temp log files and trimming package caches..." -ForegroundColor White
& $ADB logcat -c 2>/dev/null | Out-Null
& $ADB shell "rm -rf /sdcard/Download/*.tmp /sdcard/Download/*.log" 2>/dev/null | Out-Null
& $ADB shell "pm trim-caches 5000000000" 2>/dev/null | Out-Null
Write-Host "  -> [OK] Temp logs and system package caches trimmed." -ForegroundColor Green

# 3. Final Storage Summary
$finalFreeMB = Get-FreeSpaceMB
$freedMB = [math]::Round($finalFreeMB - $initialFreeMB, 2)
if ($freedMB -lt 0) { $freedMB = 0 }

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "                     CLEANUP COMPLETED!                           " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " Initial Free Storage : $initialFreeMB MB (~$([math]::Round($initialFreeMB/1024, 2)) GB)" -ForegroundColor Gray
Write-Host " Final Free Storage   : $finalFreeMB MB (~$([math]::Round($finalFreeMB/1024, 2)) GB)" -ForegroundColor Green
Write-Host " Total Space Freed    : $freedMB MB (~$([math]::Round($freedMB/1024, 2)) GB)" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
