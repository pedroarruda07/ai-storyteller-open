import 'package:flutter/material.dart';
import 'package:frontend_flutter/components/custom_appbar.dart';
import 'package:provider/provider.dart';
import '../components/ads/banner_ad.dart';
import '../components/story_card.dart';
import '../providers/subscription_provider.dart';
import '../utils/db_utils.dart';
import '../data/story.dart';
import '../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with RouteAware {
  List<Story> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadSavedStories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute? modalRoute = ModalRoute.of(context);

    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadSavedStories();
  }

  Future<void> _loadSavedStories() async {
    List<Story> stories = await getAllStories();
    setState(() {
      _stories = stories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    int width = MediaQuery.of(context).size.width.toInt();
    bool isSubscribed = Provider.of<SubscriptionProvider>(context).isSubscribed;

    return Scaffold(
        appBar:  MyAppBar(title: localizations.my_stories),
        body: Stack(children: [
           ListView.builder(
             padding: const EdgeInsets.only(top: 5),
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                return StoryCard(story: _stories[index]);
              },
            ),
          isSubscribed ? Container() : Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdWidget(width: width,),
          )
        ]));
  }
}
