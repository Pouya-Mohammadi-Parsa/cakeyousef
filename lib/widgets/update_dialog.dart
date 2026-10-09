import 'package:flutter/material.dart';

import '../services/app_updater.dart';
import '../services/version_checker.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/format_utils.dart';

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
        child: _UpdateDialogBody(
          result: result,
          remote: remote,
          force: force,
        ),
      );
    },
  );
}

class _UpdateDialogBody extends StatefulWidget {
  const _UpdateDialogBody({
    required this.result,
    required this.remote,
    required this.force,
  });

  final UpdateCheckResult result;
  final AppVersionInfo remote;
  final bool force;

  @override
  State<_UpdateDialogBody> createState() => _UpdateDialogBodyState();
}

class _UpdateDialogBodyState extends State<_UpdateDialogBody> {
  bool _busy = false;
  double? _progress;
  String? _error;

  Future<void> _update() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _progress = 0;
      _error = null;
    });
    try {
      await AppUpdater().downloadAndInstall(
        widget.remote.downloadUrl,
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _progress = p);
        },
      );
      if (!widget.force && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = toFaDigits(widget.result.currentVersion);
    final latest = toFaDigits(widget.remote.latestVersion);

    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.force ? 'بروزرسانی ضروری' : 'نسخه جدید آماده است',
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
            widget.remote.message.isNotEmpty
                ? widget.remote.message
                : 'نسخه جدید با بهبودها آماده است.',
            style: AppFonts.vazirmatn(
              fontSize: 14,
              height: 1.6,
              color: AppColors.dark700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'نسخه فعلی: $current',
            style: AppFonts.vazirmatn(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.dark700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'نسخه جدید: $latest',
            style: AppFonts.vazirmatn(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.gold700,
            ),
          ),
          if (_progress != null) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: _progress,
              color: AppColors.gold500,
              backgroundColor: AppColors.gold50,
            ),
            const SizedBox(height: 6),
            Text(
              'در حال دانلود… ${toFaDigits('${((_progress ?? 0) * 100).round()}')}٪',
              style: AppFonts.vazirmatn(
                fontSize: 11.5,
                color: AppColors.warm400,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: AppFonts.vazirmatn(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (!widget.force)
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
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
          onPressed: _busy ? null : _update,
          child: Text(
            _busy ? 'لطفاً صبر کنید…' : 'دانلود و بروزرسانی',
            style: AppFonts.vazirmatn(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
