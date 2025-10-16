import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_models.dart';
import '../config.dart';

class PaymentService {
  final http.Client _client;
  
  PaymentService({http.Client? client}) : _client = client ?? http.Client();

  Future<PaymentInitResponse> initPayment(PaymentRequest request) async {
    final uri = Uri.parse('${Config.gwBaseUrl}/payments/init');
    
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return PaymentInitResponse.fromJson(data);
    } else {
      throw PaymentServiceException(
        'Failed to initialize payment: ${response.statusCode}',
      );
    }
  }

  Future<PaymentStatusResponse> getPaymentStatus(String requestId) async {
    final uri = Uri.parse('${Config.gwBaseUrl}/payments/$requestId');
    
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return PaymentStatusResponse.fromJson(data);
    } else {
      throw PaymentServiceException(
        'Failed to get payment status: ${response.statusCode}',
      );
    }
  }

  Stream<PaymentStatusResponse> pollPaymentStatus(String requestId) async* {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed.inSeconds < Config.paymentTimeoutSeconds) {
      try {
        final status = await getPaymentStatus(requestId);
        yield status;
        
        // Stop polling if payment is complete
        if (status.status != 'PENDING') {
          break;
        }
        
        // Wait before next poll
        await Future.delayed(const Duration(seconds: Config.pollIntervalSeconds));
      } catch (e) {
        yield PaymentStatusResponse(
          status: 'ERROR',
          requestId: requestId,
        );
        break;
      }
    }
    
    // If we exit the loop due to timeout
    if (stopwatch.elapsed.inSeconds >= Config.paymentTimeoutSeconds) {
      yield PaymentStatusResponse(
        status: 'TIMEOUT',
        requestId: requestId,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class PaymentServiceException implements Exception {
  final String message;
  
  PaymentServiceException(this.message);
  
  @override
  String toString() => 'PaymentServiceException: $message';
}