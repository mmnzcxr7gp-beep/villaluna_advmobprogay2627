# villaluna_advmobprogAY2627

## Lab Activity 2: Discussion (Bea Borres Style 💅✨)

### Interaction Between Model, Service, and Screen

Okay guys, so basically, for this lab activity, i-chika ko sa inyo kung paano nag-wo-work behind the scenes 'tong super slay nating e-commerce app gamit ang DummyJSON API! Sobrang clean ng separation of concerns, as in walang kalat, period!

1. **`ProductModel` (`lib/models/product_model.dart`)**:
   - Eto 'yung pinaka-blueprint ng buong chika, guys! Dito naka-define lahat ng structure like `Product`, `ProductDimensions`, `ProductReview`, and `ProductMeta`.
   - May `fromJson` factory constructors tayo here that safely parse JSON data from the API. Null-safe siya girl, so kahit may missing fields or weird data types, hindi magka-crash ang app natin! Walang tapon, super safe!

2. **`ProductService` (`lib/services/product_service.dart`)**:
   - Think of this as our personal shopper na taga-fetch ng items from the internet!
   - Gumagamit siya ng `http.get()` para tawagin 'yung `$host/products` endpoint galing sa ating `assets/.env`.
   - Bina-validate niya if `200 OK` ang status code, dini-decode ang JSON, and then kino-convert to a clean `List<Product>`. Kapag may error, boom—she throws an exception agad para aware tayo!

3. **`ProductScreen` (`lib/screens/product_screen.dart`)**:
   - Eto na 'yung rumarampa sa screen natin, guys! It consumes data via `FutureBuilder<List<Product>>`.
   - Sobrang responsive! May loading spinner habang nagpe-fetch, may error view if ever, and 'yung product grid kapag success.
   - **Enhancement 1 (Search Bar)**: Pwede kang mag-search ng kahit anong bet mong product—title, brand, category, or description, sobrang real-time!
   - **Enhancement 2 (Product Details Navigation)**: Click mo lang 'yung card, dadalhin ka agad sa `ProductDetailsScreen` to see all the specs and customer reviews!

4. **`ThemeProvider` (`lib/providers/theme_provider.dart`) & `SettingsScreen` (`lib/screens/settings_screen.dart`)**:
   - Managed via `ChangeNotifier`, guys!
   - **Enhancement 3 (Theme Switch)**: May switch tile to toggle between Light Mode and Dark Mode instantly. Super aesthetic and easy on the eyes, literal na slay!

### Architecture & Design Pattern

- We strictly followed the **Model-View-Provider (MVP / Clean Architecture)** design pattern!
- Hiwa-hiwalay lahat ng responsibilities into `constants/`, `models/`, `providers/`, `screens/`, `services/`, and `widgets/`. Sobrang dali i-maintain and i-scale, no stress at all!

### Personal Reflection & Learning Takeaway

solod dami ko natutunan

---

## Lab Activity 3: API Part II (The Cart Era 🛒✨)

### Overview
So ayun na nga, guys! For Lab Activity 3, we took things to the NEXT LEVEL! As in major glow-up dahil nag-integrate tayo ng complete shopping cart system using the **DummyJSON Carts API**. Walang tapon, fast, and super functional! Here's the full tea:

---

### 1. The Cart Model (`lib/models/cart.dart`)
- **`Cart` & `CartProduct` Classes**: Super strongly typed, girl! Dito naka-store lahat ng details like thumbnail, title, price, quantity, discount percentage, and computed totals.
- **Null-Safe JSON Deserialization**: Lahat ng numerical values (`price`, `discountPercentage`, `total`) are safely converted from dynamic `num` to `double` or `int` with default fallback values. Zero null pointer exceptions, as in very mindful, very demure!
- **Model Adapter (`.toProduct()`)**: Eto 'yung secret sauce natin! Gumawa tayo ng `.toProduct()` method inside `CartProduct` para if you tap any cart item, it transforms seamlessly into a `Product` and opens the existing `ProductDetailsScreen` (`detail_screen.dart`) without breaking anything! Slay!

---

