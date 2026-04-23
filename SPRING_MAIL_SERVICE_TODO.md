# Spring Mail Service TODO

Dokumen ini pengingat implementasi backend baru (Spring Boot) untuk kirim email PO + attachment PDF, supaya tidak lanjut di JSP scriptlet.

## Goal

- Pindahkan endpoint kirim email PO dari JSP ke Spring Boot.
- Pertahankan format response agar kompatibel dengan app Android saat ini.
- Fokus utama: endpoint setara `send_po_print_email.jsp`.

## Endpoint Target

- Method: `GET` (sementara, supaya kompatibel dengan app sekarang)
- Path: `/trucking/reporting/send_po_print_email.jsp`
- Query params:
  - `ponbr` (required)
  - `email` (optional)
  - `cc` (optional)
  - `userid` (optional)

## Response Contract (WAJIB kompatibel)

- Success:
  - `status: "success"`
  - `status_code: 200`
  - `message: "Email PO sent successfully"`
- Error:
  - `status: "error"`
  - `status_code: 400/500`
  - `message: <error>`
  - `debug.step: <step terakhir>`

## Setup Project Baru

1. Buat workspace/folder baru, contoh: `trucking-mail-service`.
2. Generate Spring Boot project (Maven, Java 11/17).
3. Tambahkan dependency:
   - Spring Web
   - Spring Boot Starter Mail
   - Spring JDBC
   - Validation (opsional)
4. Buat struktur package:
   - `controller/PoEmailController.java`
   - `service/PoEmailService.java`
   - `repository/PoRepository.java`
   - `config/MailConfig.java` (opsional, kalau perlu custom bean)

## Logic Service (urutan implementasi)

1. Validasi `ponbr`.
2. Query DB `VPURCHASEORDER_new` ambil `CPYEMAIL`, `CPYNAME`.
3. Jika `email` dari request kosong, pakai email DB.
4. Terapkan override email per company (sesuai aturan lama).
5. Build URL report PO PDF:
   - `report_it_po_mobile.jsp?method=print-po-view-pdf...`
6. Download bytes PDF (HTTP client).
7. Compose email HTML + attachment PDF.
8. Kirim SMTP.
9. Return JSON sesuai contract.

## Hal Teknis Penting

- Jangan hardcode credential SMTP di source untuk production.
- Gunakan environment variable / secret manager.
- Tambahkan timeout untuk:
  - download PDF
  - SMTP connect/read/write
- Tambahkan logging per step (`validate`, `query-db`, `download-pdf`, `send-mail`).

## Integrasi dengan Flutter (repo ini)

- File terkait: `lib/src/pages/po/PoHeaderPage.dart`
- Saat backend Spring siap, update base URL endpoint send email ke service baru.
- Jangan ubah contract response agar fallback logic app tidak perlu banyak perubahan.

## Checklist Uji

- [ ] Test endpoint via Postman (success)
- [ ] Test invalid `ponbr` (error 400)
- [ ] Test email kosong dari request + DB kosong (error)
- [ ] Test attachment benar-benar terkirim (bukan hanya link)
- [ ] Test dipanggil dari app Android (button `Send to Email`)

## Catatan Migrasi

- Tahap awal boleh tetap `GET` demi kompatibilitas.
- Tahap lanjut disarankan migrasi ke `POST` JSON body untuk keamanan + maintainability.
