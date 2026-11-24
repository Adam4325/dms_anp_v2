# DOKUMENTASI TEKNIS & SPESIFIKASI MODUL HSE INSPEKSI V1
### ECOSYSTEM: ANDROID FLUTTER APPS & WEB ANALYTICS CONTROL DASHBOARD
**Database Engine:** SAP MaxDB  
**Master Tables Existing:** `TBLKARYAWAN (KRYID)`, `TBLDRIVER (DRVID)`, `TBLVEHICLE (VHCID)`  
**Target:** Flutter Engineer, Full-Stack Web Engineer, Grok AI Agent

---

## 1. RINGKASAN SISTEM & ATURAN BISNIS UTAMA

Modul HSE Inspeksi v1 adalah ekosistem keselamatan kerja (K3/P2K3/SHE) terintegrasi yang menggabungkan:
1. **Aplikasi Mobile (Flutter Android):** Alat inspeksi lapangan sidak/random check untuk menemukan ketidaklayakan (*finding*), memicu status **LOCKED**, dan mengunggah bukti perbaikan.
2. **Web Management & Control Dashboard:** Portal kendali terpusat untuk Manajemen, HRD, dan OPR guna memantau KPI keselamatan, eksekusi approval/unlock, analisis tren grafik bar, serta membedah **Top 10 Kejadian Sering Terjadi per Kategori Entitas (Mobil, Driver, Karyawan)**.

---

### 1.1 Matriks Approval & Otoritas Unlock

| Tipe Entitas | Master Table Existing | Kolom PK Master | Input Pencarian | Reviewer Lapangan | Approver (Aktivasi `BP` & Unlock `Active`) | Dampak Saat Status `BP` (`IS_LOCKED = 1`) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **KARYAWAN** | `TBLKARYAWAN` | `KRYID` | ID Karyawan (NIP) | SHE Inspector | **HRD** (*HR & GA Manager*) / **ADMIN** | `KRYSTATUS = 'BP'`, Flagged di HRIS |
| **DRIVER** | `TBLDRIVER` | `DRVID` | ID Driver / No SIM | SHE Inspector | **OPR** (*Manager Operasional*) / **ADMIN** | `DRVSTATUS = 'BP'`, TMS: Diblokir dari Penugasan SPK Trip |
| **MOBIL / TRUCK** | `TBLVEHICLE` | `VHCID` | No Polisi / No Lambung | SHE Inspector | **OPR** (*Manager Operasional*) / **ADMIN** | `VHCSTATUS = 'BP'`, TMS: Diblokir dari Pencetakan Surat Jalan |

---

### 1.2 Siklus Hidup Dokumen (Lifecycle Flow)

```
[1. SHE INSPECTION (MOBILE / WEB)]
        │
        ▼ (Input Temuan + Foto Before ➔ Status: 'OPEN', IS_LOCKED = 0; master DB belum berubah)
[2. APPROVAL AKTIVASI STATUS BP (approve-bp)]
        │
        ├─► Karyawan ➔ Disetujui HRD / ADMIN ➔ TBLKARYAWAN.KRYSTATUS = 'BP'
        └─► Driver & Mobil ➔ Disetujui OPR / ADMIN ➔ TBLDRIVER.DRVSTATUS = 'BP' / TBLVEHICLE.VHCSTATUS = 'BP'
        │
        ▼ (Status: 'BP', IS_LOCKED = 1; entitas tetap muncul di pencarian dengan label BP / LOCKED)
[3. ACTION AFTER (MOBILE / WEB)]
        │
        ▼ (Mekanik / PIC melakukan perbaikan fisik, upload Catatan & Foto After ➔ Status: 'WAITING_SHE')
[4. VERIFIKASI TAHAP 1: TIM SHE]
        │
        ▼ (SHE Setuju ➔ Status: 'WAITING_FINAL')
[5. FINAL APPROVAL & UNLOCK TAHAP 2]
        │
        ├─► Karyawan ➔ Disetujui HRD / ADMIN
        └─► Driver & Mobil ➔ Disetujui OPR / ADMIN
        │
        ▼ (Status: 'COMPLETE', IS_LOCKED = 0 ➔ Master DB dipulihkan menjadi 'Active')
[6. ENTITAS UNLOCKED / KEMBALI BEROPERASI]
```

---

## 2. SPESIFIKASI WEB ANALYTICS & CONTROL DASHBOARD

Portal Web Control Dashboard dirancang untuk pengawasan real-time dan analisis evaluasi berkala P2K3.

### 2.1 Fitur Utama Dashboard
1. **Summary KPI Counter Widgets:**
   - Total Unit/Driver/Karyawan Aktif Ter-Lock (`CURRENTLY LOCKED`).
   - Total Temuan Bulan Berjalan (Open, Waiting Approval, Complete).
   - Metrik Jam Kerja Selamat & Rekap Kasus LTI (*Lost Time Injury*).
2. **Bar Chart Analitik Distribusi:**
   - Tren Pelanggaran Bulanan/Mingguan (Stacked Bar: Mobil vs Driver vs Karyawan).
   - Distribusi Status Penyelesaian Tiket (Open vs In-Progress vs Done).
3. **Top 10 Kejadian Sering Terjadi (Tabbed Filter per Type):**
   - **Tab Mobil:** Top 10 Kerusakan Armada (misal: *APAR Kadaluarsa/Rusak, Ban Botak, Lampu Rem Mati, Kebocoran Oli, Masalah Pengereman*).
   - **Tab Driver:** Top 10 Pelanggaran Pengemudi (misal: *Tidak Memakai APD, Merokok di Kabin/Workshop, Melanggar Batas Kecepatan, Tekanan Darah/Fit Check Gagal*).
   - **Tab Karyawan:** Top 10 Pelanggaran Personel (misal: *Merokok Sembarangan, Tidak Memakai Helm/Sepatu Safety, Indisipliner/Terlambat, 5S Area Kerja Buruk*).
