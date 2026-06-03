# Menu Badge NEW

Dokumentasi badge **NEW** pada item menu dashboard DMS ANP.

## Ringkasan

Menu baru bisa menampilkan badge hijau **NEW** di pojok kiri atas ikon menu. Badge hilang otomatis setelah **30 hari** sejak tanggal rilis menu.

## File terkait

| File | Peran |
|------|--------|
| `lib/src/Helper/AnpService.dart` | Field `badgeNewSince`, getter `showNewBadge`, konstanta `newBadgeVisibleDays` |
| `lib/src/pages/ViewDashboard.dart` | `_buildNewMenuBadge()`, tampilan di `_buildMenuCard` & `_buildAdditionalMenuCard` |

## Cara menambah badge ke menu baru

Di `ViewDashboard.dart`, saat `add` menu ke `_anpServiceList`:

```dart
_anpServiceList.add(AnpService(
  image: Icons.receipt_long,
  color: Colors.deepPurple,
  idKey: 36,
  title: "PB",
  badgeNewSince: DateTime(2026, 6, 3), // tanggal rilis menu
));
```

- **`badgeNewSince`** — wajib diisi jika ingin badge NEW; isi tanggal menu pertama kali dirilis/deploy.
- **Tanpa `badgeNewSince`** — menu tampil normal (tanpa badge), seperti menu lama.

## Durasi badge

Default: **30 hari** (`AnpService.newBadgeVisibleDays`).

Logika di `showNewBadge`:

```dart
days = DateTime.now().difference(badgeNewSince).inDays
tampilkan NEW jika: days >= 0 && days < 30
```

Contoh: `badgeNewSince: DateTime(2026, 6, 3)` → badge hilang mulai **4 Juli 2026** (hari ke-30).

## Ubah durasi (opsional)

Edit di `lib/src/Helper/AnpService.dart`:

```dart
static const int newBadgeVisibleDays = 30;
```

## Contoh menu yang sudah pakai badge

| Menu | idKey | badgeNewSince |
|------|-------|----------------|
| PB | 36 | `DateTime(2026, 6, 3)` |

## Catatan UI

- Badge tampil di **Menu Utama** (grid) dan **Menu Tambahan** (modal More).
- Posisi: kiri atas ikon (`Positioned left: -8, top: -8`).
- Tidak bentrok dengan badge notifikasi Aduan (kanan atas, idKey 35) atau badge jumlah menu More.
