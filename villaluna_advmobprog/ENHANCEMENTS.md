# Lab Activity 2 - Enhancements Documentation

This document details the three required enhancements implemented in the **villaluna_advmobprog** project, including source code file locations, exact line markers, and feature descriptions.

---

### Enhancement 1: Product Search Bar
- **File Location**: `lib/screens/product_screen.dart`
- **Source Comment**: `// Enhancement 1: Product search bar`
- **Description**: 
  - Placed above the product grid view.
  - Real-time case-insensitive search filtering products across title, category, brand, and description fields.
  - Includes search icon and clear button to reset the filter query.

---

### Enhancement 2: Product Details Navigation
- **File Location**: `lib/screens/product_screen.dart` -> `lib/screens/product_details_screen.dart`
- **Source Comment**: `// Enhancement 2: Product details navigation`
- **Description**:
  - Tapping any product card triggers `Navigator.push` to navigate to `ProductDetailsScreen`.
  - Displays product thumbnail, title, price, star ratings, stock availability, category, brand, description, and customer reviews.

---

### Enhancement 3: Settings Theme Switch
- **File Location**: `lib/screens/settings_screen.dart`
- **Source Comment**: `// Enhancement 3: Settings theme switch`
- **Description**:
  - `SwitchListTile` widget located inside `SettingsScreen`.
  - Interacts directly with `ThemeProvider` to dynamically toggle between Light and Dark mode across the application.
