import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../models/payment_models.dart';
import '../config.dart';

class DeepLinkService {
  static Future<bool> returnToBusinessApp({
    required String requestId,
    required PaymentStatus status,
    String? transactionId,
    required int amount,
    String currency = 'JPY',
    String tender = 'PAYPAY',
    String? terminalId,
  }) async {
    final queryParams = <String, String>{
      'request_id': requestId,  // Use snake_case for consistency
      'status': status.apiValue,
      'amount': amount.toString(),
      'currency': currency,
      'tender': tender,
    };

    if (transactionId != null) {
      queryParams['txn_id'] = transactionId;
    }

    if (terminalId != null) {
      queryParams['terminal_id'] = terminalId;
    }

    final uri = Uri(
      scheme: Config.businessScheme,
      host: 'result',
      path: '/pay',
      queryParameters: queryParams,
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      return false;
    }
  }

  static PaymentRequest? parsePaymentRequest(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      if (uri.scheme == Config.qrScheme && uri.host == 'pay') {
        return PaymentRequest.fromUri(uri);
      }
    } catch (e) {
      // Invalid URI
    }
    return null;
  }
}