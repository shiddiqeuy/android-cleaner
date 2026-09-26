$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
$zipPath = "$env:TEMP\platform-tools-latest-windows.zip"
$targetDir = "d:\Shiddiqcode\android-cleaner"

Write-Host "Downloading Android Platform-Tools..."
Invoke-WebRequest -Uri $url -OutFile $zipPath

Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $targetDir -Force

Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
Write-Host "Done downloading ADB!"
