# Design Form (Soft Orange)

Standar UI **form / input data / photo upload** untuk layar Flutter DMS ANP.  
Gunakan dokumen ini sebagai *source of truth* saat membuat form baru atau merapikan form lama di DMS ANP.

Parent tema: [design_tab.md](design_tab.md) & [design_list.md](design_list.md)

Referensi implementasi utama:
- `lib/src/pages/hrd/frmAssset.dart` — Form Create & Edit Asset (Material Design 3)

---

## 1. Warna Tema (Wajib)

```dart
final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
final Color lightOrange   = Color(0xFFFFF4E6); // Very light orange
final Color accentOrange  = Color(0xFFFFB347); // Peach orange
final Color darkOrange    = Color(0xFFE07B39); // Darker orange
final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
final Color cardColor     = Color(0xFFFFF8F0); // Light cream
final Color shadowColor   = Color(0x20FF8C69); // Soft orange shadow
final Color borderColor   = Color(0x59FFB347); // accentOrange 35% opacity
```

> **Larangan:** Jangan gunakan warna biru (`Colors.blue`, `Colors.blueAccent`) atau orange mentah (`Colors.orange`) pada AppBar, kartu, dan tombol aksi form.

---

## 2. AppBar Form

Sesuai standar `design_tab.md`, AppBar form wajib menggunakan latar belakang `primaryOrange` dengan teks judul dan ikon navigasi berwarna putih:

```dart
appBar: AppBar(
  backgroundColor: primaryOrange,
  foregroundColor: Colors.white,
  elevation: 2,
  centerTitle: true,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    iconSize: 20.0,
    onPressed: () => _goBack(context),
  ),
  title: Text(
    isEdit ? 'Form Edit Asset' : 'Form Create Asset',
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      tooltip: 'Reset Form',
      onPressed: () => resetTeks(),
    ),
  ],
)
```

### Aturan AppBar Form:
- Background: `primaryOrange`
- Title: `Colors.white`, `fontWeight: FontWeight.w600`, `fontSize: 18`
- Leading icon (Back): `color: Colors.white`, ukuran 20
- Action button (opsional): icon `Colors.white` (misalnya Refresh / Reset)
- **Dilarang:** AppBar putih polos dengan judul hitam atau arrow back abu-abu.

---

## 3. Struktur Form Shell & Section Cards

Form panjang dikelompokkan ke dalam kartu-kartu tematik (*Section Cards*) untuk meningkatkan kenyamanan visual dan kemudahan pengisian data:

```dart
Widget _buildCard({
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
      boxShadow: const [
        BoxShadow(
          color: shadowColor,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Bar Kartu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: lightOrange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: darkOrange,
                ),
              ),
            ],
          ),
        ),
        // Konten Input
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    ),
  );
}
```

---

## 4. Komponen Input Standar

### A. Label & TextField
Setiap input field memiliki label rapi di atas kolom dan tanda bintang merah (`*`) jika wajib diisi:

```dart
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? hint,
  bool isRequired = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          cursorColor: primaryOrange,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint ?? 'Masukkan $label...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: primaryOrange, size: 20),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: primaryOrange, width: 1.8),
            ),
          ),
        ),
      ],
    ),
  );
}
```

### B. SmartSelect / Dropdown Picker
Menggunakan modal bottom sheet dengan tile berbingkai rounded input yang elegan:

```dart
Widget _buildSmartSelect({
  required String title,
  required String placeholder,
  required String selectedValue,
  required List<S2Choice<String>> choicesList,
  required ValueChanged<String> onChanged,
  required IconData icon,
  bool isRequired = false,
}) {
  final hasValue = selectedValue.isNotEmpty;
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        SmartSelect<String>.single(
          title: title,
          placeholder: placeholder,
          selectedValue: selectedValue,
          onChange: (state) => onChanged(state.value),
          choiceType: S2ChoiceType.radios,
          choiceItems: choicesList,
          modalType: S2ModalType.bottomSheet,
          modalHeader: true,
          modalConfig: const S2ModalConfig(
            style: S2ModalStyle(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            ),
          ),
          tileBuilder: (context, state) {
            return InkWell(
              onTap: () => state.showModal(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: primaryOrange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hasValue ? selectedValue : placeholder,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                          color: hasValue ? Colors.black87 : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
```

### C. DateTimePicker
Picker tanggal terbungkus rapi dengan ikon kalender oranye:

