## Null-safety conventions (Dart 3 / Flutter 3)

### 1. SharedPreferences

- **Boleh null (opsional)**:
  - Gunakan `String?`:
    ```dart
    String? vhcid = prefs.getString("vhcidfromdo");
    if (vhcid == null || vhcid.isEmpty) { ... }
    ```
- **Wajib String non-null**:
  - Gunakan default:
    ```dart
    String vhcid = prefs.getString("vhcidfromdo") ?? '';
    ```
  - Atau kalau *dijamin* tidak null di alur tersebut:
    ```dart
    String vhcid = prefs.getString("vhcidfromdo")!;
    ```

### 2. Global nullable state (`globals.*`)

- Contoh: `String? p2hVhcid`, `String? rvhcOil`, dll.
- **Setter dari enum**:
  ```dart
  globals.rvhcOil = rvhcOil?.index.toString();
  ```
- **Pemakaian sebagai nilai non-null**:
  - Selalu cek dulu:
    ```dart
    if (globals.rvhcOil != null) {
      final oil = globals.rvhcOil!;              // safe
      final idx = int.parse(oil);
      ...
    }
    ```

### 3. Enum state di `State` class

- State enum yang bisa “belum dipilih” → **nullable**:
  ```dart
  vhcLampd? rvhcLampd;
  ```
- Saat akses:
  - Untuk kirim ke server → pakai `rvhcLampd?.index` (menghasilkan `int?`).
  - Untuk logika tampilan, cek null dulu:
    ```dart
    if (rvhcLampd?.index == 2) { ... }
    ```

### 4. BuildContext dari GlobalKey

- `GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();`
- Saat dipakai untuk `alert` / `Navigator` dan konteks *harus ada*:
  ```dart
  alert(globalScaffoldKey.currentContext!, 0, "msg", "error");
  Navigator.of(globalScaffoldKey.currentContext!).pop(false);
  ```
- Kalau konteks bisa saja null, gunakan pola aman:
  ```dart
  final ctx = globalScaffoldKey.currentContext;
  if (ctx != null) {
    alert(ctx, 0, "msg", "error");
  }
  ```

### 5. ProgressDialog

- Deklarasi **nullable**:
  ```dart
  ProgressDialog? pr;
  ```
- Inisialisasi di `build` / `initState`:
  ```dart
  pr = ProgressDialog(context, isDismissible: true);
  ```
- Pemakaian:
  ```dart
  await pr?.show();
  if (pr?.isShowing() == true) {
    await pr?.hide();
  }
  ```

### 6. Future return type

- Fungsi yang **selalu** mengembalikan nilai → `Future<String>` dan **jangan** `return null`:
  ```dart
  Future<String> closeDo2(...) async {
    ...
    if (error) return "error";
    return status_code;
  }
  ```
- Kalau memang “boleh tidak ada nilai” → `Future<String?>` dan pemanggil wajib cek null:
  ```dart
  Future<String?> maybeGetToken() async { ... }
  final token = await maybeGetToken();
  if (token != null) { ... }
  ```

### 7. Paginator (`simple_paginator.dart`)

- Semua callback yang menerima data dari paginator → parameter `dynamic`, cast di dalam:
  ```dart
  List<dynamic> listItemsGetter(dynamic data) {
    final model = data as DriverDataModel;
    ...
  }

  Widget errorWidgetMaker(dynamic data, VoidCallback retry) {
    final model = data as DriverDataModel;
    ...
  }
  ```

### 8. Validator & onSaved (Form/Text)

- Gunakan signature null-safety:
  ```dart
  String? Function(String?) validator
  void Function(String?) onSaved
  ```
- Contoh dengan `DateTimePicker`:
  ```dart
  buildDateTimePicker({
    required String labelText,
    required String labelHint,
    required TextEditingController controller,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  })
  ```

### 9. Prinsip umum

- **Gunakan `?`** untuk field yang bisa “belum terisi” (state, global, result API).
- **Gunakan `!`** hanya setelah ada guard jelas:
  - `if (x != null) { final v = x!; ... }`
  - `globalScaffoldKey.currentContext!` saat dipakai di UI callback.
- **Tambahkan `required`** pada parameter konstruktor/fungsi yang:
  - Tidak boleh null
  - Selalu diisi di semua pemanggil.

