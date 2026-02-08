// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:lexigo/l10n/app_localizations.dart';

class RecordsPicker extends StatefulWidget {
  const RecordsPicker({super.key});

  @override
  State<RecordsPicker> createState() => _RecordsPickerState();
}

class _RecordsPickerState extends State<RecordsPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(context.l10n.recordsBuilding)),
    );
  }
}
