import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/account_models.dart';
import '../state/auth_session.dart';
import '../data/local_locations.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_sheet.dart';
import '../utils/network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = AuthSession.instance;
      if (s.isLoggedIn) s.refreshAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthSession.instance,
      builder: (context, _) {
        final s = AuthSession.instance;
        return RefreshIndicator(
          color: AppColors.gold600,
          onRefresh: () async {
            if (s.isLoggedIn) await s.refreshAccount();
          },
          child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'ناحیه کاربری',
              style: GoogleFonts.vazirmatn(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.dark900,
              ),
            ),
            const SizedBox(height: 14),
            _ProfileHero(session: s),
            const SizedBox(height: 16),
            if (!s.isLoggedIn) ...[
              _AuthButtons(
                onLogin: () => showAuthSheet(context),
                onRegister: () =>
                    showAuthSheet(context, mode: AuthSheetMode.register),
              ),
              const SizedBox(height: 16),
            ],
            _WalletCard(session: s),
            const SizedBox(height: 16),
            if (s.isLoggedIn) ...[
              if (s.accountError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    s.accountError!,
                    style: GoogleFonts.vazirmatn(
                      color: const Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              _SectionTitle('اطلاعات کاربر'),
              const SizedBox(height: 8),
              _InfoCard(session: s),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.local_shipping_outlined,
                title: 'اطلاعات ارسال',
                onTap: () => _openCheckoutDetails(context),
              ),
              const SizedBox(height: 16),
            ],
            _SectionTitle('دوره‌های من'),
            const SizedBox(height: 8),
            _MyCoursesCard(session: s),
            if (s.isLoggedIn && s.orders.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionTitle('سفارش‌ها'),
              const SizedBox(height: 8),
              _OrdersCard(orders: s.orders),
            ],
            if (s.isLoggedIn) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await s.logout();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('از حساب خارج شدید',
                          style: GoogleFonts.vazirmatn(),
                          textAlign: TextAlign.center),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'خروج از حساب',
                  style: GoogleFonts.vazirmatn(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        );
      },
    );
  }

  Future<void> _openCheckoutDetails(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutDetailsScreen()),
    );
  }
}

class CheckoutDetailsScreen extends StatefulWidget {
  const CheckoutDetailsScreen({super.key});

  @override
  State<CheckoutDetailsScreen> createState() => _CheckoutDetailsScreenState();
}

