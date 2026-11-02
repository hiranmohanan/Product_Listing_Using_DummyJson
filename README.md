# Product Catalogue

A Flutter catalogue for Android and iOS using the DummyJSON API.

## Run

Install Flutter, then run:

    flutter pub get
    flutter run

Use the test credentials supplied in the assignment. Product codes such as catalogue://product/3 can be scanned with a camera or entered with **Type code instead**.

## Structure

- lib/app: Material 3 theme, auth gate, and bottom navigation
- lib/core: Dio API service, repositories, product model, local storage, and shared widgets
- lib/features: auth, products, favourites, scanner, and settings
- test: parsing, catalogue BLoC, scanner BLoC, API header, and login UI tests

Each BLoC has separate bloc, event, and state files connected with part directives. Pages are StatelessWidgets.

## Libraries

- flutter_bloc: event-driven UI state and business operations
- dio: API requests, Bearer header, and token refresh retry
- flutter_secure_storage: Keychain and Keystore-backed token storage
- shared_preferences: cached products, favourites, and language choice
- mobile_scanner and permission_handler: QR capture and camera permission flow
- cached_network_image: image disk cache and fallback placeholders
- flutter_localizations: Arabic and English Material widgets and RTL layout

## Checks

    flutter analyze
    flutter test
    flutter build apk --debug

The Android debug build and automated checks pass. iOS compilation still needs macOS and Xcode. The scanner requests camera permission when Scan is opened. An invalid URL shows “This QR code is not a product”; a missing product ID shows “Product not found.”

## Bonus features

- Access tokens are refreshed on startup and after an authenticated request receives a 401 response.
- An automated login UI test checks text entry and password visibility.
- A persistent dark mode switch is available in Settings.
# Product_Listing_Using_DummyJson
