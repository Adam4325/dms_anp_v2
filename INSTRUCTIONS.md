# DMS ANP Flutter Project - Development Instructions

## 📋 Project Overview
**DMS ANP** (Driver Management System - Andalan Nusa Pratama) is a Flutter mobile application for trucking fleet management. The app integrates with a Java 6 JSP backend API hosted at `https://apps.tuluatas.com/trucking/mobile/api`.
- Belum compatible require, nullSafety dan !
- Tidak Perlu Update SDK dart, Flutter ataupun Gradle gunakan yang ada , karna masih pake dart lama
## 🚨 Critical Migration Requirements

### 1. Flutter SDK Compatibility
- **Current SDK**: `>=2.7.0 <3.0.0` (Legacy)
- **Target SDK**: `>=3.0.0 <4.0.0` (Recommended)
- **Migration Priority**: HIGH

### 2. Null Safety Migration
The project currently uses **legacy Dart syntax** and needs complete null safety migration:

#### Before (Legacy Code):
```dart
String drvid;  // Non-nullable without initialization
Widget build(BuildContext context) {  // No return type
  return Container();
}
```

#### After (Null Safety):
```dart
String drvid = '';  // Non-nullable with initialization (NO nullable types)
Widget build(BuildContext context) {  // Explicit return type
  return Container();
}
```

#### Required Changes:
- **NO nullable types** - Use `String drvid = ''` instead of `String? drvid`
- **NO `!` operator** - Use direct variable access: `drvid` instead of `drvid!`
- **NO `required` keyword** - Use direct parameter access: `drvid` instead of `required drvid`
- Initialize non-nullable variables with default values
- Add explicit return types to functions
- Replace `var` with explicit types where possible

### 3. Theme System Migration

#### Current Theme Issues:
- Uses deprecated `primarySwatch`
- Missing `primary` and `onPrimary` color definitions
- Inconsistent color usage

### Warna Gunakan ini
  // Soft Orange Pastel Theme Colors
  - final Color primaryOrange = Color(0xFFFF8C69); // Soft orange
  - final Color lightOrange = Color(0xFFFFF4E6); // Very light orange
  - final Color accentOrange = Color(0xFFFFB347); // Peach orange
  - final Color darkOrange = Color(0xFFE07B39); // Darker orange
  - final Color backgroundColor = Color(0xFFFFFAF5); // Cream white
  - final Color cardColor = Color(0xFFFFF8F0); // Light cream
  - final Color shadowColor = Color(0x20FF8C69); // Soft orange shadow

#### Required Theme Updates:
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.orange,  // Primary orange color
    primary: Colors.orange,
    onPrimary: Colors.white,
    secondary: Colors.orangeAccent,
    onSecondary: Colors.white,
    background: Colors.grey[50],
    onBackground: Colors.black87,
    surface: Colors.white,
    onSurface: Colors.black87,
  ),
  // Remove primarySwatch usage
)
```

## 🎨 Color Scheme Requirements

### Primary Color: Orange Theme
Replace the current red-based color scheme with orange:

#### Update `lib/src/Color/color_constants.dart`:
```dart
class ColorConstants {
  // Primary Colors - Orange Theme
  static const kPrimaryColor = Color(0xFFFF9800);  // Orange 500
  static const kPrimaryLightColor = Color(0xFFFFB74D);  // Orange 300
  static const kPrimaryDarkColor = Color(0xFFF57C00);  // Orange 700
  
  // Background Colors
  static const kScreebBackColor = Color(0XFFF7F7F7);
  static const kHomeScreenBackColor = Color(0xFFF9F9F9);
  
  // Text Colors
  static const kTextColor = Color(0XFF262E3A);
  static const kHintTextColor = Color(0xFFB2B2B2);
  static const kGreyTextColor = Color(0xFF707070);
  
  // Status Colors
  static const kGreenTextColor = Color(0xFF87B821);
  static const kDeliveredOrderColor = Color(0xFF03CC03);
  static const kOngoingOrderColor = Color(0xFFFF9800);  // Orange for ongoing
  
  // UI Element Colors
  static const ktextFieldBorderColor = Color(0xFFE3E3E3);
  static const kCardBackColor = Color(0xFF1F1F1F1A);
  static const kDividerColor = Color(0xFFEFEFEF);
  
  // Utility Colors
  static const kWhiteColor = Colors.white;
  static const kBlackColor = Colors.black;
  static const kGreyColor = Colors.grey;
  static const kOrangeColor = Colors.orange;
  static const kBlueColor = Colors.blue;
  static const kRedColor = Colors.red;
  static const kGreenColor = Colors.green;
}
```

### Theme Integration
Update `lib/src/Theme/app_theme.dart` to use the new color scheme:

```dart
class AppTheme {
  AppTheme._();
  
  // Primary Colors
  static const Color primary = Color(0xFFFF9800);  // Orange 500
  static const Color primaryLight = Color(0xFFFFB74D);  // Orange 300
  static const Color primaryDark = Color(0xFFF57C00);  // Orange 700
  static const Color onPrimary = Color(0xFFFFFFFF);  // White
  
