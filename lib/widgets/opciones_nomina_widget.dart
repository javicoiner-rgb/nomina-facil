import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

/// Toggle 12 / 14 pagas, reutilizado por varios modos.
class SelectorPagasWidget extends StatelessWidget {
  final int pagas;
  final ValueChanged<int> onChanged;

  const SelectorPagasWidget({
    super.key,
    required this.pagas,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.numeroPagas,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 12, label: Text(AppStrings.pagas12)),
            ButtonSegment(value: 14, label: Text(AppStrings.pagas14)),
          ],
          selected: {pagas},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}

/// Selector de hijos a cargo: 0, 1, 2, 3+.
class SelectorHijosWidget extends StatelessWidget {
  final int numHijos;
  final ValueChanged<int> onChanged;

  const SelectorHijosWidget({
    super.key,
    required this.numHijos,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.hijos,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (var i = 0; i <= AppConstants.maxHijos; i++)
              ChoiceChip(
                label: Text(i == AppConstants.maxHijos ? '$i+' : '$i'),
                selected: numHijos == i,
                onSelected: (_) => onChanged(i),
              ),
          ],
        ),
      ],
    );
  }
}
