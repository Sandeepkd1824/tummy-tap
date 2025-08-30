# TummyTap Flutter Frontend (MVP)

A starter Flutter frontend for a food delivery app with:
- Login/Register (mock)
- Browse items, search
- Cart & checkout (mock payment)
- Orders list & status
- Live tracking screen (simulated driver on Google Map)

> Backend is **not required** for this MVP. Data is mocked. We'll hook up Django REST Framework later.

---

## Prereqs

1) Install Flutter & Android toolchain (Android Studio / SDK / emulator).
2) In a terminal, check:
```bash
flutter doctor
```

## Get started

```bash
# unzip this folder, cd into it
cd tummytap_frontend

# generate platform folders (android/ios/web) if missing
flutter create .

# get packages
flutter pub get

# run on a connected device/emulator
flutter run
```

## Enable Google Maps (for the tracking screen)

- Create a Google Maps API key.
- Android: edit `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:

```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY_HERE"/>
```

- iOS: add the key in `ios/Runner/AppDelegate.swift` using `GMSServices.provideAPIKey("YOUR_API_KEY_HERE")`
  and add the Maps SDK for iOS to your project.

The app will still compile without the key, but the map will show a blank/grey view.

## What’s inside

- `lib/main.dart`: app bootstrap & routes
- `lib/theme.dart`: brand theme (TummyTap colors)
- `lib/models.dart`: Product, CartItem, Order, Address
- `lib/mock_api.dart`: mock products & search
- `lib/providers.dart`: Auth, Cart, Order providers
- `lib/screens/…`: UI screens (auth, home, product details, checkout, tracking)

## Next steps (when we connect DRF)

- Replace `MockApi.fetchProducts()` with your `GET /products/` endpoint
- Swap `AuthProvider.login/register` mocks with real `POST /auth/` calls
- Persist cart & orders via API
- Replace tracking simulation with real driver location polling (e.g. `GET /orders/{id}/location`)

---

**Brand tip:** Colors & typography live in `theme.dart`. Update to match your TummyTap identity.