4. **Live Lock Control Table (Action Center):**
   - Menampilkan daftar entitas yang sedang terkunci (`IS_LOCKED = 1`).
   - Tombol cepat aksi: *Review Before vs After Photo*, *Input Review Note*, dan *Approve & Unlock* (sesuai otorisasi login HRD/OPR).

---

## 3. SAP MAXDB DATABASE ARCHITECTURE (DDL & ANALYTICS QUERIES)

### 3.1 DDL Skema Transaksi & Lookup

```sql
-- ============================================================
-- 1. TABEL MASTER KATEGORI TEMUAN / PELANGGARAN
-- ============================================================
CREATE TABLE HSE_MST_VIOLATION_TYPE (
    VIOLATION_ID        VARCHAR(20) PRIMARY KEY,
    ENTITY_TARGET       VARCHAR(15) NOT NULL, -- 'KARYAWAN', 'DRIVER', 'MOBIL'
    CATEGORY_NAME       VARCHAR(100) NOT NULL,
    SEVERITY_LEVEL      VARCHAR(20) DEFAULT 'MEDIUM', -- 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    IS_ACTIVE           SMALLINT DEFAULT 1,
    CONSTRAINT CHK_VIOL_TARGET CHECK (ENTITY_TARGET IN ('KARYAWAN', 'DRIVER', 'MOBIL'))
);

-- ============================================================
-- 2. TABEL TRANSAKSI FINDING & LOCKING
-- ============================================================
CREATE TABLE HSE_TRX_FINDING_LOCK (
    FINDING_NO          VARCHAR(36) PRIMARY KEY, -- Format: FND-YYYYMMDD-XXXX
    ENTITY_TYPE         VARCHAR(15) NOT NULL,    -- 'KARYAWAN', 'DRIVER', 'MOBIL'
    
    -- Relasi ke Master Table Existing
    KRYID               VARCHAR(30),             -- FK ke TBLKARYAWAN(KRYID)
    DRVID               VARCHAR(30),             -- FK ke TBLDRIVER(DRVID)
    VHCID               VARCHAR(30),             -- FK ke TBLVEHICLE(VHCID)
    
    -- Data Temuan Lapangan (Step 3 Mobile)
    INCIDENT_DATE       DATE NOT NULL,
    VIOLATION_CATEGORY  VARCHAR(100) NOT NULL,
    SANCTION_LEVEL      VARCHAR(50) NOT NULL,
    DESCRIPTION         VARCHAR(1500) NOT NULL,
    EVIDENCE_BEFORE_URL VARCHAR(255) NOT NULL,
    DUE_DATE            TIMESTAMP,
    
    -- Workflow Status & Kunci
    STATUS_FLOW         VARCHAR(30) DEFAULT 'OPEN' NOT NULL, -- 'OPEN', 'BP', 'IN_PROGRESS', 'WAITING_SHE', 'WAITING_FINAL', 'COMPLETE', 'REJECTED'
    IS_LOCKED           SMALLINT DEFAULT 0 NOT NULL,          -- 0: Belum BP / Terbuka, 1: BP / Terkunci
    
    -- Tindakan Perbaikan (After Action)
    REPAIR_ACTION_NOTE  VARCHAR(1500),
    EVIDENCE_AFTER_URL  VARCHAR(255),
    REPAIRED_BY         VARCHAR(50),
    REPAIRED_DATE       TIMESTAMP,
    
    -- Approval Level 1: SHE Team
    SHE_VERIFIED        SMALLINT DEFAULT 0,
    SHE_VERIFIED_BY     VARCHAR(50),
    SHE_VERIFIED_DATE   TIMESTAMP,
    SHE_NOTES           VARCHAR(500),
    
    -- Approval Level 2 (Final): Penentu Buka Kunci
    FINAL_APPROVER_ROLE VARCHAR(10) NOT NULL, -- 'HRD' (Karyawan) | 'OPR' (Driver/Mobil)
    FINAL_APPROVED      SMALLINT DEFAULT 0,
    FINAL_APPROVED_BY   VARCHAR(50),
    FINAL_APPROVED_DATE TIMESTAMP,
    FINAL_NOTES         VARCHAR(500),
    
    -- Audit Trail
    CREATED_BY          VARCHAR(50) NOT NULL,
    CREATED_AT          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT CHK_HSE_ENT_TYPE CHECK (ENTITY_TYPE IN ('KARYAWAN', 'DRIVER', 'MOBIL')),
    CONSTRAINT CHK_HSE_ROLE CHECK (FINAL_APPROVER_ROLE IN ('HRD', 'OPR'))
);

CREATE INDEX IDX_HSE_KRY ON HSE_TRX_FINDING_LOCK(KRYID);
CREATE INDEX IDX_HSE_DRV ON HSE_TRX_FINDING_LOCK(DRVID);
CREATE INDEX IDX_HSE_VHC ON HSE_TRX_FINDING_LOCK(VHCID);
CREATE INDEX IDX_HSE_LOCK_STATUS ON HSE_TRX_FINDING_LOCK(STATUS_FLOW, IS_LOCKED);
```

### 3.2 SQL Query untuk Dashboard Web (MaxDB Compatible)

#### A. Query Top 10 Kejadian Sering Terjadi per Tipe Entitas
```sql
-- Ganti parameter :target_type dengan 'MOBIL', 'DRIVER', atau 'KARYAWAN'
SELECT VIOLATION_CATEGORY, COUNT(*) AS TOTAL_INCIDENTS
FROM HSE_TRX_FINDING_LOCK
WHERE ENTITY_TYPE = :target_type
GROUP BY VIOLATION_CATEGORY
ORDER BY TOTAL_INCIDENTS DESC
LIMIT 10;
```

#### B. Query Agregasi Monthly Bar Chart (Insiden per Type)
```sql
SELECT 
    SUBSTR(CHAR(INCIDENT_DATE), 1, 7) AS MONTH_PERIOD,
    ENTITY_TYPE,
    COUNT(*) AS TOTAL_CASES
FROM HSE_TRX_FINDING_LOCK
GROUP BY SUBSTR(CHAR(INCIDENT_DATE), 1, 7), ENTITY_TYPE
ORDER BY MONTH_PERIOD DESC;
```

