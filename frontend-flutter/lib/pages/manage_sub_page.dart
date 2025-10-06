
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_flutter/components/subscription_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/subscription_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/languages_utils.dart';

class SubscriptionManagementPage extends StatelessWidget {
  const SubscriptionManagementPage({super.key});

  String _getSubscriptionManagementUrl() {
    // removed for open repo
  }

  Widget _confirmationDialog(BuildContext context) {
    var translations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(translations.cancel_subscription, style: const TextStyle(fontSize: 25)),
      content: Text(translations.confirm_cancel),
      contentPadding: const EdgeInsets.all(20),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(translations.cancel)),
        TextButton(
            onPressed: () async{
              final url = Uri.parse(_getSubscriptionManagementUrl());

              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    translations.error_launch,
                    textAlign: TextAlign.center,
                    style:
                    const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  backgroundColor: const Color(0xffbaa4f5),
                  duration: const Duration(seconds: 3),
                ));
              }
              Navigator.of(context).pop();
            },
            child: Text(translations.yes)),
      ],
      elevation: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    var translations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          translations.manage_subscription,
          style: TextStyle(color: Colors.white, fontSize: calculateFontSize(translations.manage_subscription)),
        ),
        //backgroundColor: Colors.purple,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3A0CA3), // Deep Purple
                Color(0xFF4E0D7A), // Dark Violet
                Color(0xFF2C003E), // Dark Plum
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 20,
              ),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3A0CA3), // Deep Purple
                          Color(0xFF4E0D7A), // Dark Violet
                          Color(0xFF2C003E), // Dark Plum
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translations.current_plan,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subscriptionProvider.plan != null
                              ? _formatPlanName(subscriptionProvider.plan!, context)
                              : 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          subscriptionProvider.expirationDate != null
                              ? '${translations.next_billing}\n${_formatDate(subscriptionProvider.expirationDate!, context)}'
                              : '${translations.next_billing} N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _showChangePlanDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  translations.change_plan,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context, builder: (context) => _confirmationDialog(context));
                },
                child: Text(
                  translations.cancel_subscription,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          )),
    );
  }

  String _formatDate(String dateString, BuildContext context) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      DateFormat formatter = DateFormat.yMMMMd(Localizations.localeOf(context).toString()).add_jm();
      return formatter.format(dateTime.toLocal());
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _formatPlanName(String planIdentifier, BuildContext context) {
    var translations = AppLocalizations.of(context)!;
    switch (planIdentifier) {
      case '':
        return translations.monthly_premium;
      case '':
        return translations.yearly_premium;
      default:
        return planIdentifier;
    }
  }

  void _showChangePlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const SubscriptionPopup(
          canRestore: false,
        );
      },
    );
  }
}