```dart
Widget _buildDatePicker({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required ValueChanged<String> onChanged,
  bool isRequired = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: DateTimePicker(
            dateMask: 'yyyy-MM-dd',
            controller: controller,
            firstDate: DateTime(1950),
            lastDate: DateTime(2100),
            icon: Icon(icon, color: primaryOrange, size: 20),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Pilih $label...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (val) => onChanged(val),
            validator: (val) { onChanged(val ?? ''); return null; },
            onSaved: (val) => onChanged(val ?? ''),
          ),
        ),
      ],
    ),
  );
}
```

---

## 5. Kartu Upload Foto & Dokumen

Menampilkan area sentuh dengan ikon kamera untuk unggah, atau menampilkan thumbnail foto dengan aksi **Ganti** dan **Hapus** ketika foto sudah ada:

```dart
Widget _buildPhotoUploadCard({
  required String title,
  required String subtitle,
  required File? imageFile,
  required String pathImage,
  required bool isEdit,
  required VoidCallback onTap,
  required VoidCallback onRemove,
  required String type,
}) {
  final File? localFile = (isEdit && imageFile != null) ? imageFile : null;
  final bool hasLocalFile = localFile != null;
  final bool hasRemoteUrl = !hasLocalFile && pathImage.isNotEmpty;
  final bool hasImage = hasLocalFile || hasRemoteUrl;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: hasImage ? Colors.green.shade400 : borderColor,
        width: hasImage ? 1.5 : 1,
      ),
    ),
    child: hasImage
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: onTap,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text('Ganti', style: TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  InkWell(
                    onTap: onRemove,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text('Hapus', style: TextStyle(color: Colors.red.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: localFile != null
                    ? Image.file(localFile, width: double.infinity, height: 180, fit: BoxFit.cover)
                    : Image.network(
                        "${GlobalData.baseUrlOri}photo/asset/$pathImage",
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                      ),
              ),
            ],
          )
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: lightOrange, shape: BoxShape.circle),
                    child: const Icon(Icons.add_a_photo_outlined, color: primaryOrange, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: darkOrange)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
  );
}
```

---

## 6. Bottom Action Bar Form

Bottom Action Bar tersemat tetap di bagian bawah layar (*fixed bottom navigation bar*), dengan tombol aksi wajib bertuliskan **font putih** dan tanpa border:

```dart
Widget _buildBottomBar(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: cardColor,
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 10,
          offset: Offset(0, -3),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        children: [
          // 1. Tombol Reset / Batal
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
              label: const Text(
                'Reset',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.grey.shade500,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => resetTeks(),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Tombol Simpan / Update (Utama)
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: Icon(
                buttonEvent == "Update" ? Icons.update : Icons.save,
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                buttonEvent == "Update" ? "Update Asset" : "Simpan Asset",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _handleSaveOrUpdate(context),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Tombol Akses Daftar / List
          ElevatedButton.icon(
            icon: const Icon(Icons.list_alt, color: Colors.white, size: 16),
            label: const Text(
              'List',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ListAsset())),
          ),
        ],
      ),
    ),
  );
}
```

---

## 7. Dialog Konfirmasi Standar

Sesuai standar dialog DMS ANP (`pmAlertDialog` / `tireAlertDialog`):
- Background: `cardColor`
- Judul: `darkOrange`, tebal
- Tombol: `ElevatedButton` font putih (`primaryOrange` untuk Simpan, `grey` untuk Batal)

---

## 8. Checklist Pembuatan / Migrasi Form Baru

1. [ ] AppBar form menggunakan `primaryOrange` dengan judul dan icon kembali warna putih (`Colors.white`).
2. [ ] Warna tema palette Soft Orange (`primaryOrange`, `lightOrange`, `cardColor`, `shadowColor`) konsisten.
3. [ ] Field input dikelompokkan ke dalam kartu-kartu tematik berheader `lightOrange`.
4. [ ] Seluruh input menggunakan `OutlineInputBorder` (radius 12), cursor `primaryOrange`, dan label tebal dengan indikator `*` jika wajib.
5. [ ] Bottom action bar terpasang rapi dengan tombol-tombol berfont putih (tanpa border, elevation 0).
6. [ ] Area foto memiliki preview, tombol ganti, dan tombol hapus yang responsif.
7. [ ] Tidak ada dependensi warna biru (`Colors.blue` / `Colors.blueAccent`) lama.
8. [ ] Logic bisnis, HTTP POST API, dan session handling tetap utuh.
