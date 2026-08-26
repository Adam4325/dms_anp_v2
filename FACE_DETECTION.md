# Face Detection — Enrollment Wajah Absensi

Dokumentasi alur **enrollment wajah** karyawan untuk absensi DMS ANP.  
Foto master disimpan **sekali** (setelah HRD approve). Foto check-in **tidak disimpan**.

**Berlaku untuk:** absensi karyawan (`FrmAttendance`), bukan driver mixer.

---

## Ringkasan

| Item | Isi |
|---|---|
| Tujuan | Pastikan yang absen orang hidup (bukan foto/print), dan wajah sudah didaftarkan HRD |
| Liveness | Kedip mata (senyum sementara dimatikan) |
| Foto DB | Hanya 1 file master di `photo_trucking/PHOTO_FACE/` |
| Approve | Manual HRD lewat menu **Apv. Wajah** (akses `HD` / `ADMIN`) |
| Check-in | Wajib verifikasi 1x (liveness + cocokkan vs foto enroll) |
| Check-out | Wajib verifikasi lagi (bukan skip) |
| Validasi SIM | Dimatikan (di-comment) |

---

## Status enrollment

| Status | Artinya | Bisa absen? |
|---|---|---|
| `NONE` | Belum pernah enroll | Tidak — diarahkan ke enroll |
| `PENDING` | Sudah kirim foto, menunggu HRD | Tidak |
| `REJECTED` | HRD menolak — boleh enroll ulang | Tidak |
| `APPROVED` | HRD setuju — wajah terkunci | Ya (check-in + liveness) |

Setelah `APPROVED`, enroll ulang ditolak API.

---

## Skenario pertama kali (karyawan)

```
Login → menu Absensi
    → status NONE
    → halaman Enrollment Wajah
    → Mulai Enrollment
    → kamera depan: wajah di oval → kedip
    → foto dikirim (PENDING)
    → absensi terkunci sampai HRD approve
```

1. Karyawan buka **Absensi**.
2. App panggil `method=status`.
3. Belum ada data → `FrmFaceEnroll`.
4. Tombol **Mulai Enrollment Wajah**.
5. Izinkan kamera. Hadapkan wajah ke oval.
6. Ikuti instruksi: **Kedipkan mata**. (Senyum sementara di-comment.)
7. Foto diambil otomatis, dikompres (lebar max 640, JPG quality 55), dikirim `method=enroll`.
8. Pesan: *Enrollment terkirim. Menunggu approve HRD.*
9. Buka Absensi lagi sebelum approve → warning, tidak masuk form check-in.

Syarat: `kryid` dari login, atau IMEI ada di `TBLKARYAWAN` (Active). Tabel `TBLFACEENROLL` sudah ada di MaxDB. JSP sudah di-deploy.

---

## Skenario HRD approve

Tidak otomatis. Tidak ada push notif.

1. Login akun **HD** atau **ADMIN** (bukan DRIVER).
2. Menu **Apv. Wajah**.
3. Lihat foto + nama + KRYID yang `PENDING`.
4. **Approve** atau **Reject** (+ alasan).
5. Reject → karyawan boleh enroll ulang.

---

## Skenario check-in setelah approved

1. Buka **Absensi** → masuk `FrmAttendance`.
2. **Check IN** dan **Check OUT** masing-masing 1x verifikasi (kedip + cocokkan foto enroll).
3. Wajah beda (bukan orang yang di-enroll) → **ditolak**, absen tidak tersimpan.
4. Jangan sampai layar verifikasi muncul 2x dalam 1 tap (guard double-tap + 1x capture).
5. Field `photo` **tidak dikirim**. Foto profile hanya tampil di HP.

---

## Liveness (Android)

Paket: `google_mlkit_face_detection` (kamera depan).

| Cek | Aturan |
|---|---|
| Wajah | Harus di dalam oval, cukup dekat |
| Kedip | Mata terbuka → tertutup → terbuka |
| Senyum 1x | Sementara dimatikan (kode di-comment) |
| Galeri | Tidak ada — kamera live saja |

Mode:

- `enroll` — lolos liveness lalu `takePicture()`, file di-upload
- `verify` — lolos liveness, ambil foto sementara, bandingkan dengan foto enroll, lalu foto dibuang

Wajah live vs enroll memakai crop wajah + cosine/histogram (threshold `0.36`). Foto di-orientasi EXIF dulu, kamera depan di-flip (copy dulu, bukan mutate). Bukan FaceNet, tapi cukup menolak wajah orang lain.

Check-in/out kadang gagal karena koneksi `method=status` / unduh foto putus (`Connection closed before full header`). Client retry 3x, cache status+foto enroll per `kryid`, dan verifikasi pakai foto lokal jika sudah pernah diunduh.

Catatan build: `Note: FaceDetector.java uses unchecked or unsafe operations` dari plugin ML Kit. Bukan error; APK tetap bisa jadi.

---

## File Android (Flutter)

