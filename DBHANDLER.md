# DBHandler Transaction Guide

Panduan ini jadi acuan untuk API JSP lama (SAP MaxDB) saat pakai `DbHandler`.

## Prinsip Wajib

- Selalu pakai **1 instance `DbHandler` yang sama** dalam 1 request transaksi.
- Jangan pakai `new DbHandler().getQueryResult(...)` di tengah flow transaksi.
- Selalu `connectDefault()` -> `setAutoCommit(false)` -> proses SQL -> `commit()`.
- Jika error: `rollback()`.
- Selalu `close()` di `finally`.
- Escape input string (`'` jadi `''`) sebelum dirangkai ke SQL.

## Kenapa `new DbHandler().getQueryResult(...)` Dilarang

Pattern ini bikin query jalan di koneksi terpisah, di luar transaksi utama. Efeknya:

- hasil cek bisa tidak konsisten dengan data yang sedang diinsert/update;
- commit/rollback tidak meng-cover query tersebut;
- rawan error koneksi/statement tertutup (`Object is closed`) di environment legacy.

## Template Standar (JSP)

```java
DbHandler db = null;
String lastSql = "";

try {
    db = new DbHandler();
    db.connectDefault();
    db.setAutoCommit(false);

    // SELECT pakai db yang sama
    String sqlCheck = "SELECT COUNT(*) FROM MY_TABLE WHERE ID='123'";
    Vector checkResult = db.getQueryResult(sqlCheck);

    // INSERT/UPDATE pakai db yang sama
    lastSql = "INSERT INTO MY_TABLE(ID, CREATED_DATE) VALUES ('123', NOW())";
    int saved = db.exec(lastSql);
    if (saved <= 0) {
        throw new SQLException("Gagal insert MY_TABLE");
    }

    db.commit();

    // response success
} catch (Exception e) {
    try {
        if (db != null) db.rollback();
    } catch (Exception ignore) {}

    // response error + e.getMessage() + lastSql (opsional debug)
} finally {
    try {
        if (db != null) db.close();
    } catch (Exception ignore) {}
}
```

## Pattern untuk API P2H (yang pakai IMEIID)

Urutan minimum yang direkomendasikan:

1. Parse + validasi payload.
2. `db.connectDefault()` dan `db.setAutoCommit(false)`.
3. Validasi driver (`IMEIID + DRVID`) via `db.getQueryResult(...)` **pakai db yang sama**.
4. Cek header OPEN existing via `db.getQueryResult(...)` **pakai db yang sama**.
5. Generate nomor P2H + update counter number **dalam transaksi yang sama**.
6. Insert header.
7. Insert detail loop.
8. `commit()`.
9. Kalau ada error di step mana pun -> `rollback()`.

## Rekomendasi SQL Timestamp untuk MaxDB Lama

- Prioritaskan `NOW()` atau `CURRENT TIMESTAMP` sesuai engine/version yang stabil di server.
- Jangan campur format tanggal string manual kalau tidak perlu.
- Jika pakai string datetime, pastikan format konsisten (`yyyy-MM-dd HH:mm:ss`) dan quoted benar.

## Checklist Review Sebelum Deploy

- [ ] Tidak ada `new DbHandler().getQueryResult(...)` di dalam flow request.
- [ ] Semua query (select/insert/update) pakai instance `db` yang sama.
- [ ] `setAutoCommit(false)` aktif sebelum query mutasi.
- [ ] Ada `commit()` pada sukses.
- [ ] Ada `rollback()` pada catch.
- [ ] Ada `close()` pada finally.
- [ ] Error response mengembalikan pesan jelas (`status`, `message`, opsional `last_sql`).
