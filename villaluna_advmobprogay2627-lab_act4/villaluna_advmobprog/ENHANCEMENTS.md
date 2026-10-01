# Lab Activities - Enhancements Documentation

This document details all required enhancements implemented in the **villaluna_advmobprog** project, including source code file locations, exact line markers, and feature descriptions.

---

## Lab Activity 4: API Part III

### Enhancement 1: Make your own UI for the splash_screen implementing the persistent authentication.
- **File Location**: `lib/screens/splash_screen.dart`
- **Source Comment**: 
  ```dart
  // Enhancement 1: Make your own UI for the splash_screen implementing the persistent authentication.
  ```
- **Description**:
  - Custom UI with clean white background, official NU Shield SVG logo, "NUBD Exchange" title, and golden progress indicator.
  - Automatically queries `AuthStorageService.getSavedUser()` on launch to check for an existing authenticated session in `SharedPreferences`.
  - Performs safe conditional navigation (`pushReplacementNamed` to `/home` if authenticated, or `/signin` if unauthenticated).

---

### Enhancement 2: Make your own UI for the sign_screen implementing the user_service and the authentication logic above.
- **File Location**: `lib/screens/signin_screen.dart`
- **Source Comment**: 
  ```dart
  // Enhancement 2: Make your own UI for the sign_screen implementing the user_service and the authentication logic above.
  ```
- **Description**:
  - Custom Material 3 login form with `GlobalKey<FormState>`, input validation, and password visibility toggle.
  - Delegates network communication to `UserService.login()` (`POST $host/auth/login`) without embedding HTTP calls in UI widgets.
  - Disables repeated submissions with a loading spinner while authenticating.
  - Saves the resulting `User` instance in `SharedPreferences` via `AuthStorageService` and navigates to the authenticated home screen.

---

### Enhancement 3: Using the user_service create your own user.dart (model) implementing it on this project and rendering the data on the profile_screen creating UI on it. Based on the saved user data render the cart by userId
- **File Locations**:
  - `lib/models/user.dart` (Model)
  - `lib/screens/profile_screen.dart` (Profile UI)
  - `lib/screens/cart_screen.dart` (Cart UI)
- **Source Comments**:
  - `// Enhancement 3: Using the user_service create your own user.dart (model) implementing it on this project and rendering the data on the profile_screen creating UI on it. Based on the saved user data render the cart by userId`
- **Description**:
  - **User Model (`user.dart`)**: Strongly-typed model with `id`, `username`, `firstName`, `lastName`, `email`, `phone`, `gender`, `image`, `token`, `fullName`, `fromJson`, and `toJson`.
  - **Profile Screen (`profile_screen.dart`)**: Renders authenticated user details (avatar, full name, yellow username, email, gender, user ID) and provides confirmed session logout with `pushNamedAndRemoveUntil`.
  - **Cart Screen (`cart_screen.dart`)**: Dynamically resolves the active user's ID from persistent storage and requests `$host/carts/user/{userId}` to load the user's specific cart items instead of a hardcoded account.

---

## Lab Activity 3: API Part II

### Enhancement 1: Cart Screen and Detail-Screen Navigation
- **File Location**: `lib/screens/cart_screen.dart`
- **Source Comment**: `// Enhancement 1: Cart screen and detail-screen navigation`
- **Description**: Cart items display with product thumbnail, title, price, and navigate to product details on tap via `item.toProduct()`.

### Enhancement 2: Chat FloatingActionButton and Cart-Screen Visibility
- **File Location**: `lib/screens/home_screen.dart`
- **Source Comment**: `// Enhancement 2: Chat FloatingActionButton and cart-screen visibility`
- **Description**: Gold floating action button for customer support, conditionally hidden when viewing the cart.

### Enhancement 3: Cart by User ID and Add-to-Cart Integration
- **File Location**: `lib/services/cart_service.dart` & `lib/screens/product_details_screen.dart`
- **Source Comment**: `// Enhancement 3: Cart by user ID and add-to-cart integration`
- **Description**: Fetching cart by user ID and posting items to `$host/carts/add`.

---

## Lab Activity 2: API Part I

### Enhancement 1: Product Search Bar
- **File Location**: `lib/screens/product_screen.dart`
- **Source Comment**: `// Enhancement 1: Product search bar`

### Enhancement 2: Product Details Navigation
- **File Location**: `lib/screens/product_screen.dart` -> `lib/screens/product_details_screen.dart`
- **Source Comment**: `// Enhancement 2: Product details navigation`

### Enhancement 3: Settings Theme Switch
- **File Location**: `lib/screens/settings_screen.dart`
- **Source Comment**: `// Enhancement 3: Settings theme switch`