### 2. The Cart Service (`lib/services/cart_service.dart`)
- **`getCartByUserId(int userId)`**: She makes an asynchronous `GET` request to `https://dummyjson.com/carts/user/{userId}` para kunin ang active cart ni user (default User 1).
- **`addToCart(...)`**: Sends a `POST` request to `https://dummyjson.com/carts/add` with the `userId`, `productId`, and `quantity`.
- **Instant Cache & Error Handling**: Nilagyan natin ng instant in-memory cache and request timeouts para super bilis mag-load at walang hanging spinner drama sa web!

---

### 3. The Cart Screen (`lib/screens/cart_screen.dart`)
- **Aesthetic Cart Cards**: Lahat ng items are displayed in clean white rounded cards with product thumbnail, bold title, gold price tag (`#FFB800`), and discount savings breakdown.
- **Vertical Quantity Buttons**: Super trendy vertical `+` / `-` buttons! Plus button in vibrant gold, minus button in sleek slate grey.
- **Dynamic Recalculations**: Kapag nag-tap ka ng `+` or `-`, automatic na nagre-recalculate 'yung item total, discounts, and order subtotal in real time!
- **Confirm Order Action**: Full-width Golden Yellow **Confirm Order** button that displays an order summary dialog upon checkout and prevents double-clicks!

---

### 4. Cart-by-User-ID Retrieval
- Automatically triggered on screen load via `CartService().getCartByUserId(1)`.
- Synchronizes user items, item quantities, and discount rates seamlessly.

---

### 5. Add-to-Cart Integration
- Built directly into `ProductDetailsScreen` (`lib/screens/product_details_screen.dart`).
- May quantity selector (`-` / `+`) and an **Add to Cart** button with loading progress indicator to prevent duplicate submissions.
- Kapag na-add na, lalabas 'yung cute SnackBar with a **"View Cart"** button to jump straight into your cart!

---

### 6. Navigation to the Existing Detail Screen
- Just tap any product card inside the Cart screen, and boom—it uses `item.toProduct()` and opens `ProductDetailsScreen` (`detail_screen.dart`) smoothly.

---

### 7. The Updated Model-Service-Screen Design Pattern
- **Model Layer** (`lib/models/`): Pure typed data classes with serialization logic.
- **Service Layer** (`lib/services/`): Handles all HTTP networking, status code checks, and JSON decoding outside the UI.
- **Screen Layer** (`lib/screens/`): UI presentation, stateful keep-alive rendering, and navigation.
- **Provider Layer** (`lib/providers/`): Application-wide theme state management with National University Blue (`#354898`) and Gold (`#FFB800`) color palette.

---

### 8. Loading, Error, Empty, and Success State Handling
- **Loading State**: Clean centered progress indicator while fetching.
- **Error State**: Displays error feedback with an icon and an instant **Retry** button.
- **Empty State**: Cute empty cart illustration with a **Browse Products** button that switches back to the Shop tab.
- **Success State**: Complete interactive cart list with live quantity toggles, price updates, and order checkout.

---

### 9. Files Added or Modified

| Status | File Path | Purpose |
| :--- | :--- | :--- |
| **Added** | `lib/models/cart.dart` | Cart and CartProduct data models with JSON parsing and `.toProduct()` adapter |
| **Added** | `lib/models/cart_model.dart` | Export file for cart model backwards compatibility |
| **Added** | `lib/models/product.dart` | Export file for product model compatibility |
| **Added** | `lib/constants.dart` | Root-level export for constants |
| **Added** | `lib/services/cart_service.dart` | Cart HTTP service for DummyJSON API with caching & timeouts |
| **Added** | `lib/screens/cart_screen.dart` | Cart screen with multi-state support, vertical quantity buttons & order confirmation |
| **Added** | `lib/screens/detail_screen.dart` | Export and alias for ProductDetailsScreen |
| **Added** | `test/cart_model_test.dart` | Comprehensive unit tests for Cart & CartProduct models |
| **Modified** | `lib/services/product_service.dart` | Added `getProductById` helper |
| **Modified** | `lib/screens/product_details_screen.dart` | Added quantity selector, Add-to-Cart integration & NU Blue/Gold theme |
| **Modified** | `lib/screens/home_screen.dart` | Added Cart tab, moved Chat to FAB with conditional visibility & NU Blue AppBar |
| **Modified** | `lib/main.dart` | Registered `/cart` route |
| **Modified** | `README.md` | Added Lab Activity 3 documentation & discussions |

---

### 10. Personal Reflection & Learning Takeaway

same as well sa lab act 2 ang dami ko parinnatutunan hahaha
