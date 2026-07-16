# DMS ANP Style Guide

## Button Styling Guidelines

### WAJIB: Tombol harus berwarna (bukan transparan)

**JANGAN** pakai tombol text-only / transparan untuk aksi utama di dialog atau list card.
User harus langsung melihat warna solid atau bordered sesuai tema **orange soft**.

```dart
// ❌ SALAH — transparan / text-only
GestureDetector(
  onTap: onTap,
  child: Text('Pilih', style: TextStyle(color: primaryOrange)),
);

// ✅ BENAR — solid fill (aksi dialog & list: Scan / Search / Pilih / Close)
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  decoration: BoxDecoration(
    color: primaryOrange, // atau accentOrange / grey.shade600 untuk Close
    borderRadius: BorderRadius.circular(10),
  ),
  child: Row(children: [
    Icon(Icons.edit, color: Colors.white, size: 16),
    SizedBox(width: 6),
    Text('Pilih', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
  ]),
);
```

**Jangan** pakai bordered-only untuk dialog Scan QRCode / Search By Name — pakai background solid.
### ElevatedButton Color Properties

**ALWAYS USE (Flutter di project ini sering pakai `backgroundColor`):**
```dart
style: ElevatedButton.styleFrom(
  elevation: 2.0,
  backgroundColor: primaryOrange,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
)
```

### Standard Button Colors (Orange Soft)

| Aksi | Warna |
|------|-------|
| Primary (Pilih, Save, Ok, Scan) | `primaryOrange` `#FF8C69` |
| Secondary (Search, Add, Select) | `accentOrange` `#FFB347` |
| Destructive (Delete) | `darkOrange` `#E07B39` |
| Close / Cancel | `Colors.grey.shade600` |
| Soft fill / bordered bg | `lightOrange` `#FFF4E6` |

#### Primary Button (Orange Theme)
```dart
backgroundColor: primaryOrange,
foregroundColor: Colors.white,
```

#### Secondary Button
```dart
backgroundColor: accentOrange,
foregroundColor: Colors.white,
```

#### Error/Cancel Button
```dart
backgroundColor: Colors.grey.shade600, // Close
// atau Colors.red untuk error keras
foregroundColor: Colors.white,
```

### Container Colors

#### Background
```dart
decoration: BoxDecoration(color: Color(0xFFFFFAF5)) // Cream white (orange soft)
```

#### Text and Icons
```dart
color: Color(0xFF253840) // Dark blue-gray
```

#### Borders and Outlines
```dart
color: primaryOrange // untuk bordered button
```

### Opacity Usage
```dart
// Correct opacity syntax
color: Color(0xFF253840).withOpacity(0.12)  // 12% opacity
color: Color(0xFF253840).withOpacity(0.38)  // 38% opacity

// NEVER use this format: Color(0xFF253840)12 ❌
```

## Color Constants

Orange Soft Theme (sumber: `INSTRUCTIONS.md`):
- Primary: `#FF8C69` (`primaryOrange`)
- Accent: `#FFB347` (`accentOrange`)
- Light: `#FFF4E6` (`lightOrange`)
- Dark: `#E07B39` (`darkOrange`)
- Background: `#FFFAF5`
- Card: `#FFF8F0`
- Shadow: `#20FF8C69`

Referensi inventory: `FrmInventory.dart` (Search By Name → Pilih/Close solid), `ListInventoryDetail.dart` (Select/Delete/Close).

---
