# Android Storage Cleaner via ADB

Script otomatisasi pembersihan ruang penyimpanan internal HP Android (OPPO A54 / Samsung / Perangkat Android lainnya) menggunakan **ADB (Android Debug Bridge)**.

---

## 📊 Hasil Pembersihan Real-Time (OPPO A54)

- **Perangkat**: OPPO A54 (`CPH2239`)
- **Kapasitas Penyimpanan**: 105 GB
- **Penyimpanan Sebelum**: Sisa **1.89 GB** (99% Penuh)
- **Penyimpanan Sesudah**: Sisa **26.0 GB** (76% terpakai)
- **Total Ruang yang Berhasil Dibersihkan**: **~24.1 GB** 🎉

---

## 📁 Struktur Direktori Proyek (`d:\Shiddiqcode\android-cleaner`)

```text
d:\Shiddiqcode\android-cleaner\
├── clean_android.ps1           # Script utama PowerShell pembersih Android & WhatsApp cache
├── clean_whatsapp_videos.ps1   # Script pembersih khusus video WhatsApp (VID-*.mp4)
├── scan_apps_and_whatsapp.ps1  # Script pemindai cache aplikasi & video grup WhatsApp
├── run_cleaner.bat             # Launcher 1-Click Batch Script untuk Windows Explorer
├── download_adb.ps1            # Script downloader Android Platform-Tools (ADB)
├── .gitignore                  # File pengabaian git untuk ADB binaries & log
└── README.md                   # Dokumentasi petunjuk pemakaian
```

---

## 🚀 Cara Menjalankan Pembersihan

### Opsi 1: Double-Click Launcher (Paling Mudah)
Cukup double-click file [run_cleaner.bat](file:///d:/Shiddiqcode/android-cleaner/run_cleaner.bat) di Windows Explorer.

### Opsi 2: Menjalankan via PowerShell / Command Prompt

```powershell
# 1. Jalankan pembersihan otomatis (Trash, WhatsApp Sent/Private cache, Thumbnails):
powershell -ExecutionPolicy Bypass -File .\clean_android.ps1 -AutoCleanAll

# 2. Hapus seluruh file video WhatsApp (VID-*.mp4):
powershell -ExecutionPolicy Bypass -File .\clean_whatsapp_videos.ps1 -DeleteAllVideos

# 3. Pindai cache aplikasi & video WhatsApp besar:
powershell -ExecutionPolicy Bypass -File .\scan_apps_and_whatsapp.ps1
```

---

## 🧹 Target File & Folder yang Dibersihkan

1. **WhatsApp Sent & Private Cache**: Menghapus duplikat foto, video, dokumen terkirim (`WhatsApp Images/Sent`, `WhatsApp Video/Sent`, `WhatsApp Documents/Sent`) dan cache private (`WhatsApp Video/Private`).
2. **WhatsApp Video Files**: Menghapus file video WhatsApp (`VID-*.mp4`) yang menumpuk dari grup/chat.
3. **Android Package Cache (`pm trim-caches`)**: Memangkas cache paket aplikasi sistem Android.
4. **Gallery Thumbnails (`.thumbnails`)**: Menghapus file thumbnail galeri foto.
5. **Sampah & Recycle Bin**: Menghapus isi folder sampah ColorOS (`.FileManagerRecycler`) dan Android (`.Trash`).
6. **Logcat & Temp Files**: Menghapus file temporary (`*.tmp`) dan file log (`*.log`).
