# Design List (Soft Orange)

Standar UI **list dialog** + **list card** DMS ANP.  
Pakai dokumen ini sebagai source of truth sebelum merapikan / bikin list baru.

Parent tema: [design_tab.md](design_tab.md)

Referensi implementasi:
- `lib/src/pages/maintenance/FrmServiceRequestOprPM.dart`
  - Dialog: `_ItemSearchDialog`, `listDataSrOpname`, `pmAlertDialog`
  - Card: `_pmListCard`, `_kv`, `_pmBtn`
- `lib/src/pages/inventory/ListInventoryTransNew.dart` — list card di tab

Jika user bilang **design list** / **rapihkan list** → ikut file ini. Logic/API jangan diubah kecuali diminta.

---

## 1. Warna (wajib, sama design_tab)

```dart
final Color primaryOrange = Color(0xFFFF8C69);
final Color lightOrange = Color(0xFFFFF4E6);
final Color accentOrange = Color(0xFFFFB347);
final Color darkOrange = Color(0xFFE07B39);
final Color backgroundColor = Color(0xFFFFFAF5);
final Color cardColor = Color(0xFFFFF8F0);
final Color shadowColor = Color(0x20FF8C69);
```

---

## 2. Anatomi list dialog

```
┌─────────────────────────────────────┐
│  Title (darkOrange, w700, 16)  [n]  │  ← counter optional
│                                     │
│  [ Search field ........ ] [Search] │  ← Row, button font putih
│                                     │
│  ┌─ card ─────────────────────────┐ │
│  │ header lightOrange             │ │
│  │ label :              value     │ │
│  │ [ Pilih/Add ] [ Close ]        │ │
│  └────────────────────────────────┘ │
│  ...                                │
│                          [ Close ]  │  ← footer dialog, font putih
└─────────────────────────────────────┘
```

Ukuran content: `width: screen`, `height: screen * 0.7`.  
`insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24)`.

### Shell dialog

Pakai `pmAlertDialog` / `tireAlertDialog` — jangan `AlertDialog` default putih + title hitam.

```dart
AlertDialog(
  insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  backgroundColor: cardColor,
  titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
  contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 8),
  actionsPadding: EdgeInsets.fromLTRB(12, 0, 12, 12),
  title: Text(title,
      style: TextStyle(color: darkOrange, fontWeight: FontWeight.w700, fontSize: 16)),
  content: SizedBox(
    width: size.width,
    height: size.height * 0.7,
    child: Column(
      children: [
        // search row
        SizedBox(height: 10),
        Expanded(child: /* ListView atau empty/loading */),
      ],
    ),
  ),
  actions: [
    ElevatedButton.icon(
      icon: Icon(Icons.close, color: Colors.white, size: 16),
      label: pmBtnLabel('Close'),
      style: pmBtnStyle(accentOrange),
      onPressed: () => Navigator.pop(context),
    ),
  ],
);
```

### Search row

```dart
Row(
  children: [
    Expanded(
      child: TextField(
        cursorColor: primaryOrange,
        style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
        textInputAction: TextInputAction.search,
        onSubmitted: (v) => load(v),
        decoration: softDecoration(
          label: 'Partname', // atau VHCID
          hint: 'Cari ...',
          prefixIcon: Icon(Icons.search, color: primaryOrange, size: 20),
        ),
      ),
    ),
    SizedBox(width: 8),
    ElevatedButton(
      onPressed: () => load(controller.text),
      style: pmBtnStyle(primaryOrange),
      child: pmBtnLabel('Search'),
    ),
  ],
)
```

**Jangan:** `SingleChildScrollView` + `ListView` height `MediaQuery.size.height` (nested scroll, list ketutup).  
**Jangan:** suffix icon search.png doang tanpa button Search.

### Loading / empty

| State | UI |
|-------|-----|
| Loading | `Center(CircularProgressIndicator(color: primaryOrange))` |
| Empty | icon `Icons.search_off` 40 + text grey 13, center |

Fetch **di dalam** dialog (`initState` / `addPostFrameCallback` + `setState` lokal).  
Jangan `getList` parent → `Future.delayed` / `Timer(1s)` → `showDialog`. Dialog harus `Stateful` / `StatefulBuilder` supaya list rebuild.

---

## 3. List card

Helper: `_pmListCard` (`compact: true` di dalam dialog).

```
┌────────────────────────────────┐
│  Title ID / Number             │  header lightOrange, text darkOrange w700
├────────────────────────────────┤
│  Label          :      value   │  _kv dense
│  Label          :      value   │
├────────────────────────────────┤
│  [ Primary ]     [ Close ]     │  _pmBtn, font putih
└────────────────────────────────┘
```

```dart
_pmListCard(
  compact: true,
  title: 'SR Number : $id',
  rows: [
    _kv('VHCID', value, dense: true),
    _kv('LOCID', value, dense: true),
  ],
  actions: Row(
    children: [
      _pmBtn(icon: Icons.check_circle_outline, label: 'Pilih', color: primaryOrange, onPressed: onPick),
      SizedBox(width: 8),
      _pmBtn(icon: Icons.close, label: 'Close', color: accentOrange, onPressed: onClose),
    ],
  ),
);
```

