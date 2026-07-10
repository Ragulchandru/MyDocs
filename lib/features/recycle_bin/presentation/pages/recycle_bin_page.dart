// lib/features/recycle_bin/presentation/pages/recycle_bin_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/responsive_scaffold.dart';

class RecycleBinPage extends StatelessWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentPath: AppRouter.recycleBinPath,
      title: Text(localizations.navRecycleBin),
      body: Center(
        child: Text(
          localizations.navRecycleBin,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
