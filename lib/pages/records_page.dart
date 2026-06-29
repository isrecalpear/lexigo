/// Records/statistics page (planned feature).
///
/// TODO: Implement learning statistics dashboard with the following features:
/// - Daily/weekly/monthly review streaks
/// - Words learned per language chart
/// - Review accuracy (Easy/Good/Hard/Again breakdown)
/// - Time spent learning graph
/// - FSRS retention rate visualization
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/l10n/app_localizations.dart';

/// Placeholder for records/learning statistics page.
///
/// TODO: Replace this placeholder with full statistics implementation.
class RecordsPicker extends StatefulWidget {
  const RecordsPicker({super.key});

  @override
  State<RecordsPicker> createState() => _RecordsPickerState();
}

class _RecordsPickerState extends State<RecordsPicker> {
  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual statistics UI
    return Scaffold(
      body: Center(child: Text(AppLocalizations.of(context)!.recordsBuilding)),
    );
  }
}
