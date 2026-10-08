import '../models/account_models.dart';
import 'api_client.dart';

class AccountApi {
  AccountApi({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<AccountProfile> fetchProfile() async {
    final body = await _client.get('/account/profile', auth: true);
    return AccountProfile.fromJson(body);
  }

  Future<AccountProfile> updateProfile({
    required String name,
    String? email,
    String? address,
    String? zipcode,
    int? legacyStateId,
    int? legacyCityId,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (address != null) 'address': address.trim(),
      if (zipcode != null) 'zipcode': zipcode.trim(),
      if (legacyStateId != null) 'legacyStateId': legacyStateId,
      if (legacyCityId != null) 'legacyCityId': legacyCityId,
    };
    final body =
        await _client.put('/account/profile', body: payload, auth: true);
    return AccountProfile.fromJson(body);
  }

  Future<AccountDashboard> fetchDashboard() async {
    final body = await _client.get('/account/dashboard', auth: true);
    return AccountDashboard.fromJson(body);
  }

  Future<CheckoutDetails> fetchCheckoutDetails() async {
    final body = await _client.get('/account/checkout-details', auth: true);
    return CheckoutDetails.fromJson(body);
  }

  Future<CheckoutDetails> saveCheckoutDetails({
    required String name,
    required String phone,
    required String address,
    required String zipcode,
    required int legacyStateId,
    required int legacyCityId,
    bool requireShipping = true,
  }) async {
    final body = await _client.put(
      '/account/checkout-details',
      body: {
        'name': name.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'zipcode': zipcode.trim(),
        'legacyStateId': legacyStateId,
        'legacyCityId': legacyCityId,
        'requireShipping': requireShipping,
      },
      auth: true,
    );
    return CheckoutDetails.fromJson(body);
  }
}
