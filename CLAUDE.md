# CLAUDE.md - QR App

## Service Overview
**Name**: smart-tab-qr-app
**Type**: Flutter Native Application
**Purpose**: Customer-facing display for QR code payments
**Platform**: Android tablets (secondary display)

## Architecture Position
```
[Business App] → [QR App] → [Payment WebView] → [Payment API]
                     ↓
              [PayPay Gateway]
```

## Key Responsibilities
1. **QR Display**: Show payment QR codes to customers
2. **WebView Hosting**: Hosts QRDisplay.tsx
3. **Payment Status**: Receive and relay payment results
4. **Deep Link Handling**: Receive payment requests, return results

## Technical Stack
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **WebView**: webview_flutter
- **Deep Links**: app_links package
- **JSON**: json_serializable

## Project Structure
```
lib/
├── main.dart                    # App entry, deep link handler
├── config.dart                  # App configuration
├── screens/
│   ├── home_screen.dart        # Default screen
│   └── qr_display_screen.dart  # WebView for QR display
├── services/
│   ├── deep_link_service.dart  # Handle mpsqr:// scheme
│   └── payment_service.dart    # Payment processing
├── models/
│   ├── payment_models.dart     # Payment data models
│   └── payment_models.g.dart   # Generated serialization
└── constants/
    └── webview_constants.dart  # Channel: 'paymentResult'
```

## WebView Integration
**JavaScript Channel**: `paymentResult`
**Hosted Page**: `/qr-display`

**Message Handling**:
```dart
// Receive from QRDisplay.tsx
{
  "request_id": "xxx",
  "status": "COMPLETED", // or FAILED, CANCELLED, TIMEOUT
  "amount": 1000,
  "currency": "JPY",
  "txn_id": "PYPY123",
  "terminal_id": "T001"
}
```

## Deep Link Configuration
**Scheme**: `mpsqr://`
**Patterns**:
- `mpsqr://pay?amount=1000&request_id=xxx&terminal_id=T001` - Payment request

## Communication Flow
1. **From Business App**: Receive `mpsqr://pay` with payment params
2. **To WebView**: Load QRDisplay.tsx with query parameters
3. **From WebView**: Receive payment result via paymentResult channel
4. **To Business App**: Return via `mpsbiz://result/pay?status=X`

## Development Guidelines

### Code Style
- Use `const` constructors where possible
- Follow Flutter naming conventions
- Use generated code for JSON serialization

### WebView Management
- Clear cache on each load
- Handle navigation errors
- Set proper user agent

### State Management
- Keep payment state in providers
- Clear state after payment complete

## Environment Variables
```dart
class Config {
  static const String webViewBaseUrl = 'https://payment.stab.com';
  static const String deepLinkScheme = 'mpsqr';
  static const String businessAppScheme = 'mpsbiz';
}
```

## Build & Run
```bash
# Generate serialization code
flutter pub run build_runner build

# Run on device
flutter run

# Build APK
flutter build apk --release
```

## Common Issues & Solutions

### QR Code Not Displaying
- Check WebView URL construction
- Verify payment parameters
- Check network connectivity

### Payment Result Not Returning
- Verify paymentResult channel registration
- Check JSON parsing
- Verify deep link to Business App

### Build Issues
- Run `flutter clean` and rebuild
- Regenerate serialization: `flutter pub run build_runner build --delete-conflicting-outputs`

## Related Services
- **Business App** (`smart-tab-business-app`): Main POS application
- **Payment WebView** (`stab-payment-webview`): QR display UI
- **Payment API** (`stab-payment-api`): Payment processing backend