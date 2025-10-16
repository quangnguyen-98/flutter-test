import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/services/deep_link_service.dart';
import 'package:qr_app/models/payment_models.dart';

void main() {
  group('DeepLinkService', () {
    test('should parse valid payment request URI', () {
      const uriString = 'mpsqr://pay?requestId=test-123&amount=1500&currency=JPY&tender=PAYPAY';
      
      final request = DeepLinkService.parsePaymentRequest(uriString);
      
      expect(request, isNotNull);
      expect(request!.requestId, 'test-123');
      expect(request.amount, 1500);
      expect(request.currency, 'JPY');
      expect(request.tender, 'PAYPAY');
    });

    test('should return null for invalid URI scheme', () {
      const uriString = 'invalid://pay?requestId=test&amount=1000';
      
      final request = DeepLinkService.parsePaymentRequest(uriString);
      
      expect(request, isNull);
    });

    test('should return null for invalid URI host', () {
      const uriString = 'mpsqr://invalid?requestId=test&amount=1000';
      
      final request = DeepLinkService.parsePaymentRequest(uriString);
      
      expect(request, isNull);
    });

    test('should return null for malformed URI', () {
      const uriString = 'not-a-valid-uri';
      
      final request = DeepLinkService.parsePaymentRequest(uriString);
      
      expect(request, isNull);
    });
  });
}