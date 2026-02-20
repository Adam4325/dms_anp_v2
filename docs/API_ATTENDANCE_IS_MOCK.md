# Attendance API: Penggunaan `is_mock`

## Endpoint terkait
- `mobile/api/absensi/check_in_out_geofence_driver.jsp` (checkin/checkout attendance driver)
- Endpoint absensi lain yang menerima parameter `is_mock`

## Parameter dari client
- **`is_mock`**: `'1'` = client mendeteksi mock/fake GPS, `'0'` = tidak terdeteksi.
- Sumber di app: plugin TrustLocation (sering **false positive** pada beberapa device).

## Aturan untuk backend (wajib)

1. **Jangan menolak absensi HANYA karena `is_mock == '1'`.**
   - Banyak device GPS asli dilaporkan sebagai mock oleh plugin → user legit tertolak.

2. **Gunakan `is_mock` hanya sebagai salah satu sinyal.**
   - Contoh: log / flag untuk review jika `is_mock == '1'`.
   - Tolak atau flag hanya jika ada **sinyal lain** yang mencurigakan, misalnya:
     - Lokasi (lat/lon) tidak masuk geofence yang valid.
     - Pola tidak wajar (pindah lokasi ekstrem dalam waktu singkat).
     - Data lain (IP, waktu, history) yang tidak konsisten.

3. **Rekomendasi**
   - Jika `is_mock == '1'` dan lokasi konsisten dengan geofence + tidak ada indikasi lain → **terima** absensi, boleh tetap log untuk audit.
   - Jika `is_mock == '1'` **dan** lokasi di luar geofence / pola aneh → boleh **reject** atau flag untuk review.

Dengan aturan ini, pengguna GPS asli tidak terganggu false positive, sementara deteksi mock tetap dipakai untuk analisis dan penolakan hanya bila ada bukti lain.
