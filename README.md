# villaluna_advmobprogAY2627

## Lab Activity 2: Discussion

### Interaction Between Model, Service, and Screen

In this activity, the application renders API data from the DummyJSON products endpoint through a clean separation of concerns:

1. **`ProductModel` (`lib/models/product_model.dart`)**:
   - Acts as the data blueprint for API objects (`Product`, `ProductDimensions`, `ProductReview`, `ProductMeta`).
   - Implements `fromJson` factory constructors that parse API JSON responses into strongly-typed Dart objects with fallback safety.

2. **`ProductService` (`lib/services/product_service.dart`)**:
   - Manages asynchronous HTTP requests using `http.get()`.
   - Uses `dotenv.env['HOST']` configured from `assets/.env`.
   - Validates HTTP response status code `200 OK`, decodes JSON using `jsonDecode`, maps the product array to `List<Product>`, and throws exceptions on failure.

3. **`ProductScreen` (`lib/screens/product_screen.dart`)**:
   - Consumes `ProductService.getAllProducts()` using a `FutureBuilder<List<Product>>`.
   - Handles loading (`CircularProgressIndicator`), error, and success states dynamically.
   - Includes **Enhancement 1 (Product search bar)** for case-insensitive product filtering across title, category, brand, and description.
   - Includes **Enhancement 2 (Product details navigation)** to display `ProductDetailsScreen` when a product card is tapped.

4. **`ThemeProvider` (`lib/providers/theme_provider.dart`) & `SettingsScreen` (`lib/screens/settings_screen.dart`)**:
   - `ThemeProvider` manages application theme state (`isDark`, `lightTheme`, `darkTheme`) using `ChangeNotifier`.
   - Includes **Enhancement 3 (Settings theme switch)** using `SwitchListTile` to toggle between Light and Dark modes across the app immediately.

### Architecture & Design Pattern

- This activity implements the **Model-View-Provider (MVP / Clean Architecture)** design pattern for Flutter applications.
- Isolating business logic into dedicated directories (`constants/`, `models/`, `providers/`, `screens/`, `services/`, `widgets/`) improves maintainability, scalability, and code readability.

### Personal Reflection & Learning Takeaway

solod dami ko natutunan

---

## Lab Activity 3: API Part II

### Overview
Lab Activity 3 extends the application by integrating shopping cart capabilities using the **DummyJSON Carts API**. The architecture follows a strict separation of concerns among models, services, screens, and state providers.

---

### 1. The Cart Model (`lib/models/cart.dart`)
- **`Cart` & `CartProduct` Classes**: Strongly typed data structures representing cart payloads.
- **Null-Safe JSON Deserialization**: Implements robust `fromJson` factory methods that safely convert dynamic numerical types (`num` to `double` or `int`) with fallback values to guard against missing API fields.
- **Model Adapter (`toProduct()`)**: `CartProduct` provides a `toProduct()` method mapping cart item attributes into the existing `Product` model. This enables direct reuse of `ProductDetailsScreen` (`detail_screen.dart`) without altering the product details architecture.

---

### 2. The Cart Service (`lib/services/cart_service.dart`)
- **`getCartByUserId(int userId)`**: Sends an asynchronous `GET` request to `https://dummyjson.com/carts/user/{userId}` to retrieve carts associated with the specified user.
- **`addToCart(...)`**: Sends a `POST` request to `https://dummyjson.com/carts/add` with `userId` and item payload (`productId`, `quantity`).
- **Error Handling**: Validates HTTP status codes (`200 OK`, `201 Created`), decodes JSON bodies safely, catches network failures, and surfaces informative exception messages.

---

### 3. The Cart Screen (`lib/screens/cart_screen.dart`)
- **Cart Display**: Renders items with product thumbnail, title, price, quantity, discount badge, savings calculation, and line item total.
- **Item Selection**: Interactive checkboxes enable selective item checkout with dynamic subtotal and total recalculations.
- **Safe Quantity Controls**: Decrement (`-`) and increment (`+`) buttons update item quantities and price totals safely.
- **Order Confirmation**: "Confirm Order" button prevents duplicate submissions during processing and presents an order summary dialog.

---

### 4. Cart-by-User-ID Retrieval
- Handled via `CartService().getCartByUserId(1)` on screen initialization.
- Retrieves the user's active cart and synchronizes product quantities and order totals.

---

### 5. Add-to-Cart Integration
- Integrated in `ProductDetailsScreen` (`lib/screens/product_details_screen.dart`).
- Includes a quantity selector (`-` / `+`) and an "Add to Cart" button with progress indicator preventing duplicate submissions.
- Displays a confirmation SnackBar upon success with a quick navigation action to the Cart.

---

### 6. Navigation to the Existing Detail Screen
- Tapping any cart item in `CartScreen` constructs a `Product` via `item.toProduct()` and navigates to `ProductDetailsScreen` (`detail_screen.dart`), maintaining seamless navigation.

---

### 7. The Updated Model-Service-Screen Design Pattern
- **Model Layer** (`lib/models/`): Pure Dart classes for typed data representation and JSON serialization.
- **Service Layer** (`lib/services/`): Pure Dart HTTP clients isolating network requests and error handling outside the UI.
- **Screen Layer** (`lib/screens/`): Stateful and Stateless widgets focusing exclusively on rendering, layout, user interaction, and navigation.
- **Provider Layer** (`lib/providers/`): Manages application-wide theme state.

---

### 8. Loading, Error, Empty, and Success State Handling
- **Loading State**: Displays a centered `CircularProgressIndicator` during API calls.
- **Error State**: Displays error feedback with an icon, descriptive message, and a **Retry** button.
- **Empty State**: Displays an empty cart icon, helpful prompt, and a **Browse Products** button that switches back to the Shop tab.
- **Success State**: Displays populated cart items, interactive controls, and an order summary with checkout action.

---

### 9. Files Added or Modified

| Status | File Path | Purpose |
| :--- | :--- | :--- |
| **Added** | `lib/models/cart.dart` | Cart and CartProduct data models with JSON parsing and mapping |
| **Added** | `lib/models/cart_model.dart` | Export file for cart model backwards compatibility |
| **Added** | `lib/models/product.dart` | Export file for product model compatibility |
| **Added** | `lib/constants.dart` | Root-level export for constants |
| **Added** | `lib/services/cart_service.dart` | Cart HTTP service for DummyJSON API |
| **Added** | `lib/screens/cart_screen.dart` | Cart screen with multi-state support and quantity controls |
| **Added** | `lib/screens/detail_screen.dart` | Export and alias for ProductDetailsScreen |
| **Added** | `test/cart_model_test.dart` | Comprehensive unit tests for Cart & CartProduct models |
| **Modified** | `lib/services/product_service.dart` | Added `getProductById` helper |
| **Modified** | `lib/screens/product_details_screen.dart` | Added quantity selector and Add-to-Cart integration |
| **Modified** | `lib/screens/home_screen.dart` | Added Cart tab, moved Chat to FAB with conditional visibility |
| **Modified** | `lib/main.dart` | Registered `/cart` route |
| **Modified** | `README.md` | Added Lab Activity 3 documentation |

---

### 10. Personal Reflection & Learning Takeaway

same as well sa lab act 2 ang dami ko parinnatutunan hahaha