| File | Fungsi |
|---|---|
| `lib/src/pages/FaceLivenessPage.dart` | Kamera + deteksi kedip (senyum di-comment) |
| `lib/src/Helper/face_match_helper.dart` | Bandingkan wajah live vs foto enroll |
| `lib/src/pages/FrmFaceEnroll.dart` | Halaman enroll karyawan |
| `lib/src/pages/hrd/ListApvFaceEnroll.dart` | List approve HRD |
| `lib/src/services/face_enroll_service.dart` | Client API |
| `lib/src/pages/ViewDashboard.dart` | Gate Absensi + menu Apv. Wajah (`idKey: 37`) |
| `lib/src/pages/FrmAttendance.dart` | Check-in wajib enroll + liveness |

Endpoint client:

`{baseUrlProd}api/absensi/face_enroll.jsp`  
contoh: `https://apps.tuluatas.com/trucking/mobile/api/absensi/face_enroll.jsp`

---

## API

File deploy: `trucking-v2/web/mobile/api/absensi/face_enroll.jsp`

Tidak ada `ensureTable`. Tabel harus dibuat manual di MaxDB.

### method

| method | HTTP | Fungsi |
|---|---|---|
| `status` | GET | Status enroll terbaru (`kryid` / `imeiid`) |
| `enroll` | POST | Kirim foto master + `liveness_ok=Y` |
| `list` | GET | Daftar HRD (`status=PENDING\|APPROVED\|REJECTED\|ALL`, `q` = cari nama/KRYID) |
| `approve` | POST | `id` + `userid` — hanya jika `PENDING` |
| `reject` | POST | `id` + `userid` + `note` |
| `delete` | POST | Hard delete `id` + hapus file foto — karyawan bisa enroll ulang |

### enroll (POST)

| Param | Wajib | Keterangan |
|---|---|---|
| `kryid` | ya* | *bisa diisi dari IMEI jika kosong |
| `username` | | dari session |
| `namakry` | | nama karyawan |
| `imeiid` | | device ID |
| `photo` | ya | base64 JPG |
| `liveness_ok` | ya | `Y` / `1` / `true` |

Foto disimpan ke folder webapp:

`photo_trucking/PHOTO_FACE/FACE_{kryid}_{yyyyMMddHHmmss}.jpg`

URL relatif: `photo_trucking/PHOTO_FACE/{filename}`

Kalau status terakhir `PENDING`, foto lama diganti (update baris yang sama).  
Kalau `APPROVED`, enroll ditolak (`status_code` 304).

### Response

```json
{
  "status_code": 200,
  "message": "OK",
  "data": {
    "id": 1,
    "kryid": "1234",
    "username": "budi",
    "namakry": "Budi",
    "photo_file": "FACE_1234_20260826120000.jpg",
    "photo_url": "photo_trucking/PHOTO_FACE/FACE_1234_20260826120000.jpg",
    "status": "PENDING",
    "reject_note": ""
  }
}
```

`list` membungkus array di `data.items`.

---

## Tabel MaxDB — `TBLFACEENROLL`

```sql
CREATE TABLE TBLFACEENROLL (
  ID INTEGER DEFAULT SERIAL,
  KRYID VARCHAR(50) ASCII NOT NULL,
  USERNAME VARCHAR(100) ASCII,
  NAMAKRY VARCHAR(200) UNICODE,
  PHOTO_FILE VARCHAR(255) ASCII,
  IMEIID VARCHAR(100) ASCII,
  STATUS VARCHAR(20) ASCII NOT NULL,
  LIVENESS_OK CHAR(1) ASCII,
  CREATED_AT TIMESTAMP,
  CREATED_USER VARCHAR(100) ASCII,
  APPROVED_AT TIMESTAMP,
  APPROVED_USER VARCHAR(100) ASCII,
  REJECT_NOTE VARCHAR(500) UNICODE,
  PRIMARY KEY (ID)
);

CREATE INDEX IDX_FACEENROLL_KRY ON TBLFACEENROLL (KRYID);
CREATE INDEX IDX_FACEENROLL_STATUS ON TBLFACEENROLL (STATUS);
```

`STATUS`: `PENDING` | `APPROVED` | `REJECTED`

---

## Menu & akses

| Menu | idKey | Siapa |
|---|---|---|
| Absensi | 15 | Karyawan (bukan path DRIVER+status DRIVER) |
| Apv. Wajah | 37 | `akses_pages` berisi `HD`, atau username `ADMIN` |

Validasi SIM (`SimPhoneGuard.blockIfPhoneInvalid`) di-comment di:

- `ViewDashboard.dart` (buka absensi driver/karyawan + fingerprint)
- `FrmAttendance.dart`
- `FrmAttendanceDriver.dart`

---

## Deploy

1. Buat tabel `TBLFACEENROLL` di MaxDB (script di atas).
2. Copy `face_enroll.jsp` ke Tomcat: `{webapp}/trucking/mobile/api/absensi/`.
3. Pastikan folder `photo_trucking/PHOTO_FACE` writable oleh Tomcat.
4. Build APK Flutter (sudah ada dependency `google_mlkit_face_detection`).

---

## Yang tidak termasuk

- Enrollment untuk **driver** (`FrmAttendanceDriver`)
- Halaman approve di **web HRD**
- Notifikasi ke HRD saat ada enroll baru
- Penyimpanan foto setiap check-in
