import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/auth_api.dart';
import '../state/auth_session.dart';

/// Handles `cakeyousef://auth` (and later payment) deep links.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final _appLinks = AppLinks();
  final _authApi = AuthApi();
  StreamSubscription<Uri>? _sub;
  bool _started = false;
  bool _handlingAuth = false;

  /// True while exchanging a login code (UI can show a spinner).
  bool get isExchanging => _handlingAuth;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        unawaited(_handle(initial));
      }
    } catch (e) {
      debugPrint('DeepLink initial: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handle(uri)),
      onError: (Object e) => debugPrint('DeepLink stream: $e'),
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;
  }

  Future<void> _handle(Uri uri) async {
    if (uri.scheme != 'cakeyousef') return;

    switch (uri.host) {
      case 'auth':
        await _handleAuth(uri);
      case 'payment':
        // Checkout deep link — wired when payment API is connected.
        debugPrint('Payment deep link: $uri');
      default:
        debugPrint('Unhandled deep link: $uri');
    }
  }

  Future<void> _handleAuth(Uri uri) async {
    final code = uri.queryParameters['code']?.trim() ?? '';
    if (code.isEmpty) {
      debugPrint('Auth deep link missing code: $uri');
      return;
    }
    if (_handlingAuth) return;

    _handlingAuth = true;
    try {
      final result = await _authApi.exchangeToken(code);
      await AuthSession.instance.applyLogin(result);
    } on ApiException catch (e) {
      debugPrint('Auth exchange failed: $e');
      AuthSession.instance.setAuthError(e.message);
    } catch (e) {
      debugPrint('Auth exchange error: $e');
      AuthSession.instance.setAuthError('ورود از مرورگر ناموفق بود');
    } finally {
      _handlingAuth = false;
    }
  }

  /// Authorize URL for Option A (open with url_launcher / Custom Tabs).
  Future<String> resolveAuthorizeUrl() {
    return _authApi.fetchAuthorizeUrl(redirectUri: ApiConfig.authRedirectUri);
  }
}