### Token card

| | Dialog (`compact: true`) | Tab list |
|--|--------------------------|----------|
| Margin | h 6 / v 3 | h 12 / v 6 |
| Radius | 10 | 14 |
| Header pad | 10,6 | 14,12 |
| Title size | 12 | 14 |
| Body `_kv` | dense 11 | 12 |
| Shadow blur | 4 | 8 |

- Border: `accentOrange.withOpacity(0.45)`
- Fill: `cardColor`
- Header bg: `lightOrange`
- Value kosong tampil `-`

### Larangan card lama

- `Card` + `Color.fromRGBO(230, 232, 238, .9)`
- `ListTile` + `Wrap` + `Divider(height: 0)`
- Icon gear (`Icons.settings_applications`)
- `ElevatedButton` tanpa `foregroundColor: Colors.white` / tanpa `pmBtnLabel`

---

## 4. Tombol di list (wajib font putih)

Setiap `ElevatedButton` di list/dialog:

```dart
ButtonStyle pmBtnStyle(Color bg) {
  return ElevatedButton.styleFrom(
    elevation: 0,
    backgroundColor: bg,
    foregroundColor: Colors.white,
    disabledForegroundColor: Colors.white70,
    shadowColor: Colors.transparent,
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}

Widget pmBtnLabel(String text) {
  return Text(text,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13));
}
```

Icon tombol juga `color: Colors.white`, size 15–16.

| Aksi | Label | Warna | Icon saran |
|------|-------|-------|------------|
| Pilih item | Pilih | `primaryOrange` | `Icons.check_circle_outline` |
| Pilih SR | Add | `primaryOrange` | `Icons.add_circle_outline` |
| Search | Search | `primaryOrange` | — (text only) / `Icons.search` |
| Save / Ok | Save … | `primaryOrange` | `Icons.save` |
| Close kartu / dialog | Close | `accentOrange` | `Icons.close` |
| Cancel destruktif | Cancel | `Colors.grey.shade500` | `Icons.close` |

**Jangan** `Colors.blue` / `Colors.blueAccent` / `Colors.orange` mentah.  
**Jangan** `Text("Pilih")` tanpa `color: Colors.white`.

---

## 5. `_kv` (label : value)

```
Partname     :     OLI MESIN
Type         :     A
```

- Label kiri, `:` tengah, value kanan `FontWeight.w500`
- Label `Colors.grey.shade800`, value `Colors.grey.shade900`
- Dense di dialog: font 11, padding v 0
- Tab: font 12, padding v 2

Tanggal lewat `_fmtDt` → `yyyy-MM-dd HH:mm:ss`. Jangan `.toString()` hasil `DateTime.parse` (keluar `.000`).

---

## 6. Contoh layar acuan

### List Detail Item
- Title: `List Detail Item`
- Search: Partname
- Card title: `Item ID : …`
- Rows: Partname, Type, Merk, ID ACCESS, UOM, ITEM SIZE, VHTID
- Actions: **Pilih** + **Close**
- File: `_ItemSearchDialog` + `_buildDListDetailItem`

### List Detail SR
- Title: `List Detail SR`
- Search: VHCID
- Card title: `SR Number : …`
- Rows: SR DateTime, VHCID, LOCID, DRV. NAME, NOTES
- Actions: **Add** + **Close**
- File: `listDataSrOpname` + `_buildDListDetailOpnameSr`

Dialog konfirmasi setelah Add (`Save Opname ?`) juga `pmAlertDialog` + `pmBtnLabel`.

---

## 7. Checklist list baru / merapikan list lama

1. [ ] Dialog `pmAlertDialog` / setara (cream + title darkOrange)
2. [ ] Content `SizedBox` 0.7 height, `Column` + `Expanded` ListView
3. [ ] Search: `softDecoration` + button **Search** putih
4. [ ] Card `_pmListCard` (bukan Card abu + ListTile)
5. [ ] Rows `_kv` / `_fmtDt`
6. [ ] Semua button `pmBtnStyle` + `pmBtnLabel` (font putih)
7. [ ] Loading / empty state
8. [ ] Fetch + rebuild di dialog (bukan Timer 1 detik)
9. [ ] Logic/API tidak berubah

---

## 8. Mapping helper

| Helper | File | Pakai untuk |
|--------|------|-------------|
| `softDecoration` | State page | TextField / search |
| `pmBtnStyle` / `tireBtnStyle` | State page | Semua ElevatedButton |
| `pmBtnLabel` / `tireBtnLabel` | State page | Label putih |
| `pmAlertDialog` / `tireAlertDialog` | State page | Shell dialog |
| `_pmListCard` | `FrmServiceRequestOprPM.dart` | Kartu list |
| `_kv` | Inventory / Tire / PM | Baris label:value |
| `_pmBtn` | PM | Tombol card Expanded |

Salin helper ke page lain kalau belum ada — jangan mix style biru/abu lama.
