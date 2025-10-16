import 'package:json_annotation/json_annotation.dart';

part 'payment_models.g.dart';

@JsonSerializable()
class PaymentRequest {
  @JsonKey(name: 'request_id')
  final String requestId;

  final int amount;
  final String currency;
  final String tender;

  @JsonKey(name: 'terminal_id')
  final String? terminalId;


  PaymentRequest({
    required this.requestId,
    required this.amount,
    required this.currency,
    required this.tender,
    this.terminalId,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);

  factory PaymentRequest.fromUri(Uri uri) {
    final params = uri.queryParameters;
    return PaymentRequest(
      requestId: params['requestId'] ?? params['request_id'] ?? '',
      amount: int.tryParse(params['amount'] ?? '0') ?? 0,
      currency: params['currency'] ?? 'JPY',
      tender: params['tender'] ?? 'PAYPAY',
    );
  }
}

@JsonSerializable()
class PaymentInitResponse {
  @JsonKey(name: 'qr_string')
  final String qrString;

  final String expiry;

  @JsonKey(name: 'request_id')
  final String requestId;

  PaymentInitResponse({
    required this.qrString,
    required this.expiry,
    required this.requestId,
  });

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentInitResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInitResponseToJson(this);
}

@JsonSerializable()
class PaymentStatusResponse {
  final String status;

  @JsonKey(name: 'txn_id')
  final String? txnId;

  @JsonKey(name: 'request_id')
  final String requestId;

  PaymentStatusResponse({
    required this.status,
    this.txnId,
    required this.requestId,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentStatusResponseToJson(this);
}

@JsonSerializable()
class PaymentResult {
  @JsonKey(name: 'request_id')
  final String requestId;

  final PaymentStatus? status;
  final double? amount;
  final String? currency;
  final String? tender;

  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  final DateTime timestamp;

  PaymentResult({
    required this.requestId,
    this.status,
    this.amount,
    this.currency,
    this.tender,
    this.transactionId,
    required this.timestamp,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResultToJson(this);

  @override
  String toString() {
    return 'PaymentResult('
        'requestId: $requestId, '
        'status: $status, '
        'amount: $amount, '
        'currency: $currency, '
        'tender: $tender, '
        'transactionId: $transactionId, '
        'timestamp: $timestamp'
        ')';
  }
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
  timeout;

  static PaymentStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return PaymentStatus.pending;
      case 'COMPLETED':
        return PaymentStatus.completed;
      case 'FAILED':
        return PaymentStatus.failed;
      case 'CANCELLED':
        return PaymentStatus.cancelled;
      case 'TIMEOUT':
        return PaymentStatus.timeout;
      default:
        return PaymentStatus.failed;  // Default to failed for unknown status
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.completed:
        return 'COMPLETED';
      case PaymentStatus.failed:
        return 'FAILED';
      case PaymentStatus.cancelled:
        return 'CANCELLED';
      case PaymentStatus.timeout:
        return 'TIMEOUT';
    }
  }

  @override
  String toString() => apiValue;
}