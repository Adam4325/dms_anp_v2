# Query Parameters Convention

Saat membuat atau mengubah request API di Flutter/Dart, gunakan `Uri.replace(queryParameters: ...)` untuk menyusun query string.

Jangan concat query parameter manual pakai string seperti:

```dart
final url = '${GlobalData.baseUrl}api/foo.jsp?method=x&id=$id&name=$name';
```

Gunakan pola ini:

```dart
final uri = Uri.parse('${GlobalData.baseUrl}api/foo.jsp').replace(
  queryParameters: {
    'method': 'x',
    'id': id,
    'name': name,
  },
);
```

Alasan:
- Parameter otomatis di-encode, aman untuk spasi dan karakter khusus.
- Mengurangi risiko URL rusak saat nilai seperti `vhcid`, `reqnbr`, atau `userid` mengandung karakter khusus.
- Lebih mudah dibaca dan di-debug.
