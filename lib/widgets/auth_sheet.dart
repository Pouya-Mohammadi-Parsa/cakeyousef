import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/auth_api.dart';
import '../services/deep_link_service.dart';
import '../state/auth_session.dart';
import '../theme/app_colors.dart';

enum AuthSheetMode { browser, password }

Future<void> showAuthSheet(
  BuildContext context, {
  AuthSheetMode mode = AuthSheetMode.browser,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AuthSheet(initialMode: mode),
  );
}

class _AuthSheet extends StatefulWidget {
  final AuthSheetMode initialMode;
  const _AuthSheet({required this.initialMode});

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  late AuthSheetMode _mode;
  bool _busy = false;
  String? _error;
  bool _obscure = true;
  bool _waitingBrowser = false;

  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _api = AuthApi();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    AuthSession.instance.addListener(_onSession);
  }

  @override
  void dispose() {
    AuthSession.instance.removeListener(_onSession);
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onSession() {
    final session = AuthSession.instance;
    if (!mounted) return;

    if (session.isLoggedIn) {
      Navigator.pop(context);
      return;
    }

    final err = session.authError;
    if (err != null && err.isNotEmpty) {
      setState(() {
        _error = err;
        _busy = false;
        _waitingBrowser = false;
      });
    }
  }

  Future<void> _openBrowserLogin() async {
    setState(() {
      _busy = true;
      _error = null;
      _waitingBrowser = false;
    });
    try {
      final url = await DeepLinkService.instance.resolveAuthorizeUrl();
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        throw const FormatException('امکان باز کردن مرورگر نیست');
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _waitingBrowser = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _busy = false;
        _waitingBrowser = false;
      });
    }
  }

  Future<void> _submitLogin() async {
    final id = _identifier.text.trim();
    final pass = _password.text;
    if (id.isEmpty || pass.isEmpty) {
      setState(() => _error = 'شماره موبایل / ایمیل و رمز عبور را وارد کنید');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await _api.login(identifier: id, password: pass);
      await AuthSession.instance.applyLogin(result);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warm200,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _mode == AuthSheetMode.browser ? 'ورود به حساب' : 'ورود با رمز',
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.dark900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _mode == AuthSheetMode.browser
                  ? 'ورود، ثبت‌نام و بازیابی رمز از طریق سایت انجام می‌شود'
                  : 'شماره موبایل یا ایمیل و رمز عبور را وارد کنید',
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                fontSize: 12.5,
                height: 1.6,
                color: AppColors.dark700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            if (_error != null) ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (_mode == AuthSheetMode.browser) ...[
              if (_waitingBrowser) ...[
                Text(
                  'پس از ورود در مرورگر، به‌طور خودکار به اپ برمی‌گردید.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.gold700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _openBrowserLogin,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login_rounded, size: 22),
                  label: Text(
                    _waitingBrowser
                        ? 'باز کردن مجدد مرورگر'
                        : 'ورود / ثبت‌نام در مرورگر',
                    style: GoogleFonts.vazirmatn(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                          _mode = AuthSheetMode.password;
                          _error = null;
                          _waitingBrowser = false;
                        }),
                child: Text(
                  'ورود مستقیم با رمز عبور',
                  style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700),
                ),
              ),
            ] else ...[
              TextField(
                controller: _identifier,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'شماره موبایل یا ایمیل',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  fillColor: AppColors.creamDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _busy ? null : _submitLogin(),
                decoration: InputDecoration(
                  hintText: 'رمز عبور',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.creamDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _busy ? null : _submitLogin,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'ورود',
                          style: GoogleFonts.vazirmatn(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                          _mode = AuthSheetMode.browser;
                          _error = null;
                        }),
                child: Text(
                  'بازگشت به ورود از مرورگر',
                  style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