#### C. Query Live Active Lock (Daftar Terkunci yang Butuh Tindakan)
```sql
SELECT 
    F.FINDING_NO,
    F.ENTITY_TYPE,
    CASE 
        WHEN F.ENTITY_TYPE = 'KARYAWAN' THEN F.KRYID
        WHEN F.ENTITY_TYPE = 'DRIVER' THEN F.DRVID
        ELSE F.VHCID 
    END AS TARGET_ID,
    F.INCIDENT_DATE,
    F.VIOLATION_CATEGORY,
    F.STATUS_FLOW,
    F.FINAL_APPROVER_ROLE
FROM HSE_TRX_FINDING_LOCK F
WHERE F.IS_LOCKED = 1
ORDER BY F.INCIDENT_DATE DESC;
```

> **Hasil Verifikasi SAP MaxDB (`TRUCKING`):** Ketiga query analitik 3.2 (`LIMIT 10` maupun alternatif `TOP 10`, `SUBSTR(CHAR(INCIDENT_DATE), 1, 7)`, serta `CASE WHEN` pada daftar `SELECT`) valid dan berjalan normal di SAP MaxDB. Pada implementasi JDBC `PreparedStatement` (JSP/Java), ganti parameter `:target_type` menjadi `?`.

---

## 4. UNIVERSAL 4-STEP WIZARD (FLUTTER CLIENT)

Alur pada aplikasi Android mencakup 4 langkah universal:
1. **Step 1 - Identifikasi Entitas:** Pilih tab (`Mobil`, `Driver`, `Karyawan`), masukkan ID (`KRYID`, `DRVID`, atau `VHCID`) atau scan barcode/QR.
2. **Step 2 - Preview Validasi:** API mengembalikan kartu ringkasan identitas target (Nama/No Polisi, Divisi/Pool, Foto, Status Lock aktif).
3. **Step 3 - Form Input Temuan:** Tanggal, dropdown kategori temuan, radio sanksi kontekstual, deskripsi, dan foto Before (kamera/galeri).
4. **Step 4 - Output & Lock Record:** Tiket `FINDING_NO` terbit, entitas seketika terkunci (`IS_LOCKED = 1`), masuk antrean dashboard.

---

## 5. PROMPT SIAP PAKAI UNTUK GROK AGENT (BAHASA TINGKAT TINGGI & TERSTRUKTUR)

Gunakan prompt di bawah ini langsung ke Grok Agent untuk menghasilkan implementasi kode lengkap (Flutter + Web Dashboard):

```text
Halo Grok, bertindaklah sebagai Principal Full-Stack Engineer & Database Architect berpengalaman dalam ekosistem Flutter, Modern Web Dashboard (React/Next.js/Tailwind), dan SAP MaxDB.

Konteks Sistem:
Kami sedang membangun Modul HSE Inspeksi & Control System v1 untuk monitoring K3 terpadu pada perusahaan logistik & transportasi. 

Sistem terdiri dari 2 Frontend:
1. Mobile Android (Flutter): Digunakan petugas Safety (SHE) di lapangan untuk sidak inspeksi dengan Universal 4-Step Wizard, serta pengemudi/mekanik untuk input tindakan perbaikan (Action After).
2. Web Management & Control Dashboard: Digunakan oleh Manajemen P2K3, HRD, dan Tim OPR untuk monitoring status lock real-time, approval buka kunci, serta evaluasi tren kecelakaan/pelanggaran.

Spesifikasi Basis Data (SAP MaxDB):
- Tabel Master Existing:
  * TBLKARYAWAN (Primary Key: KRYID)
  * TBLDRIVER (Primary Key: DRVID)
  * TBLVEHICLE (Primary Key: VHCID)
- Tabel Transaksi Baru:
  * HSE_TRX_FINDING_LOCK dengan field: FINDING_NO (PK), ENTITY_TYPE ('KARYAWAN'|'DRIVER'|'MOBIL'), KRYID, DRVID, VHCID, INCIDENT_DATE, VIOLATION_CATEGORY, SANCTION_LEVEL, DESCRIPTION, EVIDENCE_BEFORE_URL, DUE_DATE, STATUS_FLOW, IS_LOCKED (1/0), REPAIR_ACTION_NOTE, EVIDENCE_AFTER_URL, REPAIRED_BY, SHE_VERIFIED, FINAL_APPROVER_ROLE ('HRD'|'OPR'), FINAL_APPROVED, CREATED_BY, CREATED_AT.

Aturan Bisnis Kunci:
1. Pemicu Kunci (System Lock): Setiap temuan baru otomatis menyetel IS_LOCKED = 1.
2. Aturan Dual-Stage Approval Buka Kunci:
   - Verifikasi Lapangan (Level 1) dilakukan oleh SHE Officer.
   - Approval Final (Level 2) yang membuka kunci (IS_LOCKED = 0):
     * Wajib oleh HRD jika ENTITY_TYPE = 'KARYAWAN'
     * Wajib oleh OPR (Manager Operasional) jika ENTITY_TYPE = 'MOBIL' atau 'DRIVER'

Kebutuhan Output yang Harus Anda Bangun:

1. WEB CONTROL DASHBOARD:
   - Layout modern berbasis Tailwind CSS + Chart library (Chart.js / Recharts).
   - Summary Metric Cards: Active Locked Units, Monthly Open Findings, Resolved Rate.
   - Bar Chart Komparasi: Tren jumlah insiden per bulan breakdown per Type (Mobil, Driver, Karyawan).
   - Komponen Top 10 Kejadian Sering Terjadi (Interaktif dengan tab selector: [Mobil] [Driver] [Karyawan]), menampilkan frekuensi kejadian dan tingkat severity.
   - Actionable Control Table: Daftar item yang sedang locked (IS_LOCKED = 1) dengan modal perbandingan foto Before vs After dan tombol "Approve & Unlock" dengan proteksi role guard (HRD vs OPR).

2. FLUTTER ANDROID CLIENT:
   - Universal 4-Step Wizard:
     * Step 1: Input/Scan ID (KRYID / DRVID / VHCID).
     * Step 2: Auto-Preview Entity Card dari REST API.
     * Step 3: Input Pelanggaran (DatePicker, Dropdown Kategori, Radio Sanksi, Kamera Bukti Before).
     * Step 4: Layar Sukses & Penandaan Tiket Terkunci.
   - Clean Architecture State Management (Riverpod / BLoC) yang rapi dan modular.

3. REST API ENDPOINTS & SAP MAXDB SQL:
   - Buatkan endpoint RESTful untuk: Lookup profil entitas, Submit temuan baru, Submit bukti perbaikan, Approval final, dan Agregasi data Top 10 & Chart Bar.
   - Query SQL MaxDB yang dioptimalkan dengan indexing.

Tolong berikan kode yang terstruktur rapi, *clean*, siap pakai, dan memiliki error-handling yang kuat!
```

