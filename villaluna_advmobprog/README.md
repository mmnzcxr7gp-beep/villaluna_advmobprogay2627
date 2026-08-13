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
