import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoDialogWidget extends StatefulWidget {
  const InfoDialogWidget({super.key});

  @override
  State<InfoDialogWidget> createState() => _InfoDialogWidgetState();
}

class _InfoDialogWidgetState extends State<InfoDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var translations = AppLocalizations.of(context)!;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      title: Center(
          child: Text(
        '${translations.welcome_to} InkFlow!',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      )),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Divider(
              height: 10,
              thickness: 3,
            ),
            const SizedBox(height: 10),
            Center(
                child: Text(
              translations.welcome_description,
              style: const TextStyle(fontSize: 14),
            )),
            const SizedBox(height: 10),
            const Divider(
              height: 10,
              thickness: 3,
            ),
            const SizedBox(height: 10),
            Center(
                child: Text(
                  translations.welcome_description2,
                  style: const TextStyle(fontSize: 14),
                )),
            const SizedBox(height: 10),
            const Divider(
              height: 10,
              thickness: 3,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Center(
                  child: Text(
                translations.get_started,
                style: const TextStyle(fontSize: 18),
              )),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    );
  }
}
