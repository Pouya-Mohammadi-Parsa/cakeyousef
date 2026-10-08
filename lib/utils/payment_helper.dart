import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/site_config.dart';

Future<void> openWebsiteCheckout(
  BuildContext context,
  String url, {
  String errorMessage = 'امکان باز کردن صفحه پرداخت نیست',
}) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: GoogleFonts.vazirmatn(),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final uri = Uri.parse(
    trimmed.startsWith('http') ? trimmed : Uri.encodeFull(trimmed),
  );
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: GoogleFonts.vazirmatn(),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

Future<void> checkoutCourseOnWebsite(
  BuildContext context, {
  String? slug,
  String? fallbackUrl,
}) {
  final url = (fallbackUrl != null && fallbackUrl.isNotEmpty)
      ? fallbackUrl
      : SiteConfig.courseCheckoutUrl(slug);
  return openWebsiteCheckout(
    context,
    url,
    errorMessage: 'امکان باز کردن صفحه دوره برای پرداخت نیست',
  );
}

Future<void> checkoutProductOnWebsite(
  BuildContext context, {
  required String productId,
}) {
  return openWebsiteCheckout(
    context,
    SiteConfig.productCheckoutUrl(productId),
    errorMessage: 'امکان باز کردن صفحه محصول برای پرداخت نیست',
  );
}
