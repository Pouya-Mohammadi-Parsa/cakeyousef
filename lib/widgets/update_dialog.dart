import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/version_checker.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateCheckResult result,
}) async {
  if (!result.needsUpdate || result.remote == null) return;

  final remote = result.remote!;
  final force = result.kind == UpdateKind.force;

  await showDialog<void>(
    context: context,
    barrierDismissible: !force,
    builder: (dialogContext) {
      return PopScope(
        canPop: !force,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            force ? 'بروزرسانی ضروری' : 'نسخه جدید آماده است',
            style: AppFonts.vazirmatn(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.dark900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                remote.message.isNotEmpty
                    ? remote.message
                    : 'نسخه جدید با بهبودها آماده است.',
                style: AppFonts.vazirmatn(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.dark700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'نسخه فعلی: ${result.currentVersion}  |  جدید: ${remote.latestVersion}',
                style: AppFonts.vazirmatn(
                  fontSize: 12,
                  color: AppColors.warm400,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'بعداً',
                  style: AppFonts.vazirmatn(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warm400,
                  ),
                ),
              ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await _openDownload(remote.downloadUrl);
                if (force) return;
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'بروزرسانی',
                style: AppFonts.vazirmatn(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _openDownload(String url) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
