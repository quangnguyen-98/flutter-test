class Config {
  static const String gwBaseUrl = String.fromEnvironment('PAYMENT_GW_URL', defaultValue: 'http://10.0.2.2:3002/webview');
  static const String bffEndpoint = String.fromEnvironment('BFF_ENDPOINT', defaultValue: 'http://10.0.2.2:8005');
  static const String qrScheme = 'mpsqr';
  static const String businessScheme = 'mpsbiz';
  static const String currency = 'JPY';
  static const String tender = 'PAYPAY';
  static const int paymentTimeoutSeconds = 120;
  static const int pollIntervalSeconds = 2;
  static const String deepLinkPaymentRequest = '$qrScheme://pay';
}