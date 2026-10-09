import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/account_api.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/account_models.dart';
import '../utils/format_utils.dart';

/// Auth session: login token + account area (profile / dashboard / checkout).
class AuthSession extends ChangeNotifier {
  AuthSession._() {
    ApiClient.tokenProvider = () => token;
  }
  static final AuthSession instance = AuthSession._();

  static const _tokenKey = 'auth_token';
  static const _expiresAtKey = 'auth_expires_at';
  static const _userIdKey = 'auth_user_id';
  static const _nameKey = 'auth_name';
  static const _phoneKey = 'auth_phone';
  static const _emailKey = 'auth_email';
  static const _imageKey = 'auth_image';
  static const _userTypeKey = 'auth_user_type';

  final _accountApi = AccountApi();

  String? token;
  DateTime? expiresAt;
  String userId = '';
  String name = '';
  String phone = '';
  String email = '';
  String city = '';
  String address = '';
  String zipcode = '';
  String imageUrl = '';
  String userType = '';
  int? legacyStateId;
  int? legacyCityId;
  int wallet = 0;

  List<DashboardCourse> enrolledCourses = const [];
  List<DashboardOrder> orders = const [];
  List<DashboardWishlistItem> wishlist = const [];
  CheckoutDetails? checkoutDetails;
  bool accountLoading = false;
  String? accountError;

  /// Transient auth error (e.g. deep-link token exchange failure).
  String? authError;

