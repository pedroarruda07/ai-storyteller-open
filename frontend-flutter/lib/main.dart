import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_flutter/pages/main_screen_navigation.dart';
import 'package:frontend_flutter/providers/locale_provider.dart';
import 'package:frontend_flutter/providers/showcase_provider.dart';
import 'package:frontend_flutter/providers/subscription_provider.dart';
import 'package:frontend_flutter/providers/theme_provider.dart';
import 'package:frontend_flutter/services/lifecycle_watcher.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:frontend_flutter/styles/app_style.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/story.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(StoryAdapter());
  MobileAds.instance.initialize();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isNew = prefs.getBool('isNew') ?? true;

  await Purchases.setup(dotenv.env['REVENUECAT_API_KEY']!);
  //await Purchases.setLogLevel(LOG_LEVEL.DEBUG);

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider( create: (_) => LocaleProvider()),
        ChangeNotifierProvider( create: (_) => ShowcaseProvider()),
        ChangeNotifierProvider( create: (_) => SubscriptionProvider()),
      ],
      child:LifecycleWatcher(
      child: MyApp(isNew: isNew))));
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  final bool isNew;

  const MyApp({super.key, required this.isNew});

  @override
  Widget build(BuildContext context) {
    return  Consumer4<ShowcaseProvider, ThemeProvider, LocaleProvider, SubscriptionProvider>(
        builder: (context, showcaseProvider, themeProvider, localeProvider, subscriptionProvider, child) {
          return MaterialApp(
            navigatorObservers: [routeObserver],
            locale: localeProvider.locale,
            title: 'InkFlow',
            theme: Styles.themeData(themeProvider.isDarkTheme, context),
            home: LoaderOverlay(child: MainScreen(showWelcome: isNew,)),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      );

  }
}
