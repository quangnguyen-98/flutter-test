import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/models/payment_models.dart';

void main() {
  group('PaymentRequest', () {
    test('should create from URI correctly', () {
      final uri = Uri.parse(
        'mpsqr://pay?requestId=test-123&amount=1500&currency=JPY&tender=PAYPAY',
      );
      
      final request = PaymentRequest.fromUri(uri);
      
      expect(request.requestId, 'test-123');
      expect(request.amount, 1500);
      expect(request.currency, 'JPY');
      expect(request.tender, 'PAYPAY');
    });

    test('should handle missing parameters with defaults', () {
      final uri = Uri.parse('mpsqr://pay?requestId=test-456');
      
      final request = PaymentRequest.fromUri(uri);
      
      expect(request.requestId, 'test-456');
      expect(request.amount, 0);
      expect(request.currency, 'JPY');
      expect(request.tender, 'PAYPAY');
    });

    test('should serialize to JSON correctly', () {
      final request = PaymentRequest(
        requestId: 'test-789',
        amount: 2000,
        currency: 'JPY',
        tender: 'PAYPAY',
      );
      
      final json = request.toJson();
      
      expect(json['requestId'], 'test-789');
      expect(json['amount'], 2000);
      expect(json['currency'], 'JPY');
      expect(json['tender'], 'PAYPAY');
    });
  });

  group('PaymentStatus', () {
    test('should parse status strings correctly', () {
      expect(PaymentStatus.fromString('SUCCESS'), PaymentStatus.success);
      expect(PaymentStatus.fromString('FAILED'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('ERROR'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('TIMEOUT'), PaymentStatus.timeout);
      expect(PaymentStatus.fromString('CANCELLED'), PaymentStatus.cancelled);
      expect(PaymentStatus.fromString('CANCEL'), PaymentStatus.cancelled);
      expect(PaymentStatus.fromString('PENDING'), PaymentStatus.pending);
      expect(PaymentStatus.fromString('UNKNOWN'), PaymentStatus.pending);
    });

    test('should return correct API values', () {
      expect(PaymentStatus.success.apiValue, 'SUCCESS');
      expect(PaymentStatus.failed.apiValue, 'ERROR');
      expect(PaymentStatus.timeout.apiValue, 'TIMEOUT');
      expect(PaymentStatus.cancelled.apiValue, 'CANCEL');
      expect(PaymentStatus.pending.apiValue, 'PENDING');
    });
  });

  group('PaymentInitResponse', () {
    test('should deserialize from JSON correctly', () {
      final json = {
        'qrString': '<svg>...</svg>',
        'expiry': '2024-01-01T12:00:00Z',
        'requestId': 'test-123',
      };
      
      final response = PaymentInitResponse.fromJson(json);
      
      expect(response.qrString, '<svg>...</svg>');
      expect(response.expiry, '2024-01-01T12:00:00Z');
      expect(response.requestId, 'test-123');
    });
  });

  group('PaymentStatusResponse', () {
    test('should deserialize from JSON correctly', () {
      final json = {
        'status': 'SUCCESS',
        'txnId': 'PYPY123',
        'requestId': 'test-123',
      };
      
      final response = PaymentStatusResponse.fromJson(json);
      
      expect(response.status, 'SUCCESS');
      expect(response.txnId, 'PYPY123');
      expect(response.requestId, 'test-123');
    });

    test('should handle null transaction ID', () {
      final json = {
        'status': 'PENDING',
        'requestId': 'test-456',
      };
      
      final response = PaymentStatusResponse.fromJson(json);
      
      expect(response.status, 'PENDING');
      expect(response.txnId, isNull);
      expect(response.requestId, 'test-456');
    });
  });
}