import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_app/constants/webview_constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../models/payment_models.dart';
import '../services/deep_link_service.dart';

class QRDisplayScreen extends ConsumerStatefulWidget {
  const QRDisplayScreen({
    super.key,
    required this.deepLink,
  });

  final String deepLink;

  @override
  ConsumerState<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends ConsumerState<QRDisplayScreen> {
  late WebViewController _webViewController;
  PaymentRequest? _paymentRequest;
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _handleInitialDeepLink();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..clearCache()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            debugPrint('QR App: Page finished loading: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Resource error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        WebViewConstants.javascriptChannel,
        onMessageReceived: (JavaScriptMessage message) {
          _handlePaymentResult(message.message);
        },
      );
  }

  void _handleInitialDeepLink() async {
    final paymentRequest = _parsePaymentRequest(widget.deepLink);
    if (paymentRequest != null) {
      await _handlePaymentRequest(paymentRequest);
    } else {
      debugPrint('QR App: Failed to parse payment request from deep link');
      _showError('Invalid payment request');
    }
  }

  PaymentRequest? _parsePaymentRequest(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      final queryParams = uri.queryParameters;

      // Extract required parameters (check both formats for compatibility)
      final requestId = queryParams['request_id'] ?? queryParams['requestId'];
      final amountString = queryParams['amount'];
      final currency = queryParams['currency'];
      final tender = queryParams['tender'];

      // Validate required parameters
      if (requestId == null || amountString == null || currency == null) {
        debugPrint('QR App: Missing required parameters in deep link');
        return null;
      }

      // Parse amount
      final amount = int.tryParse(amountString);
      if (amount == null) {
        debugPrint('QR App: Invalid amount format: $amountString');
        return null;
      }

      // Extract terminal_id from query params
      final terminalId = queryParams['terminal_id'];

      final paymentRequest = PaymentRequest(
        requestId: requestId,
        amount: amount,
        currency: currency,
        tender: tender ?? 'UNKNOWN',
        terminalId: terminalId,
      );

      debugPrint('QR App: Parsed payment request: ${paymentRequest.toJson()}');
      return paymentRequest;
    } catch (e) {
      debugPrint('QR App: Error parsing payment request: $e');
      return null;
    }
  }

  Future<void> _handlePaymentRequest(PaymentRequest paymentRequest) async {
    debugPrint(
        'QR App: Processing payment request: ${paymentRequest.toJson()}',
    );

    setState(() {
      _paymentRequest = paymentRequest;
    });

    await _loadWebView();
  }

  Future<void> _loadWebView() async {
    if (_paymentRequest == null) {
      debugPrint('QR App: Cannot load WebView - no payment request');
      return;
    }

    // Build query parameters
    final queryParams = <String, String>{
      'request_id': _paymentRequest!.requestId,
      'amount': _paymentRequest!.amount.toString(),
      'currency': _paymentRequest!.currency,
      'tender': _paymentRequest!.tender,
    };

    // Add terminal_id if available
    if (_paymentRequest!.terminalId != null) {
      queryParams['terminal_id'] = _paymentRequest!.terminalId!;
    }

    final uri = Uri.parse('${Config.gwBaseUrl}/qr-display').replace(
      queryParameters: queryParams,
    );

    debugPrint('QR App: Loading WebView with URL: $uri');

    try {
      await _webViewController.loadRequest(uri);
      setState(() {
        _isInitialized = true;
      });
      debugPrint('QR App: WebView loaded successfully');
    } catch (e) {
      debugPrint('QR App: Error loading WebView: $e');
      _showError('Error loading payment QR: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Close',
            textColor: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  void _handlePaymentResult(String resultJson) {
    debugPrint('QR App: Received payment result: $resultJson');
    try {
      final result = json.decode(resultJson) as Map<String, dynamic>;
      final status = PaymentStatus.fromString(result['status'] ?? '');

      debugPrint('QR App: Parsed status: $status');

      _returnToBusinessApp(
        requestId: result['requestId'] ?? _paymentRequest?.requestId ?? '',
        status: status,
        transactionId: result['txnId'],
        amount: _paymentRequest?.amount ?? 0,
      );
    } catch (e) {
      debugPrint('QR App: Error handling payment result: $e');
      // Return with error status
      _returnToBusinessApp(
        requestId: _paymentRequest?.requestId ?? '',
        status: PaymentStatus.failed,
        amount: _paymentRequest?.amount ?? 0,
      );
    }
  }

  Future<void> _returnToBusinessApp({
    required String requestId,
    required PaymentStatus status,
    String? transactionId,
    required int amount,
  }) async {
    debugPrint('QR App: Returning to business app with status: $status');

    final success = await DeepLinkService.returnToBusinessApp(
      requestId: requestId,
      status: status,
      transactionId: transactionId,
      amount: amount,
      currency: _paymentRequest?.currency ?? 'JPY',
      tender: _paymentRequest?.tender ?? 'UNKNOWN',
      terminalId: _paymentRequest?.terminalId,
    );

    if (success) {
      debugPrint('QR App: Successfully returned to business app');
      // Small delay to ensure the deep link is processed
      await Future.delayed(const Duration(milliseconds: 500));

      // Pop this screen and return to home
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Exit app after returning to business app
      SystemNavigator.pop();
    } else {
      debugPrint('QR App: Failed to return to business app');
      _showError('Failed to return to business app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _onCancelPressed,
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          localizations.qrTitle,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        if (_paymentRequest != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '¥${_formatAmount(_paymentRequest!.amount)} ${_paymentRequest!.currency}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[800],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Loading indicator
            if (_isLoading) const LinearProgressIndicator(),

            // WebView
            Expanded(
              child: _isInitialized
                  ? WebViewWidget(controller: _webViewController)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading payment QR...'),
                        ],
                      ),
                    ),
            ),

            // Cancel button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onCancelPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(localizations.cancelPayment),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _onCancelPressed() {
    debugPrint('QR App: User cancelled payment');
    _returnToBusinessApp(
      requestId: _paymentRequest?.requestId ?? '',
      status: PaymentStatus.cancelled,
      amount: _paymentRequest?.amount ?? 0,
    );
  }
}
