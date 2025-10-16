import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_models.dart';
import '../services/payment_service.dart';

class QRPaymentState {
  final PaymentRequest? request;
  final PaymentInitResponse? initResponse;
  final PaymentStatus status;
  final String? error;
  final String? transactionId;
  final bool isLoading;

  QRPaymentState({
    this.request,
    this.initResponse,
    this.status = PaymentStatus.pending,
    this.error,
    this.transactionId,
    this.isLoading = false,
  });

  QRPaymentState copyWith({
    PaymentRequest? request,
    PaymentInitResponse? initResponse,
    PaymentStatus? status,
    String? error,
    String? transactionId,
    bool? isLoading,
  }) {
    return QRPaymentState(
      request: request ?? this.request,
      initResponse: initResponse ?? this.initResponse,
      status: status ?? this.status,
      error: error ?? this.error,
      transactionId: transactionId ?? this.transactionId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QRPaymentNotifier extends StateNotifier<QRPaymentState> {
  final PaymentService _paymentService;
  StreamSubscription<PaymentStatusResponse>? _pollSubscription;

  QRPaymentNotifier(this._paymentService) : super(QRPaymentState());

  Future<void> initializePayment(PaymentRequest request) async {
    state = state.copyWith(
      request: request,
      isLoading: true,
      error: null,
    );

    try {
      final initResponse = await _paymentService.initPayment(request);
      
      state = state.copyWith(
        initResponse: initResponse,
        isLoading: false,
      );
      
      // Start polling for payment status
      _startPolling(request.requestId);
      
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        status: PaymentStatus.failed,
      );
    }
  }

  void _startPolling(String requestId) {
    _pollSubscription?.cancel();
    
    _pollSubscription = _paymentService
        .pollPaymentStatus(requestId)
        .listen(
          (statusResponse) {
            final status = PaymentStatus.fromString(statusResponse.status);
            
            state = state.copyWith(
              status: status,
              transactionId: statusResponse.txnId,
            );
            
            // Stop polling if payment is complete
            if (status != PaymentStatus.pending) {
              _pollSubscription?.cancel();
            }
          },
          onError: (error) {
            state = state.copyWith(
              error: error.toString(),
              status: PaymentStatus.failed,
            );
            _pollSubscription?.cancel();
          },
        );
  }

  void cancelPayment() {
    _pollSubscription?.cancel();
    state = state.copyWith(
      status: PaymentStatus.cancelled,
    );
  }

  void reset() {
    _pollSubscription?.cancel();
    state = QRPaymentState();
  }

  @override
  void dispose() {
    _pollSubscription?.cancel();
    super.dispose();
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

final qrPaymentProvider = StateNotifierProvider<QRPaymentNotifier, QRPaymentState>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return QRPaymentNotifier(paymentService);
});