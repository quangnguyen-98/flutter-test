// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      requestId: json['request_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      tender: json['tender'] as String,
      terminalId: json['terminal_id'] as String?,
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'amount': instance.amount,
      'currency': instance.currency,
      'tender': instance.tender,
      'terminal_id': instance.terminalId,
    };

PaymentInitResponse _$PaymentInitResponseFromJson(Map<String, dynamic> json) =>
    PaymentInitResponse(
      qrString: json['qr_string'] as String,
      expiry: json['expiry'] as String,
      requestId: json['request_id'] as String,
    );

Map<String, dynamic> _$PaymentInitResponseToJson(
        PaymentInitResponse instance) =>
    <String, dynamic>{
      'qr_string': instance.qrString,
      'expiry': instance.expiry,
      'request_id': instance.requestId,
    };

PaymentStatusResponse _$PaymentStatusResponseFromJson(
        Map<String, dynamic> json) =>
    PaymentStatusResponse(
      status: json['status'] as String,
      txnId: json['txn_id'] as String?,
      requestId: json['request_id'] as String,
    );

Map<String, dynamic> _$PaymentStatusResponseToJson(
        PaymentStatusResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'txn_id': instance.txnId,
      'request_id': instance.requestId,
    };

PaymentResult _$PaymentResultFromJson(Map<String, dynamic> json) =>
    PaymentResult(
      requestId: json['request_id'] as String,
      status: $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      tender: json['tender'] as String?,
      transactionId: json['transaction_id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$PaymentResultToJson(PaymentResult instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'status': _$PaymentStatusEnumMap[instance.status],
      'amount': instance.amount,
      'currency': instance.currency,
      'tender': instance.tender,
      'transaction_id': instance.transactionId,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.cancelled: 'cancelled',
  PaymentStatus.timeout: 'timeout',
};
