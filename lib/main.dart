import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/qr_display_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription? _linkSubscription;
  late AppLinks _appLinks;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await _handleDeepLink(initialLink.toString());
      }
    } catch (e) {
      debugPrint('QR App: Error getting initial link: $e');
    }

    // Listen for incoming links (when app is already running)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) async {
        await _handleDeepLink(uri.toString());
      },
      onError: (err) {
        debugPrint('QR App: Deep link error: $err');
      },
    );
  }

  Future<void> _handleDeepLink(String link) async {
    debugPrint('QR App: Received deep link: $link');

    if (link.startsWith(Config.deepLinkPaymentRequest)) {
      // Navigate to QR display screen
      final context = _navigatorKey.currentContext;
      if (context != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QRDisplayScreen(deepLink: link),
          ),
        );
      }
    } else {
      debugPrint('QR App: Invalid deep link scheme');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'MPS QR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
