# MPS SmartTab QR App - Development Helper Commands

.PHONY: get-ip run-dev clean build help

# Get local IP address and show Flutter run command
get-ip:
	@echo "Wi-Fi IP: $$(ipconfig getifaddr en0)"
	@echo "Use: flutter run --dart-define=PAYMENT_GW_URL=http://$$(ipconfig getifaddr en0):8000/webview --dart-define=BFF_ENDPOINT=http://$$(ipconfig getifaddr en0):8005"

# Run app with local IP for device testing
run-dev:
	@IP=$$(ipconfig getifaddr en0); \
	echo "Running with host IP: $$IP"; \
	flutter run --dart-define=PAYMENT_GW_URL=http://$$IP:8000/webview  --dart-define=BFF_ENDPOINT=http://$$IP:8005

# Clean build artifacts
clean:
	flutter clean
	flutter pub get

# Build APK for testing
build:
	@IP=$$(ipconfig getifaddr en0); \
	echo "Building APK with host IP: $$IP"; \
	flutter build apk --dart-define=PAYMENT_GW_URL=http://$$IP:8000/webview --dart-define=BFF_ENDPOINT=http://$$IP:8005


show-apk:
	open build/app/outputs/flutter-apk/

# Show available commands
help:
	@echo "Available commands:"
	@echo "  get-ip   - Show local IP and Flutter run command"
	@echo "  run-dev  - Run app with local IP configuration"
	@echo "  clean    - Clean build artifacts and get dependencies"
	@echo "  build    - Build debug APK with local IP"
	@echo "  help     - Show this help message"