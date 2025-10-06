import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/manage_sub_page.dart';
import 'package:frontend_flutter/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/ads/banner_ad.dart';
import '../components/custom_appbar.dart';
import '../components/subscription_dialog.dart';
import '../providers/locale_provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/languages_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  void _showLanguageDialog() {

    var localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    List<Locale> locales = AppLocalizations.supportedLocales;
    List<String> countryNames = getLanguagesName(locales);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(localizations.select_language, style: Theme.of(context).textTheme.bodyLarge,),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: locales.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: CountryFlag.fromCountryCode(getFlagCode(locales[index].languageCode), shape: const Circle(), height: 30, width: 30,),
                  title: Text(countryNames[index], style: locales[index] == localeProvider.locale ? const TextStyle(fontWeight: FontWeight.bold) : const TextStyle(fontWeight: FontWeight.normal)),
                  trailing: locales[index] == localeProvider.locale ? const Icon(Icons.circle): const Icon(Icons.circle_outlined),
                  onTap: () {
                      localeProvider.setLocale(locales[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _openTermsAndConditions() async {
    var localizations = AppLocalizations.of(context)!;
    final Uri url = Uri.parse('https://aistorygenerator-2024.web.app/terms_of_service.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.error_launch)),
      );
      }
    }
  }

  void _openPrivacyPolicy() async {
    var localizations = AppLocalizations.of(context)!;
    final Uri url = Uri.parse('https://aistorygenerator-2024.web.app/privacy_policy.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.error_launch)),
        );
      }
    }
  }

  void _sendFeedback() async {
    var localizations = AppLocalizations.of(context)!;
    final Uri url = Uri.parse('https://forms.gle/MmBPzdRk4Zgqqtww9');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(localizations.error_launch)),
        );
      }
    }
  }

  void _manageSubscription() {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

    if (subscriptionProvider.isSubscribed) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SubscriptionManagementPage()
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const SubscriptionPopup(canRestore: true,);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    var localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    var translations = AppLocalizations.of(context)!;
    int width = MediaQuery.of(context).size.width.toInt();
    bool isSubscribed = Provider.of<SubscriptionProvider>(context).isSubscribed;

    return Scaffold(
      appBar: MyAppBar(
        title: translations.settings,
      ),
      body: Stack( children: [ListView(
        children: [
          const SizedBox(height: 30,),
          Padding(padding: const EdgeInsets.only(left: 20),
              child: Text(translations.general, style: const TextStyle(color: Colors.grey, fontSize: 14))),
          const SizedBox(height: 5,),
          const Divider(indent: 20, endIndent: 20, height: 0,),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(translations.dark_mode),
            trailing: Transform.scale(
              scaleY: 0.8,
              scaleX: 0.9,
              child: Switch(
                value: themeProvider.isDarkTheme,
                onChanged: (bool value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
          ),
          const Divider(indent: 20, endIndent: 20,height: 0),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(translations.language),
            trailing: CountryFlag.fromCountryCode(getFlagCode(localeProvider.locale.languageCode), shape: const Circle(), height: 30, width: 30,),
            onTap: _showLanguageDialog,
          ),
          const Divider(indent: 20, endIndent: 20,height: 0),
          ListTile(
              leading: const Icon(Icons.star_border),
              title: isSubscribed ? Text(translations.manage_subscription) : Text(translations.subscription),
              onTap: _manageSubscription,
              trailing: const Icon(Icons.arrow_forward_ios)),
          const Divider(indent: 20, endIndent: 20,height: 0),

          const SizedBox(height: 40,),

          Padding(padding: const EdgeInsets.only(left: 20),
              child: Text(translations.about, style: const TextStyle(color: Colors.grey, fontSize: 14))),
          const SizedBox(height: 5,),
          const Divider(indent: 20, endIndent: 20, height: 0,),
          ListTile(
            leading: const Icon(Icons.text_snippet_outlined),
              title: Text(translations.terms_conditions),
              onTap: _openTermsAndConditions,
              trailing: const Icon(Icons.arrow_forward_ios)),
          const Divider(indent: 20, endIndent: 20,height: 0),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: Text(translations.privacy_policy),
            onTap: _openPrivacyPolicy,
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          const Divider(indent: 20, endIndent: 20,height: 0),
          ListTile(
            leading: const Icon(Icons.mail_outline),
              title: Text(translations.contact_us),
              onTap: _sendFeedback,
              trailing: const Icon(Icons.arrow_forward_ios)),
          const Divider(indent: 20, endIndent: 20,height: 0),
        ],
      ),
        isSubscribed ? Container() : Align(
          alignment: Alignment.bottomCenter,
          child: BannerAdWidget(width: width,),
        )
        ])
    );
  }
}
