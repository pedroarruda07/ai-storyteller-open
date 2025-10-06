import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlertDialogWidget extends StatefulWidget {
  final String message;
  final String title;

  const AlertDialogWidget({
    super.key,
    required this.message,
    required this.title
  });

  @override
  _AlertDialogWidgetState createState() => _AlertDialogWidgetState();
}

class _AlertDialogWidgetState extends State<AlertDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var translations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.title, style: const TextStyle(fontSize: 25)),
      content: Text(widget.message),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(translations.close))
      ],
      elevation: 5,
    );
  }
}
