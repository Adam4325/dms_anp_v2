# Design Tab (Soft Orange)

Standar UI tab/form/list untuk layar Flutter DMS ANP.  
Referensi implementasi: **Inventory** (`ListInventoryTransNew.dart`) dan **Tyre** (`FrmServiceTire.dart`).

Jika user menyebut **design_tab.md** / **design tab** → pakai dokumen ini sebagai source of truth sebelum mengubah UI tab.

## Lokasi dokumen

`dms_anp/.cursor/design_tab.md`

## File terkait

| File | Peran |
|------|--------|
| `lib/src/pages/inventory/ListInventoryTransNew.dart` | Referensi utama TabBar + list card modern |
| `lib/src/pages/maintenance/FrmServiceTire.dart` | Referensi TabBar + form shell + helper `softDecoration` / `tireBtnStyle` / `tireAlertDialog` |
| `lib/src/pages/maintenance/FrmServiceRequestOprPM.dart` | Service Request PM — helpers `softDecoration` / `pmBtnStyle` / `pmAlertDialog` / `_pmListCard` |

## Warna tema (wajib)

```dart
final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
final Color lightOrange = Color(0xFFFFF4E6);   // Very light orange
final Color accentOrange = Color(0xFFFFB347);  // Peach orange
final Color darkOrange = Color(0xFFE07B39);    // Darker orange
final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
final Color cardColor = Color(0xFFFFF8F0);     // Light cream
final Color shadowColor = Color(0x20FF8C69);   // Soft orange shadow
```

Jangan pakai `Colors.orange` mentah / biru (`Colors.blue`, `Colors.blueAccent`) untuk aksi utama tab baru.

---

## 1. AppBar + TabBar

```dart
appBar: AppBar(
  backgroundColor: primaryOrange,
  foregroundColor: Colors.white,
  elevation: 2,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    iconSize: 20.0,
    onPressed: () { /* back */ },
  ),
  title: Text('Judul Halaman',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
  bottom: TabBar(
    controller: _tabController,
    isScrollable: true,
    indicatorColor: Colors.white,
    indicatorWeight: 3,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white70,
    labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
    tabs: [
      Tab(icon: Icon(Icons.list, size: 20, color: Colors.white), child: Text('TAB 1')),
      // ...
    ],
  ),
),
```

### Larangan TabBar lama
- Jangan `indicator: BoxDecoration(... Colors.black38)`
- Jangan arrow back tanpa `color: Colors.white`
- Jangkan title hitam di AppBar orange

---

## 2. Form shell (isi tab form)

Outer container seragam antar tab (contoh SERAH TERIMA / OPNAME):

```dart
Container(
  margin: EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: cardColor,
    boxShadow: [
      BoxShadow(color: shadowColor, blurRadius: 10, offset: Offset(0, 4)),
    ],
  ),
  child: SingleChildScrollView(
    child: Column(
      children: [
        // Header bar
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: lightOrange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: primaryOrange, size: 24),
              SizedBox(width: 12),
              Text('Judul Form',
                  style: TextStyle(
                    color: darkOrange,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
        // fields...
      ],
    ),
  ),
)
```

Scaffold body sebaiknya `backgroundColor: backgroundColor`.

---

## 3. Input / TextField / Search

Pakai helper `softDecoration` (atau top-level `tireSearchDecoration` untuk widget di luar State).

```dart
InputDecoration softDecoration({
  String? label,
  String? hint,
  bool readOnly = false,
  Widget? suffixIcon,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryOrange, width: 2),
    ),
  );
}
```

### Aturan field
- `cursorColor: primaryOrange`
- `style: TextStyle(color: Colors.black87, fontSize: 14)`
- Margin field biasanya `EdgeInsets.all(12)`
- **Jangan** `BorderRadius.circular(25)`, fill `black12`, atau `contentPadding: EdgeInsets.all(2)`
- Icon search pakai `color: primaryOrange`

### SmartSelect / dropdown
- Bungkus `Container(margin: EdgeInsets.all(12))`
- Modal boleh rounded; jangan styling biru legacy

---

## 4. Tombol

### Style wajib
- **Font label: putih** + `FontWeight.w600`
- **Tanpa border** (`side: BorderSide.none`)
- **Elevation 0** (atau sangat rendah)
- Radius ~8–10

```dart
ButtonStyle tireBtnStyle(Color bg) {
  return ElevatedButton.styleFrom(
    elevation: 0,
    backgroundColor: bg,
    foregroundColor: Colors.white,
    shadowColor: Colors.transparent,
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}

Widget tireBtnLabel(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
  );
}
```

### Mapping warna aksi

| Aksi | Warna |
|------|--------|
| Primary (Save / Submit / Create / Ok / Approve) | `primaryOrange` |
| Secondary (Update KM / Detail) | `accentOrange` |
| Cancel / Close / Clear | `Colors.grey.shade500` |
| Hapus / Cancel destruktif | `Colors.redAccent` |

### Larangan tombol
- Jangan `TextButton` biru untuk aksi utama form
- Jangan label tanpa `color: Colors.white`
- Jangan outline / border pada ElevatedButton

---

## 5. List Card / Row

**Buang** icon gear (`Icons.settings_applications`).

Pakai card modern (header orange + key/value):

```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
  decoration: BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: accentOrange.withOpacity(0.45)),
    boxShadow: [
      BoxShadow(color: shadowColor, blurRadius: 8, offset: Offset(0, 3)),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // header lightOrange + title darkOrange bold
      // body: _kv(label, value)
      // actions: Row tombol dengan tireBtnStyle
    ],
  ),
)
```

Helper `_kv` menampilkan label kiri / nilai kanan (lihat Inventory / FrmServiceTire).

Jangan Card abu `Color.fromRGBO(230, 232, 238, .9)` + `ListTile` leading gear.

---

## 6. AlertDialog

```dart
AlertDialog tireAlertDialog({
  required String title,
  required Widget content,
  List<Widget> actions = const <Widget>[],
}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: cardColor,
    title: Text(
      title,
      style: TextStyle(color: darkOrange, fontWeight: FontWeight.w600),
    ),
    content: content,
    actions: actions,
  );
}
```

Tombol di `actions`:
- `label: tireBtnLabel('Ok')`
- `style: tireBtnStyle(primaryOrange)` (atau grey/red sesuai peran)

Jangan dialog default putih polos + tombol biru tanpa white label.

---

## 7. Checklist migration tab lama → design_tab

Saat merombak tab:

1. [ ] Warna tema soft orange dipakai
2. [ ] AppBar/TabBar putih (arrow, indicator, label)
3. [ ] Form outer card + header lightOrange
4. [ ] Semua TextField `softDecoration` / setara
5. [ ] Search modal ikut radius 12 (bukan 25)
6. [ ] Semua ElevatedButton: white label, no border
7. [ ] AlertDialog: `tireAlertDialog` + tombol putih
8. [ ] List card modern; gear icon dibuang
9. [ ] Logic bisnis / API **tidak diubah** kecuali diminta

---

## Contoh halaman yang sudah mengikuti

- Inventory list tab: `ListInventoryTransNew.dart`
- Tyre tabs (SERAH TERIMA / OPNAME / LIST TMS / FINISH): `FrmServiceTire.dart`
- Service Request PM tabs (CREATE SR / SERAH TERIMA / OPNAME / FOREMAN / PROSES / QC): `FrmServiceRequestOprPM.dart`

Saat membuat tab baru atau merapikan modul lain, **salin pola dari file di atas** dan patuhi dokumen ini.
