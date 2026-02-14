# DMS ANP Style Guide

## Button Styling Guidelines

### ElevatedButton Color Properties

**ALWAYS USE:**
```dart
style: ElevatedButton.styleFrom(
  primary: Theme.of(context).colorScheme.primary,
  onPrimary: Theme.of(context).colorScheme.onPrimary,
  // other properties...
)
```

**DO NOT USE:**
```dart
style: ElevatedButton.styleFrom(
  backgroundColor: Theme.of(context).colorScheme.primary, // ❌ WRONG
  foregroundColor: Theme.of(context).colorScheme.onPrimary, // ❌ WRONG
  // other properties...
)
```

### Standard Button Colors

#### Primary Button (Orange Theme)
```dart
primary: Theme.of(context).colorScheme.primary,
onPrimary: Theme.of(context).colorScheme.onPrimary,
```

#### Secondary Button
```dart
primary: Theme.of(context).colorScheme.secondary,
onPrimary: Theme.of(context).colorScheme.onSecondary,
```

#### Error/Cancel Button
```dart
primary: Colors.red,
onPrimary: Colors.white,
```

### Container Colors

#### Background
```dart
decoration: BoxDecoration(color: Color(0xFFF2F3F8)) // Light gray
```

#### Text and Icons
```dart
color: Color(0xFF253840) // Dark blue-gray
```

#### Borders and Outlines
```dart
color: Color(0xFF757575) // Medium gray
```

### Opacity Usage
```dart
// Correct opacity syntax
color: Color(0xFF253840).withOpacity(0.12)  // 12% opacity
color: Color(0xFF253840).withOpacity(0.38)  // 38% opacity

// NEVER use this format: Color(0xFF253840)12 ❌
```

## Color Constants

Based on INSTRUCTIONS.md orange theme:
- Primary: `#FF9800` (Orange 500)
- Secondary: `#FFB74D` (Orange 300)
- Background: `#F2F3F8` (Light gray)
- Text: `#253840` (Dark blue-gray)
- Border: `#757575` (Medium gray)

---
**Last Updated**: December 2024
**Project**: DMS ANP Flutter