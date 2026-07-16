# DMS ANP ↔ Trucking API

## Ringkasan

| Bagian | Path | Teknologi |
|--------|------|-----------|
| App (Android) | `D:\DMS_ANP\dms_anp` | Flutter (target Android) |
| Backend API | `D:\DMS_ANP\trucking` | JSP legacy (style Java 6), Tomcat |

**DMS ANP** = Driver Management System — Andalan Nusa Pratama. App Flutter untuk operasional armada trucking, memanggil API di project **trucking**.

> Catatan ejaan path: folder API adalah **`mobile`** (bukan `mobil`).

## Base URL (Flutter)

Definisi di `lib/src/Helper/Provider.dart` → class `GlobalData`:

| Constant | Nilai (prod) | Dipakai untuk |
|----------|--------------|---------------|
| `baseUrl` | `https://apps.tuluatas.com/trucking/mobile/` | Umum + `api/*.jsp` |
| `baseUrlProd` | `https://apps.tuluatas.com/trucking/mobile/` | Sama (prod) |
| `baseUrlOri` | `https://apps.tuluatas.com/trucking/` | Root app + `mobile/api/...`, `master/...`, gambar |
| `baseUrlServlet` | `https://apps.tuluatas.com/trucking/mobile/` | Servlet / mobile |
| `baseUrlDEV` | `https://apps.tuluatas.com:8080/cemindo/mobile/` | Legacy DEV |

Contoh pemanggilan:

```dart
// → https://apps.tuluatas.com/trucking/mobile/api/authorize_v9.jsp
GlobalData.baseUrl + 'api/authorize_v9.jsp'

// → https://apps.tuluatas.com/trucking/mobile/api/absensi/...
GlobalData.baseUrlOri + 'mobile/api/absensi/get_info_absensi.jsp'
```

Query string: pakai `Uri.replace(queryParameters: ...)` — lihat `queryParameters.md`.

## Mapping path app → sumber API

| URL runtime | File sumber |
|-------------|-------------|
| `/trucking/mobile/api/*.jsp` | `trucking/web/mobile/api/` |
| `/trucking/mobile/api/<modul>/*.jsp` | `trucking/web/mobile/api/<modul>/` |
| `/trucking/api/*.jsp` | `trucking/web/api/` (kadang via `baseUrlOri + 'api/...'`) |
| `/trucking/master/*.jsp` | `trucking/web/master/` |

Modul di `web/mobile/api/`: `absensi`, `aduan`, `do`, `do_mixer`, `driver`, `duration`, `firebase`, `gt`, `imeiid`, `inventory`, `laka`, `maintenance`, `mekanik`, `nontera`, `p2h_driver`, `pb`, `po`, `points`, `units`, `vehicle`.

## Struktur app Flutter (penting)

```
lib/src/
  loginPage.dart
  Helper/          # GlobalData (Provider.dart), AnpService, cache, dll
  pages/           # Dashboard, DO, absensi, PB/PO, P2H, inventory, …
  services/        # FCM, notifikasi, background
  model/
```

## Aturan coding Flutter (wajib)

- Jangan ubah fungsi existing tanpa perlu; **jangan naikkan SDK** Flutter/Dart/Gradle.
- **Jangan** pakai nullsafety style: no `String?`, no `!`, no `required`.
- Detail rule: `.cursor/rules/dmsrule.mdc`
- Badge menu NEW: `menuBadge.md`
- Panduan lengkap/migrasi (warna, tema, dll): `INSTRUCTIONS.md` di root app
- Transaksi DB di API: `DBHANDLER.md` (di root app, acuan JSP)

## UI Button — Orange Soft (wajib)

**Jangan** buat tombol aksi transparan / text-only tanpa background (mis. plain `TextButton` / `GestureDetector` + teks saja). Tombol harus terlihat jelas dengan warna tema orange soft.

Warna tema (lihat juga `INSTRUCTIONS.md` / `STYLE_GUIDE.md`):

| Nama | Hex | Pakai untuk |
|------|-----|-------------|
| `primaryOrange` | `#FF8C69` | Aksi utama (Pilih, Scan, Save, Ok) |
| `accentOrange` | `#FFB347` | Aksi sekunder (Search, Add, Select) |
| `lightOrange` | `#FFF4E6` | Background bordered / soft fill |
| `darkOrange` | `#E07B39` | Aksi kuat (Delete) |
| Grey `shade600` | — | Close / cancel |

Pola di inventory (`FrmInventory`, `ListInventoryDetail`):

- **Solid fill** + teks putih: semua aksi utama (Scan QRCode, Search By Name, Pilih, Close, Select, Delete)
- Hindari bordered-only / transparan untuk tombol aksi dialog & list
- Hindari `InkWell` di overlay `PageRoute` custom (bug MediaQuery dispose) — pakai `GestureDetector` + `Container` berwarna

Contoh file terkait: `lib/src/pages/inventory/FrmInventory.dart` (Search By Name list: Pilih / Close).

## DO Mixer — Logkar upload dokumen

Alur OUTUNLOADING → Close DO:

1. `ViewDashboard` (status OUTUNLOADING) → simpan `logkar_mixer_no_do` → `ViewListDoMixer`
2. `ViewListDoMixer` tombol **DO DiTerima** → `CreateDoDiTerima` saja → `FrmCloseVehicleMixer` (**jangan** upload Logkar di sini)
3. `FrmCloseVehicleMixer` **Capture** foto → **Submit** → jika `isApiLokarRUN`: upload dokumen + status `99` ke Logkar dulu; gagal = stop; sukses = lanjut `closeDo`

Prefs: `logkar_mixer_no_do` (dihapus setelah close DO sukses).

**Background Send Position (doc 1.1):** `LogkarPositionBackgroundService` kirim `/transporter/order/position` tiap 1 menit (foreground service). Saat tracking aktif (`shouldBlockAutoLogout()`), **auto-logout idle** (`UserInactivityScope`) dan **session inactive logout** (`ViewDashboard._logoutInactiveSession`) **jangan dijalankan** — agar `prefs.clear()` tidak mematikan service.

## Backend singkat

- Style dokumentasi tim: **Java 6 JSP** (legacy); NetBeans build properties: `javac` 1.8 — tulis JSP tetap gaya lama (`DbHandler`, string SQL, Gson JSON).
- Docs API lengkap: `../trucking/.cursor/trucking-api.md` (buka workspace sibling `trucking`).
