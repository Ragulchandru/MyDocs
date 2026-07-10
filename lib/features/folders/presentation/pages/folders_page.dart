// lib/features/folders/presentation/pages/folders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/responsive_scaffold.dart';

class FoldersPage extends StatelessWidget {
  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentPath: AppRouter.foldersPath,
      title: Text(localizations.navFolders),
      body: Center(
        child: Text(
          localizations.navFolders,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
