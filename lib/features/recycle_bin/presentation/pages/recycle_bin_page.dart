// lib/features/recycle_bin/presentation/pages/recycle_bin_page.dart

import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/responsive_scaffold.dart';

class RecycleBinPage extends StatelessWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ResponsiveScaffold(
      currentPath: AppRouter.recycleBinPath,
      title: Text(
        localizations.navRecycleBin,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
      ),
      body: const AppEmptyState(
        icon: Icons.delete_outline_rounded,
        message: 'Your Recycle Bin is empty.\nDeleted documents are permanently cleaned up.',
      ),
    );
  }
}
