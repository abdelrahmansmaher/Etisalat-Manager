import 'package:flutter/material.dart';

import '../../core/widgets/page_scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Training placeholder (v1.1 per doc 00 §6).
class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PageScaffold(
      title: l10n.trainingTitle,
      children: [
        PlaceholderPanel(
          icon: Icons.school_outlined,
          title: l10n.contentComingSoon,
          body: l10n.trainingPlaceholderBody,
        ),
      ],
    );
  }
}