  // Background Colors
  static const Color background = Color(0xFFF2F3F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF253840);
  static const Color onSurface = Color(0xFF253840);
  
  // Text Colors
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  
  // Utility Colors
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);
  static const Color spacer = Color(0xFFF2F2F2);
  
  static const String fontName = 'NeoSans';  // Use project font
  
  // ... rest of the theme definitions
}
```

## 🔌 API Integration

### Backend API Details
- **Base URL**: `https://apps.tuluatas.com/trucking/mobile/api`
- **Technology**: Java 6 JSP
- **Authentication**: Session-based (likely)

### API Service Updates
Update `lib/src/Helper/AnpService.dart`:

```dart
class AnpService {
  static const String baseUrl = 'https://apps.tuluatas.com/trucking/mobile/api';
  
  // Add proper error handling and null safety
  static Future<Map<String, dynamic>> apiCall({
    String endpoint = '',
    Map<String, dynamic> data = const {},
    String method = 'POST',
  }) async {
    try {
      final dio = Dio();
      final response = await dio.request(
        '$baseUrl$endpoint',
        data: data,
        options: Options(method: method),
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      return <String, dynamic>{};
    }
  }
}
```

## 📱 UI Component Updates

### Background Color Usage
Replace direct color usage with theme-based colors:

#### Before:
```dart
Container(
  color: Colors.blue,  // Direct color
  child: Text('Hello'),
)
```

#### After:
```dart
Container(
  color: Theme.of(context).colorScheme.primary,  // Theme-based
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)
```

### Common Widget Updates
```dart
// AppBar with orange theme
AppBar(
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Theme.of(context).colorScheme.onPrimary,
  title: Text('DMS ANP'),
)

// ElevatedButton with orange theme
ElevatedButton(
  style: ElevatedButton.styleFrom(
    primary: Theme.of(context).colorScheme.primary,
    onPrimary: Theme.of(context).colorScheme.onPrimary,
  ),
  onPressed: () {},
  child: Text('Submit'),
)
```

## 🔧 Migration Steps

### Step 1: Update Dependencies
```yaml
# pubspec.yaml
environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  # Update all dependencies to null-safe versions
  dio: ^5.0.0
  shared_preferences: ^2.2.0
  # ... other dependencies
```

### Step 2: Enable Null Safety
```bash
# Run migration tool
dart migrate --apply

# Fix remaining issues manually
flutter analyze
```

### Step 3: Update Theme
1. Replace `primarySwatch` with `colorScheme`
2. Update all color constants to orange theme
3. Replace direct color usage with theme-based colors

### Step 4: Test API Integration
1. Verify all API endpoints work with the new backend
2. Test authentication flow
3. Validate data parsing with null safety

## 🚀 Build and Deploy

### Android Build
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS Build
```bash
# Build for iOS
flutter build ios --release
```

## 📝 Code Style Guidelines

### Null Safety Best Practices
```dart
// ✅ Good - Non-nullable with initialization
String drvid = '';
String name = '';
int count = 0;

// ❌ Bad - Don't use nullable types
String? nullableString;  // NOT ALLOWED

// ❌ Bad - Don't use ! operator
String result = nullableString!;  // NOT ALLOWED

// ❌ Bad - Don't use required keyword
Widget build({required String title}) {  // NOT ALLOWED

// ✅ Good - Direct parameter access
Widget build({String title = ''}) {
  return Container();
}

// ✅ Good - Explicit return type
Widget build(BuildContext context) {
  return Container();
}

// ❌ Bad - Missing return type
build(BuildContext context) {  // Will cause error
  return Container();
}
```

### Theme Usage
```dart
// ✅ Good - Use theme colors
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Text',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)

// ✅ Good - Button styling
ElevatedButton(
  style: ElevatedButton.styleFrom(
    primary: Theme.of(context).colorScheme.primary,
    onPrimary: Theme.of(context).colorScheme.onPrimary,
  ),
  onPressed: () {},
  child: Text('Button'),
)

// ❌ Bad - Direct color usage
Container(
  color: Colors.orange,
  child: Text('Text'),
)
```

## 📝 TextField & Button Implementation Guidelines

### ✅ **Standard TextField Pattern (SUDAH DITERAPKAN dengan BENAR)**

Berdasarkan analisis `RegistrasiNewDriver.dart`, berikut adalah pattern TextField yang sudah SESUAI dan harus diikuti:

#### **Custom buildTextField Method:**
```dart
Widget buildTextField({
  String labelText,
  TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  bool readOnly = false,
  Widget suffixIcon,
}) {
  return Container(
    margin: EdgeInsets.all(12.0),
    child: TextField(
      readOnly: readOnly,
      cursorColor: primaryOrange,                    // ✅ Orange cursor
      style: TextStyle(color: Colors.black87, fontSize: 14),
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        fillColor: Colors.white,                     // ✅ White background
        filled: true,
        isDense: true,
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),   // ✅ Modern radius
          borderSide: BorderSide(color: Colors.grey[300], width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300], width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryOrange, width: 2),  // ✅ Orange focus
        ),
      ),
    ),
  );
}
```

