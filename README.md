# Product List & Auth App

A mobile product catalogue application built with **Flutter**, featuring secure JWT authentication with automatic token refresh, offline caching, QR-code product scanning, multi-language localization (EN/AR), dynamic theme switching (Dark/Light mode), and full state management powered by BLoC.

---

## 🚀 How to Run the App

Running the application is simple and requires only standard Flutter commands:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run the application (select your simulator, emulator, or connected device)
flutter run
```

### Running Tests

Execute the automated test suite (unit tests, UI widget tests, and BLoC integration tests):

```bash
flutter test
```

To run static analysis and lint checks:

```bash
flutter analyze
```

---



## ⏱️ Hours Spent

**Total Time Invested:** ~**4 - 5 hours**

---

## 📁 Folder Structure

The project follows a clean **feature-first** and **layered architecture**, separating core shared infrastructure from feature-specific presentation and business logic.

```
lib/
├── main.dart                          # App entry point
├── app/                               # Global application configuration
│   ├── app.dart                       # Root MaterialApp, theme, and locale setup
│   ├── shell.dart                     # Main bottom navigation shell
│   └── bloc/                          # Shell navigation BLoC (tab index switching)
│       ├── shell_bloc.dart
│       ├── shell_event.dart
│       └── shell_state.dart
├── core/                              # Shared foundation and domain services
│   ├── api_service.dart               # Dio HTTP client, ApiEndpointRegistry, dev logger, & token refresh
│   ├── auth_repository.dart           # Authentication & token persistence handling
│   ├── local_store.dart               # Persistent storage for preferences, cache & favourites
│   ├── product.dart                   # Product domain models & JSON serialization
│   ├── product_card.dart              # Shared reusable product card UI component
│   ├── product_repository.dart        # Repository coordinating API & offline caching
│   └── strings.dart                   # Centralized string translations (EN / AR)
└── features/                          # Feature modules
    ├── auth/                          # Authentication feature
    │   ├── login_page.dart            # Login form UI with validation & loading states
    │   └── bloc/                      # AuthBloc (login, logout, session state)
    ├── products/                      # Product catalogue feature
    │   ├── products_page.dart         # Paginated catalogue list & search UI
    │   ├── product_detail_page.dart   # Product details screen
    │   ├── bloc/                      # ProductsBloc (pagination, search, offline fallback)
    │   └── detail_bloc/               # Product detail BLoC (cache retrieval & fetch)
    ├── favourites/                    # Favourites feature
    │   ├── favourites_page.dart       # Saved favourite products list
    │   └── bloc/                      # FavouritesBloc (toggle & persistent favourites)
    ├── scanner/                       # QR / Barcode scanner feature
    │   ├── scanner_page.dart          # Camera scanner UI with permission handling
    │   ├── scan_code_parser.dart      # Deep link & product QR parsing
    │   └── bloc/                      # ScannerBloc (barcode processing & product navigation)
    └── settings/                      # Settings & preferences feature
        ├── settings_page.dart         # Theme switch, language picker, & logout UI
        ├── theme_bloc/                # ThemeBloc (light / dark mode toggling)
        └── bloc/                      # LocaleBloc (EN / AR language switching)