class _CheckoutDetailsScreenState extends State<CheckoutDetailsScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _postal = TextEditingController();

  List<LocationItem> _provinces = [];
  List<LocationItem> _cities = [];
  LocationItem? _province;
  LocationItem? _city;
  bool _nameLocked = false;
  bool _phoneLocked = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _postal.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final session = AuthSession.instance;
    try {
      if (session.isLoggedIn) {
        await session.refreshAccount();
      }
      final existing = session.checkoutDetails;
      _name.text = existing?.fullName.isNotEmpty == true
          ? existing!.fullName
          : session.name;
      _phone.text = existing?.phone.isNotEmpty == true
          ? existing!.phone
          : session.phone;
      _address.text = existing?.address ?? '';
      _postal.text = existing?.postalCode ?? '';
      _nameLocked = existing?.nameLocked ?? false;
      _phoneLocked = existing?.phoneLocked ?? false;

      _provinces = await LocalLocations.fetchProvinces();
      final stateId = existing?.legacyStateId ?? session.legacyStateId;
      final cityId = existing?.legacyCityId ?? session.legacyCityId;

      if (stateId != null) {
        _province = _provinces.cast<LocationItem?>().firstWhere(
              (p) => p?.legacyId == stateId,
              orElse: () => null,
            );
        if (_province == null && existing?.province.isNotEmpty == true) {
          _province = _provinces.cast<LocationItem?>().firstWhere(
                (p) => p?.title == existing!.province,
                orElse: () => null,
              );
        }
        if (_province != null) {
          _cities = await LocalLocations.fetchCities(_province!.legacyId);
          _city = _cities.cast<LocationItem?>().firstWhere(
                (c) => c?.legacyId == cityId,
                orElse: () => null,
              );
          if (_city == null && existing?.city.isNotEmpty == true) {
            _city = _cities.cast<LocationItem?>().firstWhere(
                  (c) => c?.title == existing!.city,
                  orElse: () => null,
                );
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onProvince(LocationItem? value) async {
    setState(() {
      _province = value;
      _city = null;
      _cities = [];
    });
    if (value == null) return;
    final cities = await LocalLocations.fetchCities(value.legacyId);
    if (!mounted) return;
    setState(() => _cities = cities);
  }

  Future<void> _save() async {
    if (_province == null || _city == null) {
      setState(() => _error = 'استان و شهر را انتخاب کنید');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AuthSession.instance.saveCheckoutDetails({
        'fullName': _name.text.trim(),
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'province': _province!.title,
        'city': _city!.title,
        'address': _address.text.trim(),
        'postalCode': _postal.text.trim(),
        'legacyStateId': _province!.legacyId,
        'legacyCityId': _city!.legacyId,
        'requireShipping': true,
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('اطلاعات ارسال',
            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark900,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold600))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _boxField(_name, 'نام گیرنده', enabled: !_nameLocked),
                _boxField(_phone, 'موبایل', enabled: !_phoneLocked),
                _dropdown<LocationItem>(
                  label: 'استان',
                  value: _province,
                  items: _provinces,
                  labelOf: (e) => e.title,
                  onChanged: _onProvince,
                ),
                _dropdown<LocationItem>(
                  label: 'شهر',
                  value: _city,
                  items: _cities,
                  labelOf: (e) => e.title,
                  onChanged: (v) => setState(() => _city = v),
                ),
                _boxField(_address, 'آدرس', maxLines: 3),
                _boxField(_postal, 'کد پستی'),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!,
                        style: GoogleFonts.vazirmatn(color: Colors.red)),
                  ),
                GestureDetector(
                  onTap: _saving ? null : _save,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _saving ? 'در حال ذخیره...' : 'ذخیره',
                      style: GoogleFonts.vazirmatn(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _boxField(
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.creamDark,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextField(
        controller: c,
        enabled: enabled,
        maxLines: maxLines,
        style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.vazirmatn(color: AppColors.warm400),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.vazirmatn(color: AppColors.warm400),
          border: InputBorder.none,
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(labelOf(e))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final AuthSession session;
  const _ProfileHero({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.goldGlow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            backgroundImage: session.imageUrl.isNotEmpty
                ? NetworkImage(session.imageUrl)
                : null,
            child: session.imageUrl.isNotEmpty
                ? null
                : session.isLoggedIn
                    ? Text(
                        session.name.isNotEmpty
                            ? String.fromCharCode(session.name.runes.first)
                            : 'ک',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_rounded,
                        color: Colors.white, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.displayName,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.isLoggedIn
                      ? session.phone
                      : 'برای دسترسی کامل وارد شوید',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthButtons extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  const _AuthButtons({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Btn(label: 'ورود', filled: true, onTap: onLogin)),
        const SizedBox(width: 10),
        Expanded(child: _Btn(label: 'ثبت‌نام', filled: false, onTap: onRegister)),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: filled ? AppColors.goldGradient : null,
          color: filled ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: AppColors.gold300),
          boxShadow: AppColors.cardShadow,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.vazirmatn(
            fontWeight: FontWeight.w800,
            color: filled ? Colors.white : AppColors.gold700,
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final AuthSession session;
  const _WalletCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.gold600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('کیف پول',
                    style: GoogleFonts.vazirmatn(
                        fontWeight: FontWeight.w800, color: AppColors.dark900)),
                Text(
                  session.isLoggedIn
                      ? '${session.walletFa} تومان'
                      : 'برای شارژ وارد شوید',
                  style: GoogleFonts.vazirmatn(
                      fontSize: 12, color: AppColors.warm400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AuthSession session;
  const _InfoCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _InfoRow(label: 'نام', value: session.name),
          _InfoRow(label: 'موبایل', value: session.phone),
          _InfoRow(
              label: 'ایمیل',
              value: session.email.isEmpty ? '—' : session.email),
          _InfoRow(
            label: 'شهر',
            value: session.city.isEmpty ? '—' : session.city,
            last: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;
  const _InfoRow({required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                    color: AppColors.warm200.withValues(alpha: 0.7))),
      ),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.vazirmatn(
                  color: AppColors.warm400, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.vazirmatn(
                  fontWeight: FontWeight.w800, color: AppColors.dark900)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold600),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800)),
              ),
              const Icon(Icons.chevron_left_rounded, color: AppColors.warm400),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyCoursesCard extends StatelessWidget {
  final AuthSession session;
  const _MyCoursesCard({required this.session});

  @override
  Widget build(BuildContext context) {
    if (!session.isLoggedIn) {
      return _EmptyBox(
          text: 'پس از ورود، دوره‌های خریداری‌شده اینجا نمایش داده می‌شود.');
    }
    if (session.accountLoading && session.enrolledCourses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.gold600),
        ),
      );
    }
    if (session.accountError != null && session.enrolledCourses.isEmpty) {
      return _EmptyBox(
        text: 'خطا در دریافت دوره‌ها: ${session.accountError}',
      );
    }
    final courses = session.enrolledCourses;
    if (courses.isEmpty) {
      return const _EmptyBox(text: 'هنوز دوره‌ای خریداری نکرده‌اید.');
    }
    return Column(
      children: courses
          .map(
            (c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: c.imageUrl.isNotEmpty
                          ? AppNetworkImage(
                              url: c.imageUrl,
                              width: 44,
                              height: 44,
                            )
                          : const ColoredBox(
                              color: AppColors.gold50,
                              child: Icon(Icons.school_outlined,
                                  color: AppColors.gold600),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                          fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _OrdersCard extends StatelessWidget {
  final List<DashboardOrder> orders;
  const _OrdersCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < orders.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i == orders.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(
                            color: AppColors.warm200.withValues(alpha: 0.7))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(orders[i].title,
                        style: GoogleFonts.vazirmatn(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                  Text(orders[i].status,
                      style: GoogleFonts.vazirmatn(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Text(
        text,
        style: GoogleFonts.vazirmatn(
            color: AppColors.warm400, fontSize: 13, height: 1.6),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.vazirmatn(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.dark900,
      ),
    );
  }
}