#### **Orange Theme Colors (SUDAH BENAR):**
```dart
// Orange Soft Theme Colors - GUNAKAN YANG INI
final Color primaryOrange = Color(0xFFFF8C69);      // Soft orange
final Color lightOrange = Color(0xFFFFF4E6);        // Very light orange
final Color accentOrange = Color(0xFFFFB347);       // Peach orange
final Color darkOrange = Color(0xFFE07B39);         // Darker orange
final Color backgroundColor = Color(0xFFFFFAF5);     // Cream white
final Color cardColor = Color(0xFFFFF8F0);          // Light cream
final Color shadowColor = Color(0x20FF8C69);        // Soft orange shadow
```

#### **Penggunaan TextField:**
```dart
// ✅ BENAR - Menggunakan buildTextField
buildTextField(
  labelText: "Nama Pengemudi",
  controller: txtDriverName,
),

buildTextField(
  labelText: "Email",
  controller: txtEmail,
  keyboardType: TextInputType.emailAddress,
),

buildTextField(
  labelText: "No Telepon", 
  controller: txtNoTelpon,
  keyboardType: TextInputType.phone,
),
```

#### **Button dengan Orange Theme (SUDAH BENAR):**
```dart
// ✅ BENAR - ElevatedButton dengan orange theme
ElevatedButton(
  style: ElevatedButton.styleFrom(
    elevation: 2.0,
    primary: primaryOrange,                          // ✅ Orange background
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)
  ),
  onPressed: () {},
  child: Text("Submit"),
)

// ✅ BENAR - Button dengan icon
ElevatedButton.icon(
  icon: Icon(Icons.save, color: Colors.white, size: 18.0),
  label: Text("Save"),
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    elevation: 2.0,
    primary: primaryOrange,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)
  ),
)
```

#### **DateTimePicker dengan Orange Theme:**
```dart
Widget buildDateTimePicker({
  String labelText,
  String labelHint,
  TextEditingController controller,
}) {
  return Container(
    margin: EdgeInsets.all(12.0),
    child: DateTimePicker(
      dateMask: 'yyyy-MM-dd',
      controller: controller,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      icon: Icon(Icons.event, color: primaryOrange),  // ✅ Orange icon
      dateLabelText: labelText,
      style: TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: labelHint,
        fillColor: Colors.white,
        filled: true,
        isDense: true,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300], width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300], width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryOrange, width: 2),  // ✅ Orange focus
        ),
      ),
    ),
  );
}
```

### 🎯 **Key Requirements:**
1. **SELALU gunakan** `primaryOrange` untuk `cursorColor` dan `focusedBorder`
2. **SELALU gunakan** `BorderRadius.circular(12)` untuk TextField modern look
3. **SELALU gunakan** `BorderRadius.circular(8)` untuk Button modern look
4. **SELALU gunakan** `Colors.white` untuk `fillColor` dengan `filled: true`
5. **SELALU gunakan** margin `EdgeInsets.all(12.0)` untuk consistency
6. **SELALU gunakan** `Colors.grey[600]` untuk `labelStyle`
7. **SELALU gunakan** `primary: primaryOrange` untuk button background

### ❌ **Hindari:**
```dart
// ❌ JANGAN - Direct TextField tanpa custom styling
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(),  // Plain styling
  ),
)

// ❌ JANGAN - Warna yang tidak sesuai theme
TextField(
  cursorColor: Colors.blue,       // Bukan orange
  decoration: InputDecoration(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),  // Bukan orange
    ),
  ),
)

// ❌ JANGAN - Button tanpa styling
ElevatedButton(
  onPressed: () {},
  child: Text("Button"),  // Plain button tanpa theme
)
```

**KESIMPULAN**: Pattern TextField dan Button di `RegistrasiNewDriver.dart` sudah SANGAT BAIK dan SESUAI dengan guidelines. Gunakan pattern ini sebagai STANDARD untuk semua TextField dan Button di aplikasi.

## 🔍 Testing Checklist

- [ ] All screens render correctly with orange theme
- [ ] API calls work with new backend
- [ ] Null safety migration completed
- [ ] No deprecated widget usage
- [ ] Theme colors used consistently
- [ ] TextField menggunakan pattern buildTextField dengan orange theme
- [ ] Button menggunakan primaryOrange untuk background
- [ ] Authentication flow works
- [ ] All features functional
- [ ] Performance acceptable

## 📞 Support

For issues related to:
- **Backend API**: Contact Tulu Atas development team
- **Flutter Migration**: Follow official Flutter migration guide
- **Theme Issues**: Check Material Design 3 guidelines

---

**Last Updated**: December 2024
**Flutter Version**: 3.0.0+
**Dart Version**: 3.0.0+ 