---

## 6. DOKUMENTASI IMPLEMENTASI AKTUAL (AS-BUILT REFERENCE)

> Bagian ini mencatat struktur **aktual** yang sudah dibangun, di-deploy ke server, dibuat di database SAP MaxDB `TRUCKING`, dan diverifikasi end-to-end agar mudah dijadikan acuan saat pengembangan/perubahan berikutnya (termasuk saat membangun Web Analytics & Control Dashboard).

### 6.1 Lokasi Artefak Implementasi

| Komponen | Lokasi File |
|---|---|
| Script SQL DDL & Seed | `d:\DMS_ANP\trucking-v2\create_tbl_hse_inspeksi.sql` |
| Backend JSP API (sync 2 repo) | `d:\DMS_ANP\trucking\web\mobile\api\hse\hse_api.jsp` & `d:\DMS_ANP\trucking-v2\web\mobile\api\hse\hse_api.jsp` |
| Backend JSP Live Server | `192.168.5.130:/usr/java/apache-tomcat-9.0.120/webapps/trucking/mobile/api/hse/hse_api.jsp` |
| Direktori Upload Foto Server | `/usr/java/apache-tomcat-9.0.120/webapps/trucking/uploads/hse/` |
| Integrasi Menu Dashboard Flutter | `lib/src/pages/ViewDashboard.dart` (`idKey = 43`, icon `verified_user_outlined`) |
| Test API Playwright | `d:\DMS_ANP\e2e-tests\tests\api\hse_inspection.api.spec.ts` |

---

## 7. TABEL DATABASE BARU & INTEGRASI MASTER (SAP MAXDB `TRUCKING`)

Semua struktur di bawah sudah dijalankan dan terverifikasi pada database `TRUCKING` tanpa mengubah struktur kolom tabel master existing.

### 7.1 Tabel Baru 1: `HSE_MST_VIOLATION_TYPE`
Master kategori pelanggaran dinamis per tipe entitas (`KARYAWAN`, `DRIVER`, `MOBIL`).