  bool get isLoggedIn => token != null && token!.isNotEmpty && !_isExpired;
  bool get _isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  String get displayName =>
      isLoggedIn && name.isNotEmpty ? name : 'کاربر مهمان';
  String get walletFa => formatPriceFa(wallet);

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved == null || saved.isEmpty) return;

    final expiresMs = prefs.getInt(_expiresAtKey);
    if (expiresMs != null) {
      expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresMs);
      if (DateTime.now().isAfter(expiresAt!)) {
        await logout();
        return;
      }
    }

    token = saved;
    userId = prefs.getString(_userIdKey) ?? '';
    name = prefs.getString(_nameKey) ?? '';
    phone = prefs.getString(_phoneKey) ?? '';
    email = prefs.getString(_emailKey) ?? '';
    imageUrl = prefs.getString(_imageKey) ?? '';
    userType = prefs.getString(_userTypeKey) ?? '';
    notifyListeners();

    // Do not block splash on account APIs.
    unawaited(refreshAccount().catchError((_) {}));
  }

  void setAuthError(String? message) {
    authError = message;
    notifyListeners();
  }

  void clearAuthError() {
    if (authError == null) return;
    authError = null;
    notifyListeners();
  }

  Future<void> applyLogin(AuthLoginResult result) async {
    token = result.token;
    expiresAt = result.expiresIn > 0
        ? DateTime.now().add(Duration(seconds: result.expiresIn))
        : null;
    _applyUser(result.user);
    authError = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, result.token);
    if (expiresAt != null) {
      await prefs.setInt(_expiresAtKey, expiresAt!.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_expiresAtKey);
    }
    await _persistProfileFields(prefs);
    notifyListeners();

    unawaited(refreshAccount().catchError((_) {}));
  }

  void _applyUser(AuthUser user) {
    userId = user.id;
    name = user.name;
    phone = user.phone;
    email = user.email;
    imageUrl = user.imageUrl;
    userType = user.userType;
  }

  void _applyProfile(AccountProfile profile) {
    if (profile.id.isNotEmpty) userId = profile.id;
    if (profile.name.isNotEmpty) name = profile.name;
    if (profile.phone.isNotEmpty) phone = profile.phone;
    email = profile.email;
    if (profile.imageUrl.isNotEmpty) imageUrl = profile.imageUrl;
    if (profile.userType.isNotEmpty) userType = profile.userType;
    address = profile.address;
    zipcode = profile.zipcode;
    legacyStateId = profile.legacyStateId ?? legacyStateId;
    legacyCityId = profile.legacyCityId ?? legacyCityId;
    wallet = profile.wallet;
  }

  Future<void> _persistProfileFields(SharedPreferences prefs) async {
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_imageKey, imageUrl);
    await prefs.setString(_userTypeKey, userType);
  }

  Future<void> refreshAccount() async {
    if (!isLoggedIn) return;

    accountLoading = true;
    accountError = null;
    notifyListeners();

    try {
      final profileResult = await _safeAccountCall(_accountApi.fetchProfile);
      final dashResult = await _safeAccountCall(_accountApi.fetchDashboard);
      final checkoutResult =
          await _safeAccountCall(_accountApi.fetchCheckoutDetails);

      if (profileResult.$2?.statusCode == 401 ||
          dashResult.$2?.statusCode == 401 ||
          checkoutResult.$2?.statusCode == 401) {
        await logout();
        accountError = 'نشست منقضی شده؛ دوباره وارد شوید';
        return;
      }

      final profile = profileResult.$1;
      final dashboard = dashResult.$1;
      final checkout = checkoutResult.$1;

      if (profile is AccountProfile) {
        _applyProfile(profile);
        final prefs = await SharedPreferences.getInstance();
        await _persistProfileFields(prefs);
      }
      if (dashboard is AccountDashboard) {
        orders = dashboard.orders;
        enrolledCourses = dashboard.enrollments;
        wishlist = dashboard.wishlist;
      }
      if (checkout is CheckoutDetails) {
        checkoutDetails = checkout;
        if (checkout.city.isNotEmpty) city = checkout.city;
        if (checkout.legacyStateId != null) {
          legacyStateId = checkout.legacyStateId;
        }
        if (checkout.legacyCityId != null) {
          legacyCityId = checkout.legacyCityId;
        }
      }

      if (profile == null && dashboard == null && checkout == null) {
        accountError = profileResult.$2?.message ??
            dashResult.$2?.message ??
            checkoutResult.$2?.message ??
            'خطا در دریافت اطلاعات حساب';
      } else {
        accountError = null;
      }
    } catch (e) {
      accountError = e.toString();
    } finally {
      accountLoading = false;
      notifyListeners();
    }
  }

  Future<(T?, ApiException?)> _safeAccountCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      return (await call(), null);
    } on ApiException catch (e) {
      return (null, e);
    } catch (e) {
      return (null, ApiException(e.toString()));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    if (!isLoggedIn) return;
    try {
      final profile = await _accountApi.updateProfile(
        name: fields['name']?.toString() ?? name,
        email: fields['email']?.toString(),
        address: fields['address']?.toString(),
        zipcode: fields['zipcode']?.toString() ?? fields['postalCode']?.toString(),
        legacyStateId: fields['legacyStateId'] as int? ?? legacyStateId,
        legacyCityId: fields['legacyCityId'] as int? ?? legacyCityId,
      );
      _applyProfile(profile);
      city = fields['city']?.toString() ?? city;
      final prefs = await SharedPreferences.getInstance();
      await _persistProfileFields(prefs);
      notifyListeners();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await logout();
      }
      rethrow;
    }
  }

  Future<void> saveCheckoutDetails(Map<String, dynamic> fields) async {
    if (!isLoggedIn) return;

    final stateId = fields['legacyStateId'] as int?;
    final cityId = fields['legacyCityId'] as int?;
    if (stateId == null || cityId == null) {
      throw const ApiException('استان و شهر را انتخاب کنید');
    }

    try {
      final saved = await _accountApi.saveCheckoutDetails(
        name: fields['name']?.toString() ??
            fields['fullName']?.toString() ??
            name,
        phone: fields['phone']?.toString() ?? phone,
        address: fields['address']?.toString() ?? '',
        zipcode: fields['postalCode']?.toString() ??
            fields['zipcode']?.toString() ??
            '',
        legacyStateId: stateId,
        legacyCityId: cityId,
        requireShipping: fields['requireShipping'] != false,
      );

      checkoutDetails = saved.copyWithTitles(
        province: fields['province']?.toString() ?? saved.province,
        city: fields['city']?.toString() ?? saved.city,
      );
      if (checkoutDetails!.city.isNotEmpty) {
        city = checkoutDetails!.city;
      }
      legacyStateId = checkoutDetails!.legacyStateId ?? stateId;
      legacyCityId = checkoutDetails!.legacyCityId ?? cityId;
      if (checkoutDetails!.fullName.isNotEmpty) {
        name = checkoutDetails!.fullName;
      }
      if (checkoutDetails!.phone.isNotEmpty) {
        phone = checkoutDetails!.phone;
      }
      notifyListeners();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await logout();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    token = null;
    expiresAt = null;
    userId = '';
    name = '';
    phone = '';
    email = '';
    city = '';
    address = '';
    zipcode = '';
    imageUrl = '';
    userType = '';
    legacyStateId = null;
    legacyCityId = null;
    wallet = 0;
    enrolledCourses = const [];
    orders = const [];
    wishlist = const [];
    checkoutDetails = null;
    accountLoading = false;
    accountError = null;
    authError = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiresAtKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_imageKey);
    await prefs.remove(_userTypeKey);
    notifyListeners();
  }
}

extension on CheckoutDetails {
  CheckoutDetails copyWithTitles({String? province, String? city}) {
    return CheckoutDetails(
      fullName: fullName,
      phone: phone,
      province: province ?? this.province,
      city: city ?? this.city,
      address: address,
      postalCode: postalCode,
      legacyStateId: legacyStateId,
      legacyCityId: legacyCityId,
      requireShipping: requireShipping,
      nameLocked: nameLocked,
      phoneLocked: phoneLocked,
    );
  }
}
