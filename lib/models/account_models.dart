import '../api/api_config.dart';

class DashboardCourse {
  final String id;
  final String slug;
  final String title;
  final String imageUrl;

  const DashboardCourse({
    required this.id,
    required this.slug,
    required this.title,
    required this.imageUrl,
  });

  factory DashboardCourse.fromJson(Map<String, dynamic> json) {
    final course = json['course'];
    final nested = course is Map ? Map<String, dynamic>.from(course) : json;
    final id = '${nested['id'] ?? json['id'] ?? json['courseId'] ?? ''}';
    final slug =
        '${nested['slug'] ?? json['slug'] ?? nested['id'] ?? id}';
    final title = (nested['title'] ??
            nested['name'] ??
            json['title'] ??
            json['name'] ??
            'دوره')
        .toString();
    final image = ApiConfig.mediaUrl(
      (nested['image'] ??
              nested['thumbnail'] ??
              nested['cover'] ??
              json['image'] ??
              json['thumbnail'])
          ?.toString(),
    );
    return DashboardCourse(
      id: id,
      slug: slug,
      title: title,
      imageUrl: image,
    );
  }
}

class DashboardOrder {
  final String id;
  final String title;
  final String status;
  final int amount;

  const DashboardOrder({
    required this.id,
    required this.title,
    required this.status,
    required this.amount,
  });

  factory DashboardOrder.fromJson(Map<String, dynamic> json) {
    final id = '${json['id'] ?? json['orderId'] ?? ''}';
    final title = (json['title'] ??
            json['label'] ??
            json['description'] ??
            json['code'] ??
            'سفارش')
        .toString();
    final status = (json['status'] ?? json['state'] ?? '—').toString();
    return DashboardOrder(
      id: id,
      title: title,
      status: status,
      amount: _asInt(json['amount'] ?? json['total'] ?? json['price']),
    );
  }
}

class DashboardWishlistItem {
  final String id;
  final String title;
  final String imageUrl;
  final String kind;

  const DashboardWishlistItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.kind,
  });

  factory DashboardWishlistItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final course = json['course'];
    final nested = product is Map
        ? Map<String, dynamic>.from(product)
        : course is Map
            ? Map<String, dynamic>.from(course)
            : json;
    return DashboardWishlistItem(
      id: '${nested['id'] ?? json['id'] ?? ''}',
      title: (nested['title'] ?? nested['name'] ?? json['title'] ?? 'آیتم')
          .toString(),
      imageUrl: ApiConfig.mediaUrl(
        (nested['image'] ?? nested['thumbnail'] ?? json['image'])?.toString(),
      ),
      kind: product is Map
          ? 'product'
          : course is Map
              ? 'course'
              : (json['type']?.toString() ?? 'item'),
    );
  }
}

class AccountProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String imageUrl;
  final String userType;
  final String address;
  final String zipcode;
  final int? legacyStateId;
  final int? legacyCityId;
  final int wallet;

  const AccountProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
    required this.userType,
    this.address = '',
    this.zipcode = '',
    this.legacyStateId,
    this.legacyCityId,
    this.wallet = 0,
  });

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final map = user is Map
        ? Map<String, dynamic>.from(user)
        : Map<String, dynamic>.from(json);
    return AccountProfile(
      id: '${map['id'] ?? ''}',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      imageUrl: ApiConfig.mediaUrl(map['image']?.toString()),
      userType: map['userType']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      zipcode: (map['zipcode'] ?? map['postalCode'])?.toString() ?? '',
      legacyStateId: _asIntOrNull(map['legacyStateId']),
      legacyCityId: _asIntOrNull(map['legacyCityId']),
      wallet: _asInt(map['wallet'] ?? json['wallet'] ?? map['balance']),
    );
  }
}

class AccountDashboard {
  final List<DashboardOrder> orders;
  final List<DashboardCourse> enrollments;
  final List<DashboardWishlistItem> wishlist;

  const AccountDashboard({
    required this.orders,
    required this.enrollments,
    required this.wishlist,
  });

  factory AccountDashboard.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> listOf(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    }

    return AccountDashboard(
      orders: listOf(json['orders']).map(DashboardOrder.fromJson).toList(),
      enrollments:
          listOf(json['enrollments']).map(DashboardCourse.fromJson).toList(),
      wishlist: listOf(json['wishlist'])
          .map(DashboardWishlistItem.fromJson)
          .toList(),
    );
  }
}

class CheckoutDetails {
  final String fullName;
  final String phone;
  final String province;
  final String city;
  final String address;
  final String postalCode;
  final int? legacyStateId;
  final int? legacyCityId;
  final bool requireShipping;
  final bool nameLocked;
  final bool phoneLocked;

  const CheckoutDetails({
    this.fullName = '',
    this.phone = '',
    this.province = '',
    this.city = '',
    this.address = '',
    this.postalCode = '',
    this.legacyStateId,
    this.legacyCityId,
    this.requireShipping = true,
    this.nameLocked = false,
    this.phoneLocked = false,
  });

  factory CheckoutDetails.fromJson(Map<String, dynamic> json) {
    final details = json['details'] ?? json['checkoutDetails'] ?? json;
    final map = details is Map
        ? Map<String, dynamic>.from(details)
        : Map<String, dynamic>.from(json);
    return CheckoutDetails(
      fullName: (map['name'] ?? map['fullName'])?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      province: (map['province'] ?? map['state'] ?? map['stateTitle'])
              ?.toString() ??
          '',
      city: (map['city'] ?? map['cityTitle'])?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      postalCode: (map['zipcode'] ?? map['postalCode'])?.toString() ?? '',
      legacyStateId: _asIntOrNull(map['legacyStateId']),
      legacyCityId: _asIntOrNull(map['legacyCityId']),
      requireShipping: map['requireShipping'] != false,
      nameLocked: map['nameLocked'] == true,
      phoneLocked: map['phoneLocked'] == true,
    );
  }
}

class LocationItem {
  final int legacyId;
  final String title;
  final int parentLegacyId;
  final int sortOrder;

  const LocationItem({
    required this.legacyId,
    required this.title,
    required this.parentLegacyId,
    required this.sortOrder,
  });
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}