| Kolom | Tipe Data (MaxDB) | Constraint / Default | Keterangan |
|---|---|---|---|
| `VIOLATION_ID` | `VARCHAR(20)` | `PRIMARY KEY NOT NULL` | Kode kategori (`KRY-01`..`05`, `DRV-01`..`06`, `VHC-01`..`06`) |
| `ENTITY_TARGET` | `VARCHAR(15)` | `NOT NULL`, `CHECK IN ('KARYAWAN','DRIVER','MOBIL')` | Target entitas |
| `CATEGORY_NAME` | `VARCHAR(100)` | `NOT NULL` | Nama kategori pelanggaran |
| `SEVERITY_LEVEL` | `VARCHAR(20)` | `DEFAULT 'MEDIUM'` | Tingkat keparahan (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`) |
| `IS_ACTIVE` | `SMALLINT` | `DEFAULT 1` | `1` aktif, `0` nonaktif |

Seed data default yang sudah terpasang (`17` baris):
- **`KARYAWAN` (5 baris)**: `KRY-01` (Disiplin Waktu & Absensi), `KRY-02` (Tidak Menggunakan APD Lengkap), `KRY-03` (Pelanggaran SOP / Prosedur Kerja Aman), `KRY-04` (Perilaku Tidak Aman (Unsafe Act)), `KRY-05` (Insiden / Near Miss Area Kerja).
- **`DRIVER` (6 baris)**: `DRV-01` (Tidak Menggunakan Sabuk Pengaman / APD), `DRV-02` (Melebihi Batas Kecepatan / Overspeed), `DRV-03` (Penggunaan Ponsel Saat Mengemudi), `DRV-04` (Fatik / Kondisi Tidak Fit Berkendara), `DRV-05` (Dokumen SIM / Administrasi Tidak Lengkap), `DRV-06` (Parkir / Muat Tidak Sesuai Standar Safety).
- **`MOBIL` (6 baris)**: `VHC-01` (Sistem Pengereman Tidak Layak), `VHC-02` (Ban Gundul / Tidak Standar / Baut Kendor), `VHC-03` (APAR / P3K / Safety Kit Tidak Tersedia), `VHC-04` (Lampu Utama / Sein / Rem Mati), `VHC-05` (Kebocoran Oli / Udara / Bahan Bakar), `VHC-06` (Dokumen STNK / KIR Tidak Berlaku).

### 7.2 Tabel Baru 2: `HSE_TRX_FINDING_LOCK`
Tabel utama transaksi temuan inspeksi, perbaikan, verifikasi SHE, dan approval pembuka kunci.

| Kolom | Tipe Data (MaxDB) | Constraint / Default | Keterangan |
|---|---|---|---|
| `FINDING_NO` | `VARCHAR(36)` | `PRIMARY KEY NOT NULL` | Format `FND-YYYYMMDD-XXXX` |
| `ENTITY_TYPE` | `VARCHAR(15)` | `NOT NULL`, `CHECK IN ('KARYAWAN','DRIVER','MOBIL')` | Tipe entitas target |
| `KRYID` | `VARCHAR(30)` | Nullable | ID `TBLKARYAWAN` jika `ENTITY_TYPE='KARYAWAN'` |
| `DRVID` | `VARCHAR(30)` | Nullable | ID `TBLDRIVER` jika `ENTITY_TYPE='DRIVER'` |
| `VHCID` | `VARCHAR(30)` | Nullable | ID `TBLVEHICLE` jika `ENTITY_TYPE='MOBIL'` |
| `INCIDENT_DATE` | `DATE` | `NOT NULL` | Tanggal kejadian |
| `VIOLATION_CATEGORY` | `VARCHAR(100)` | `NOT NULL` | Nama kategori pelanggaran |
| `SANCTION_LEVEL` | `VARCHAR(50)` | `NOT NULL` | Sanksi / tindakan yang dipilih |
| `DESCRIPTION` | `VARCHAR(1500)` | `NOT NULL` | Kronologi / detail pelanggaran |
| `EVIDENCE_BEFORE_URL` | `VARCHAR(255)` | `NOT NULL` | Path relatif foto bukti temuan (`uploads/hse/BEFORE_...jpg`) |
| `DUE_DATE` | `TIMESTAMP` | Nullable | Batas waktu tindak lanjut |
| `STATUS_FLOW` | `VARCHAR(30)` | `DEFAULT 'OPEN' NOT NULL` | Nilai aktual: `OPEN`, `IN_PROGRESS`, `WAITING_SHE`, `WAITING_FINAL`, `COMPLETE`, `REJECTED` |
| `IS_LOCKED` | `SMALLINT` | `DEFAULT 1 NOT NULL` | `1` terkunci, `0` terbuka (`COMPLETE`) |
| `REPAIR_ACTION_NOTE` | `VARCHAR(1500)` | Nullable | Catatan perbaikan lapangan |
| `EVIDENCE_AFTER_URL` | `VARCHAR(255)` | Nullable | Path relatif foto sesudah perbaikan (`uploads/hse/AFTER_...jpg`) |
| `REPAIRED_BY` | `VARCHAR(50)` | Nullable | User penginput Action After |
| `REPAIRED_DATE` | `TIMESTAMP` | Nullable | Waktu input perbaikan |
| `SHE_VERIFIED` | `SMALLINT` | `DEFAULT 0` | `1` disetujui SHE, `0` belum/ditolak |
| `SHE_VERIFIED_BY` | `VARCHAR(50)` | Nullable | User verifikator SHE (`HD`/`ADMIN`) |
| `SHE_VERIFIED_DATE` | `TIMESTAMP` | Nullable | Waktu verifikasi SHE |
| `SHE_NOTES` | `VARCHAR(500)` | Nullable | Catatan verifikasi SHE |
| `FINAL_APPROVER_ROLE` | `VARCHAR(10)` | `NOT NULL`, `CHECK IN ('HRD','OPR')` | Otomatis: `HRD` (`KARYAWAN`) / `OPR` (`DRIVER` & `MOBIL`) |
| `FINAL_APPROVED` | `SMALLINT` | `DEFAULT 0` | `1` disetujui final approver |
| `FINAL_APPROVED_BY` | `VARCHAR(50)` | Nullable | User final approver |
| `FINAL_APPROVED_DATE` | `TIMESTAMP` | Nullable | Waktu final approval |
| `FINAL_NOTES` | `VARCHAR(500)` | Nullable | Catatan final approval |
| `CREATED_BY` | `VARCHAR(50)` | `NOT NULL` | Pembuat temuan (`HD`/`ADMIN`) |
| `CREATED_AT` | `TIMESTAMP` | Nullable (diisi `CURRENT_TIMESTAMP` oleh API) | Waktu pembuatan temuan |

**Index `HSE_TRX_FINDING_LOCK`:**
- `IDX_HSE_KRY` ON `(KRYID)`
- `IDX_HSE_DRV` ON `(DRVID)`
- `IDX_HSE_VHC` ON `(VHCID)`
- `IDX_HSE_LOCK_STATUS` ON `(STATUS_FLOW, IS_LOCKED)`

### 7.3 Registrasi Menu Mobile: `TBL_MOBILE_MENU`
Baris menu baru yang ditambahkan untuk memunculkan menu `HSE` di Dashboard aplikasi Flutter:
- `MENU_ID`: `72` (auto/sequence di DB)
- `MENU_CODE`: `'HSE'`
- `MENU_NAME`: `'HSE'`
- `ID_KEY`: `43`
- `ICON_NAME`: `'verified_user_outlined'`
- `COLOR_HEX`: `'#FF8C69'`
- `ROLE_ACCESS`: `'ADMIN,HD,OP'`
- `ORDER_NO`: `39`
- `IS_ACTIVE`: `'1'`

### 7.4 DDL SQL Aktual yang Dijalankan (`create_tbl_hse_inspeksi.sql`)
```sql
CREATE TABLE HSE_MST_VIOLATION_TYPE (
    VIOLATION_ID        VARCHAR(20) NOT NULL,
    ENTITY_TARGET       VARCHAR(15) NOT NULL,
    CATEGORY_NAME       VARCHAR(100) NOT NULL,
    SEVERITY_LEVEL      VARCHAR(20) DEFAULT 'MEDIUM',
    IS_ACTIVE           SMALLINT DEFAULT 1,
    PRIMARY KEY (VIOLATION_ID),
    CONSTRAINT CHK_VIOL_TARGET CHECK (ENTITY_TARGET IN ('KARYAWAN', 'DRIVER', 'MOBIL'))
);

CREATE TABLE HSE_TRX_FINDING_LOCK (
    FINDING_NO          VARCHAR(36) NOT NULL,
    ENTITY_TYPE         VARCHAR(15) NOT NULL,
    KRYID               VARCHAR(30),
    DRVID               VARCHAR(30),
    VHCID               VARCHAR(30),
    INCIDENT_DATE       DATE NOT NULL,
    VIOLATION_CATEGORY  VARCHAR(100) NOT NULL,
    SANCTION_LEVEL      VARCHAR(50) NOT NULL,
    DESCRIPTION         VARCHAR(1500) NOT NULL,
    EVIDENCE_BEFORE_URL VARCHAR(255) NOT NULL,
    DUE_DATE            TIMESTAMP,
    STATUS_FLOW         VARCHAR(30) DEFAULT 'OPEN' NOT NULL,
    IS_LOCKED           SMALLINT DEFAULT 1 NOT NULL,
    REPAIR_ACTION_NOTE  VARCHAR(1500),
    EVIDENCE_AFTER_URL  VARCHAR(255),
    REPAIRED_BY         VARCHAR(50),
    REPAIRED_DATE       TIMESTAMP,
    SHE_VERIFIED        SMALLINT DEFAULT 0,
    SHE_VERIFIED_BY     VARCHAR(50),
    SHE_VERIFIED_DATE   TIMESTAMP,
    SHE_NOTES           VARCHAR(500),
    FINAL_APPROVER_ROLE VARCHAR(10) NOT NULL,
    FINAL_APPROVED      SMALLINT DEFAULT 0,
    FINAL_APPROVED_BY   VARCHAR(50),
    FINAL_APPROVED_DATE TIMESTAMP,
    FINAL_NOTES         VARCHAR(500),
    CREATED_BY          VARCHAR(50) NOT NULL,
    CREATED_AT          TIMESTAMP,
    PRIMARY KEY (FINDING_NO),
    CONSTRAINT CHK_HSE_ENT_TYPE CHECK (ENTITY_TYPE IN ('KARYAWAN', 'DRIVER', 'MOBIL')),
    CONSTRAINT CHK_HSE_ROLE CHECK (FINAL_APPROVER_ROLE IN ('HRD', 'OPR'))
);

CREATE INDEX IDX_HSE_KRY ON HSE_TRX_FINDING_LOCK (KRYID);
CREATE INDEX IDX_HSE_DRV ON HSE_TRX_FINDING_LOCK (DRVID);
CREATE INDEX IDX_HSE_VHC ON HSE_TRX_FINDING_LOCK (VHCID);
CREATE INDEX IDX_HSE_LOCK_STATUS ON HSE_TRX_FINDING_LOCK (STATUS_FLOW, IS_LOCKED);

INSERT INTO TBL_MOBILE_MENU (
    MENU_CODE, MENU_NAME, ID_KEY, ICON_NAME, COLOR_HEX, ROLE_ACCESS, ORDER_NO, IS_ACTIVE, CREATED_DATETIME, CREATED_USER
) VALUES (
    'HSE', 'HSE', 43, 'verified_user_outlined', '#FF8C69', 'ADMIN,HD,OP', 39, '1', CURRENT_TIMESTAMP, 'ADMIN'
);
```

### 7.5 Relasi & Efek ke Tabel Existing Server
- **Read-Only Lookup/Foto**:
  - `TBLKARYAWAN` (`KRYID`, `KRYNAME`, `DIVISI`, `JABATAN`, `CABANG`, `KRYSTATUS`, `NOTLP`) & `TBLFACEENROLL` (`PHOTO_FILE`)
  - `TBLDRIVER` (`DRVID`, `DRVNAME`, `DRVNICKNAME`, `DRVLICENSENBR`, `DRVLICENSETYPE`, `CABANG`, `VEHICLETYPE`, `DRVSTATUS`, `PHONE`) & `TBLPHOTODRIVER` (`PHOTO_DRIVER`)
  - `TBLVEHICLE` (`VHCID`, `VHCNOPOL`, `VHCTYPE`, `VHCMANUFACTURER`, `LOCID`, `VHCDFLTLOCID`, `VHCDEFAULTDRIVER`, `VHCSTATUS`, `STATUS`) & `TBLPHOTOVEHICLE` (`PHOTO_STNK`, `PHOTO_KIR`)
  - `TBLSCREENUSER` (`SUBSTR(SCNID, 1, 2)` berdasarkan `UPPER(USRUSERID)`) untuk verifikasi role di backend JSP.
- **Update Status Pelanggaran Otomatis (Approval `BP` & Unlock `Active`)**:
  - **Saat `create-finding` (`OPEN`)**: hanya menyimpan tiket temuan dengan `STATUS_FLOW = 'OPEN'`, `IS_LOCKED = 0`. Status tabel master (`KRYSTATUS`, `DRVSTATUS`, `VHCSTATUS`) belum berubah.
  - **Saat `approve-bp` (`APPROVED` dari `OPEN`)**: tiket berubah menjadi `STATUS_FLOW = 'BP'`, `IS_LOCKED = 1`, dan tabel master otomatis diset menjadi `'BP'`:
    - `KARYAWAN`: `UPDATE TBLKARYAWAN SET KRYSTATUS = 'BP' WHERE KRYID = ?`
    - `DRIVER`: `UPDATE TBLDRIVER SET DRVSTATUS = 'BP' WHERE DRVID = ?`
    - `MOBIL`: `UPDATE TBLVEHICLE SET VHCSTATUS = 'BP' WHERE VHCID = ?`
  - **Pencarian saat status `BP`:** Entitas dengan `KRYSTATUS`/`DRVSTATUS`/`VHCSTATUS = 'BP'` (maupun `'BLOCKED'`) tetap ditampilkan di hasil `search-entities` & `lookup` dengan `is_locked = true` dan label status `'BP'`.
  - **Saat `final-approve` (`APPROVED` Unlock dari `WAITING_FINAL`)**: jika `COUNT(*) WHERE IS_LOCKED = 1` untuk target tersebut sudah `0` (tidak ada temuan aktif lain), maka `TBLKARYAWAN.KRYSTATUS`, `TBLDRIVER.DRVSTATUS`, atau `TBLVEHICLE.VHCSTATUS` (`WHERE UPPER(...) IN ('BP','BLOCKED')`) dikembalikan menjadi `'Active'`.

---

## 8. ATURAN ROLE & KONTRAK BACKEND JSP (`hse_api.jsp`)

### 8.1 Aturan Role Akses
Penentuan akses dilakukan di frontend (`HseMainPage` pada `lib/features/hse_inspection/presentation/pages/hse_main_page.dart` dan `ViewDashboard.dart`) serta diverifikasi ulang oleh server di `resolveUserRoles()` (`hse_api.jsp`):

| Role (`TBLSCREENUSER`) | Tampilan Menu Dashboard | Tab di Halaman HSE | Buat Temuan (`create-finding`) | Input Perbaikan (`submit-repair`) & Verifikasi SHE (`verify-she`) | Approve BP (`approve-bp`) & Final Unlock (`final-approve`) |
|---|---|---|---|---|---|
| `ADMIN` | Muncul (`HSE`) | `Buat Temuan` & `Daftar & Approval` | Ya | Ya | Semua Entitas (`KARYAWAN`, `DRIVER`, `MOBIL`) |
| `HD` (HRD) | Muncul (`HSE`) | `Buat Temuan` & `Daftar & Approval` | Ya | Ya | `KARYAWAN` (`FINAL_APPROVER_ROLE = 'HRD'`) |
| `OP` (OPR) | Muncul (`HSE`) | `HSE - Approval OPR` saja (tanpa `Buat Temuan`) | Tidak (`403`) | Tidak (`403`) | `DRIVER` & `MOBIL` (`FINAL_APPROVER_ROLE = 'OPR'`) |
| Role Lainnya | Disembunyikan | Diblokir | Tidak (`403`) | Tidak (`403`) | Tidak (`403`) |

### 8.2 Daftar Endpoint Aktual (`mobile/api/hse/hse_api.jsp`)
Base endpoint: `${GlobalData.baseUrl}api/hse/hse_api.jsp` (mendukung GET query parameter maupun POST form / JSON body dengan parameter `method`):

| `method` | HTTP | Role Wajib | Parameter Utama | Fungsi & Transisi DB |
|---|---|---|---|---|
| `violation-types` | GET | Publik / Menu | `entity_type` (opsional) | Ambil daftar `HSE_MST_VIOLATION_TYPE WHERE IS_ACTIVE = 1` |
| `search-entities` | GET | Menu | `type` (`KARYAWAN`/`DRIVER`/`MOBIL`), `q` | Cari maksimal 25 entitas (termasuk entitas berstatus `'BP'`) beserta `status_master`, `is_locked` & `active_lock_ticket`. Untuk `DRIVER`, format subtitle diawali `DRVID: <id> \| SIM: <sim>`. |
| `lookup` | GET | Menu | `type`, `id` | Lookup detail target (+ fallback compact Nopol untuk `MOBIL`, mis. `B9001KIN` -> `B 9001 KIN`) |
| `create-finding` | POST | `HD` / `ADMIN` | `username`, `entity_type`, `entity_id`, `incident_date`, `violation_category`, `sanction_level`, `description`, `evidence_before` (Base64), `due_date` | Simpan foto `BEFORE_*.jpg`, insert `HSE_TRX_FINDING_LOCK` (`STATUS_FLOW='OPEN'`, `IS_LOCKED=0`); status master DB tetap tidak berubah sampai di-approve menjadi `BP`. |
| `approve-bp` | POST | `HRD`/`ADMIN` (Karyawan) atau `OP`/`ADMIN` (Driver/Mobil) | `username`, `finding_no`, `status` (`APPROVED`/`REJECTED`), `notes` | Valid saat `STATUS_FLOW='OPEN'`; `APPROVED` -> `STATUS_FLOW='BP'`, `IS_LOCKED=1` & set `KRYSTATUS`/`DRVSTATUS`/`VHCSTATUS` = `'BP'`. `REJECTED` -> `REJECTED` (`IS_LOCKED=0`). |
| `list-findings` | GET | `ADMIN` / `HD` / `OP` | `username`, `status_flow` (`ACTIVE`/`ALL`/`LOCKED`/`OPEN`/`BP`/`WAITING_SHE`/`WAITING_FINAL`/`COMPLETE`/`REJECTED`), `entity_type`, `q` | Ambil list temuan + `summary` (`total_open`, `total_bp`, dll.) + flag hak aksi (`can_approve_bp`, `can_repair`, `can_verify_she`, `can_final_approve`) |
| `detail-finding` | GET | `ADMIN` / `HD` / `OP` | `username`, `finding_no` | Ambil detail lengkap 1 tiket beserta foto & riwayat approval |
| `submit-repair` | POST | `HD` / `ADMIN` | `username`, `finding_no`, `repair_action_note`, `evidence_after` (Base64) | Valid saat `STATUS_FLOW` `BP`/`IN_PROGRESS`/`REJECTED` (`IS_LOCKED=1`); simpan foto `AFTER_*.jpg` -> `STATUS_FLOW = 'WAITING_SHE'` |
| `verify-she` | POST | `HD` / `ADMIN` | `username`, `finding_no`, `status` (`APPROVED`/`REJECTED`), `notes` | Valid saat `WAITING_SHE`; `APPROVED` -> `WAITING_FINAL`, `REJECTED` -> `REJECTED` (tetap `IS_LOCKED=1` / `BP`) |
| `final-approve` | POST | `HRD`/`ADMIN` (Karyawan) atau `OP`/`ADMIN` (Driver/Mobil) | `username`, `finding_no`, `status` (`APPROVED`/`REJECTED`), `notes` | Saat `OPEN`: mendelegasikan ke `approve-bp`. Saat `WAITING_FINAL`: `APPROVED` -> `STATUS_FLOW='COMPLETE'`, `IS_LOCKED=0`, memulihkan `KRYSTATUS`/`DRVSTATUS`/`VHCSTATUS` ke `'Active'` jika tidak ada lock lain. |

> **Catatan SAP MaxDB SQL:** Query pada `hse_api.jsp` sengaja **tidak menggunakan** `COALESCE(...)` (SAP MaxDB error `-4023`) dan **tidak memakai** `CASE WHEN` di dalam klausa `ORDER BY`. Pastikan aturan ini tetap dijaga bila mengedit query JSP atau menambahkan query Web Dashboard di kemudian hari.

---

## 9. STRUKTUR FILE FLUTTER AKTUAL (`dms_anp`)

```text
lib/features/hse_inspection/
├── data/
│   ├── datasources/
│   │   └── hse_remote_datasource.dart   # Koneksi ke hse_api.jsp
│   └── models/
│       └── hse_models.dart              # HseEntityType, ViolationTypeModel, EntityPreviewModel,
│                                        # FindingSubmissionModel, HseFindingItem, HseSummaryModel
├── domain/
│   └── repositories/
│       └── hse_repository.dart          # Kontrak HseRepository
└── presentation/
    ├── controllers/
    │   └── hse_wizard_notifier.dart     # State 4-step wizard + _disposed guard notifyListeners()
    ├── pages/
    │   ├── hse_main_page.dart           # Entry point & pemisahan UI HD/ADMIN (2 tab) vs OP (approval-only)
    │   ├── hse_wizard_page.dart         # Wrapper Wizard Step 1..4
    │   ├── hse_approval_dashboard_page.dart # List, filter status/entitas, KPI summary counters
    │   └── hse_finding_detail_page.dart # Detail temuan + _RepairSheetDialog & _ApprovalDecisionDialog
    └── widgets/
        ├── hse_theme.dart               # Palet soft pastel orange, badge status, image preview dialog
        ├── entity_search_step.dart      # Step 1 (pilih tipe, search/autocomplete, barcode scanner)
        ├── entity_preview_step.dart     # Step 2 (preview profil & status lock / master DB)
        ├── finding_form_step.dart       # Step 3 (tanggal, kategori, sanksi, due date, kamera/galeri)
        └── submission_success_step.dart # Step 4 (konfirmasi tiket FND-* terkunci)
```

Integrasi pada `lib/src/pages/ViewDashboard.dart`:
- `_resolveMenuIcon`: mapping `'verified_user_outlined'` -> `Icons.verified_user_outlined`.
- Guard role akses menu `idKey == 43`: hanya ditambahkan untuk `_isAdminUser || getAkses("HD") || getAkses("OP")` (role lain dihapus via `_anpServiceList.removeWhere`).
- Tap handler `anpService.idKey == 43`: navigasi ke `HseMainPage(initialRoles: rawRoles)`.

---

## 10. MODUL WEB JSP ANALYTICS & LOCK CONTROL DASHBOARD

Portal Web Kontrol & Analitik HSE terintegrasi dengan ERP Trucking (`/trucking/`), memakai autentikasi session web (`session.getAttribute("USERID")`) dan proxy session API sehingga seluruh otoritas role diverifikasi di server.

### 10.1 File & Endpoint Web JSP (`trucking/web` & `trucking-v2/web`)
| File | Path URL | Fungsi |
|---|---|---|
| `dashboard_hse.jsp` | `/trucking/dashboard_hse.jsp` | Dashboard eksekutif HSE: 4 KPI cards (Active Locked, Monthly Findings, Resolution Rate, Safety/Critical Tracker), stacked bar chart bulanan + status/severity breakdown (`Chart.js v4` + fallback offline DOM), Top 10 Pelanggaran interaktif (tab Semua/Mobil/Driver/Karyawan), Live Lock Control table, Modal 4-Step Wizard (`HD`/`ADMIN`), Modal perbandingan foto Before vs After + Approval/Unlock, & Lightbox zoom |
| `hse/index.jsp` | `/trucking/hse/` | Entry redirect ke `../dashboard_hse.jsp` |
| `hse/hse_web_api.jsp` | `/trucking/hse/hse_web_api.jsp` | Session bridge ERP Web: memverifikasi `session.getAttribute("USERID")` (mengembalikan HTTP `401` JSON jika belum login), meneruskan `HSE_WEB_SESSION_USER` ke `hse_api.jsp` (mencegah spoofing parameter `username`) |
| `mobile/api/hse/hse_api.jsp` | `/trucking/mobile/api/hse/hse_api.jsp` | Ditambahkan method `approve-bp` (`OPEN` -> `BP`, update `KRYSTATUS`/`DRVSTATUS`/`VHCSTATUS` = `'BP'`), `start-progress` (`BP`/`REJECTED` terkunci -> `IN_PROGRESS`), `web-analytics` (KPI termasuk `total_bp`/`monthly_bp`, tren bulanan, distribusi status & severity, Top 10 `LIMIT 10`, & roles), serta filter `ACTIVE`, `BP`, `BP_GROUP`, `month`, dan `category` pada `list-findings` |
| `templates/global-new.jsp` | Sidebar Portal ERP | Menambahkan tautan `dashboard_hse.jsp` pada grup **Operation (Out)** (`OP1`), **Monitoring** (`MO2`), dan **Hrd&GA** (`HD4`) |

---

## 11. PANDUAN PERUBAHAN & VERIFIKASI KE DEPAN

Bila nanti ada modifikasi fitur HSE, ikuti checklist berikut agar sinkron di semua layer:
1. **Perubahan kolom / kategori DB**: perbarui `d:\DMS_ANP\trucking-v2\create_tbl_hse_inspeksi.sql` lalu jalankan DDL/DML ke database SAP MaxDB `TRUCKING`.
2. **Perubahan Web & API JSP**: edit dan sinkronkan kedua salinan (`d:\DMS_ANP\trucking\web\` dan `d:\DMS_ANP\trucking-v2\web\`) untuk `mobile/api/hse/hse_api.jsp`, `hse/hse_web_api.jsp`, `hse/index.jsp`, `dashboard_hse.jsp`, dan `templates/global-new.jsp`, lalu deploy ke `192.168.5.130:/usr/java/apache-tomcat-9.0.120/webapps/trucking/` (**jangan restart Tomcat** kecuali diminta).
3. **Perubahan UI / Model Flutter**: sesuaikan file di `lib/features/hse_inspection/`, lalu jalankan `flutter analyze lib/features/hse_inspection`.
4. **Verifikasi Otomatis**: jalankan `npx playwright test tests/api/hse_inspection.api.spec.ts` di folder `d:\DMS_ANP\e2e-tests`.