test/                                  # Automated test suite
├── api_service_test.dart              # ApiEndpointRegistry, dev logger, & interceptor tests
├── login_ui_test.dart                 # Login form widget & validation flow tests
├── products_bloc_test.dart            # Products pagination & offline caching tests
├── scanner_bloc_test.dart             # QR scanner code parsing & lookup tests
├── theme_bloc_test.dart               # Theme toggling tests
└── widget_test.dart                   # Model parsing & deeplink parser tests
```

---

## 📦 Libraries Used & Why

| Library | Version | Purpose & Justification |
| :--- | :--- | :--- |
| **`flutter_bloc`** | `^9.1.1` | **State Management:** Implements the BLoC pattern to ensure clean separation between UI and business logic, providing predictable state transitions, high maintainability, and easy testability across all features. |
| **`dio`** | `^5.11.1` | **HTTP Networking:** Advanced networking client supporting interceptors, automated authorization headers, token refreshing on 401s, request/response developer logging, and configurable timeouts. |
| **`flutter_secure_storage`** | `^11.2.0` | **Secure Storage:** Safely persists sensitive credentials (JWT access and refresh tokens) using platform-native secure encryption (Keychain on iOS, Keystore/EncryptedSharedPreferences on Android). |
| **`shared_preferences`** | `^2.5.6` | **Key-Value Persistence:** Stores non-sensitive user preferences (selected theme mode, active language) and serialized cache for offline product browsing and favourites. |
| **`mobile_scanner`** | `^7.5.0` | **Hardware Camera Scanning:** Fast and reliable QR/barcode scanning capabilities for instant in-store product lookup via camera. |
| **`permission_handler`** | `^13.0.2` | **Runtime Permissions:** Clean cross-platform API to request and verify camera permissions gracefully before launching the scanner. |
| **`cached_network_image`** | `^4.0.6` | **Image Optimization:** Caches remote product images locally in memory and disk with placeholders and error widgets, optimizing bandwidth and speeding up scroll performance. |
| **`flutter_localizations`** | SDK | **Internationalization:** First-party support for localized text, formatting, and RTL (Right-to-Left) directional layout for Arabic language support. |
| **`cupertino_icons`** | `^1.0.8` | **Asset Icons:** Provides crisp iOS-style design symbols alongside Material design icons. |
| **`flutter_lints`** | `^6.0.0` | **Code Quality:** Enforces recommended Dart and Flutter style guidelines and lint rules for clean, bug-free code. |
| **`flutter_test`** | SDK | **Testing:** Comprehensive unit, BLoC, and widget UI test suite. |

---

## 🎁 Bonus Features Included

1. **Automatic Refresh Token Mechanism in `ApiService`:**
   - Intercepts `401 Unauthorized` responses and transparently issues a refresh token request to `/auth/refresh`.
   - Queues pending requests and retries the original request with the new access token without disrupting user interaction.
   - Gracefully triggers session expiry and logout if the refresh token is invalid or expired.
2. **Centralized `ApiEndpointRegistry` & Dev Logging Interceptor:**
   - Static registry (`ApiEndpointRegistry` / `ApiEndpoints`) centralizing base URLs and endpoint paths.
   - Built-in `ApiLogInterceptor` that logs API base URL, HTTP method, endpoint, status code, and response body for all network calls via `dart:developer`.
3. **Automated Login Flow UI Tests:**
   - Widget tests in `test/login_ui_test.dart` validating input field behavior, required-field validations, password visibility toggle, and successful submission states.
4. **Dark & Light Mode Support:**
   - Complete dynamic theming with persistent preference saved across app restarts via `ThemeBloc` and `LocalStore`.
5. **Offline Caching & Resilience:**
   - Products, product details, and favourites are cached locally, allowing offline browsing with connectivity fallback handling.
6. **Multi-Language Support (EN & AR):**
   - Instant localization toggle between English and Arabic with automatic RTL layout mirroring.

---

## 🔮 What I Would Improve

Given additional time, the following improvements would elevate the user experience and codebase further:

- **Enhanced UI with Hero Animations:**
  - Implement seamless `Hero` transitions between the product image thumbnail in the catalogue grid/list and the hero image on the product detail screen.
- **Custom Page Route Transitions:**
  - Add fluid page transitions (e.g., shared axis transitions, custom slide & fade page curves) instead of standard platform push transitions.
- **Micro-Interactions with Lottie / SVGs:**
  - Replace static icons with animated SVGs and Lottie animations (e.g., animated checkmark on login, animated heart for favourites toggle, animated shopping cart).
- **Rive Animations for Empty & Error States:**
  - Introduce interactive Rive or Lottie animations for empty search results, offline banners, 404 errors, and barcode scanning guides.
- **Shimmer Loading Skeletons:**
  - Add shimmer skeleton loading cards instead of circular progress indicators during initial pagination and search queries.
- **Live Network Connectivity Watcher:**
  - Integrate `connectivity_plus` with a persistent animated top toast to notify users immediately when they go offline or come back online.
