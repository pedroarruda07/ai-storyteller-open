import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_flutter/components/ads/rewarded_ad.dart';
import 'package:frontend_flutter/components/alert_dialog.dart';
import 'package:frontend_flutter/components/custom_appbar.dart';
import 'package:frontend_flutter/components/custom_slider.dart';
import 'package:frontend_flutter/pages/story_page.dart';
import 'package:frontend_flutter/utils/languages_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../components/ads/banner_ad.dart';
import '../components/ads/interstitial_ad.dart';
import '../components/mydropdown_button.dart';
import '../data/story.dart';
import '../main.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:translator/translator.dart';
import '../providers/locale_provider.dart';
import '../providers/showcase_provider.dart';
import '../providers/subscription_provider.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware {
  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();
  final RewardedAdManager _rewardedAdManager = RewardedAdManager();
  String _genre = 'Fantasy';
  String _theme = 'Love';
  bool _isForKids = false;
  final TextEditingController _plot = TextEditingController();
  final TextEditingController _setting = TextEditingController();
  List<TextEditingController> _characterControllers = [TextEditingController()];
  List<String> _characters = [];
  int _selectedOption = 1;
  int _currentCover = 0;
  static final List<String> _styles = ["cartoon", "fantasy", "realistic", "painting", "anime", "comics", "cyberpunk"];
  final ScrollController _scrollController = ScrollController();
  final CarouselSliderController _carouselController =  CarouselSliderController();
  final translator = GoogleTranslator();

  //bool generateImage = false;

  @override
  void initState() {
    super.initState();
    _interstitialAdManager.loadInterstitialAd();
    _rewardedAdManager.loadRewardedAd();
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
    _interstitialAdManager.dispose();
    _rewardedAdManager.dispose();

    routeObserver.unsubscribe(this);
    _plot.dispose();
    _setting.dispose();
    for (var controller in _characterControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    //this method will be called when the user returns to this page by popping the previous one
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _genre = 'Fantasy';
      _theme = 'Love';
      _isForKids = false;
      _selectedOption = 1;
      _currentCover = 0;
      _carouselController.jumpToPage(0);
      _characters = [];
      _plot.clear();
      _setting.clear();
      _characterControllers = [TextEditingController()];
      _scrollController.animateTo(0,
          duration: const Duration(seconds: 1), curve: Curves.ease);
    });
  }

  void _showAd() {
    bool isSubscribed = Provider.of<SubscriptionProvider>(context, listen: false).isSubscribed;
    if (!isSubscribed){
      //logic removed for open repo
    }
  }

  Future<String> _translate(String text) async {
    if (text.trim() != '') {
      var localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      String language = localeProvider.locale.languageCode;
      if (language != 'en') {
        var translation =
            await translator.translate(text, from: language, to: 'en');
        return translation.toString();
      }
    }
    return text;
  }


  //names are being translated, probably dont use
  Future<void> _translateCharacterControllers() async {

    _characters = await Future.wait(
      _characterControllers.map((controller) async {
        String translatedName = await _translate(controller.text);
        return translatedName;
      }),
    );

    _characters = _characters.where((name) => name.isNotEmpty).toList();
  }


  Future<Uint8List?> _generateImage(String prompt) async {
    try {
      String url = dotenv.env['IMAGE_API_URL']!;

      Map<String, dynamic> requestBody = {
        'prompt': prompt,
        'style': _styles[_currentCover]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
      }
    } catch (e) {
      //
    }
    return null;
  }

  //send story creation request
  void _createStory() async {
    var localizations = AppLocalizations.of(context);
    try {
      context.loaderOverlay.show();
      _showAd();

      String url = dotenv.env['STORY_API_URL']!;

      //await _translateCharacterControllers();
      _characters = _characterControllers
          .map((controller) => controller.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();


      String plot = await _translate(_plot.text);
      String setting = await _translate(_setting.text);

      String language = '';
      if(mounted){
        language = getCurrentLanguage(context);
      }

      Map<String, dynamic> requestBody = {
        'characters': _characters,
        'plot': plot,
        'theme': _theme,
        'genre': _genre,
        'words': getWords(),
        'forKids': _isForKids,
        'setting': setting,
        'language': language
      };

      http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonList = json.decode(response.body);
        final Map<String, dynamic> story = json.decode(jsonList["story"]);

        if (mounted) {
          Uint8List? imageBytes = await _generateImage(story["Prompt"]);
          Story newStory = Story.fromJson(story, imageBytes);

          final showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
          bool showShowcase = false;

          if (!showcaseProvider.hasShownStoryShowcase) {
            showShowcase = true;
            await showcaseProvider.setShowcaseShown();
          }

          if(mounted) {
            context.loaderOverlay.hide();

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ShowCaseWidget(
                        builder: (context) =>
                            StoryPage(story: newStory,
                                isSaved: false,
                                isFirst: showShowcase),)
              ),
            );
          }
        }
      } else {
        if (mounted) {
          context.loaderOverlay.hide();
          showDialog(
              context: context,
              builder: (context) => AlertDialogWidget(
                  title: localizations!.error_wrong,
                  message: "${response.body}\n${localizations.try_again}"));
        }
      }
    } catch (e) {

      if (mounted) {
        context.loaderOverlay.hide();
        showDialog(
            context: context,
            builder: (context) => AlertDialogWidget(
                title: localizations!.error_wrong,
                message:
                    localizations.error_internet));
      }
    }
  }

  int getWords() {
    switch (_selectedOption) {
      case 0:
        return 200;
      case 1:
        return 500;
      case 2:
        return 1000;
      default:
        return 200;
    }
  }

  void _addCharacterField() {
    var localizations = AppLocalizations.of(context);
    setState(() {
      switch (_selectedOption) {
        case 2:
          if (_characterControllers.length >= 5) {
            _showErrorSnackbar(localizations!.max_characters);
            return;
          }
        default:
          if (_characterControllers.length >= 3) {
            _showErrorSnackbar(
                localizations!.increase_size);
            return;
          }
      }
      _characterControllers.add(TextEditingController());
    });
  }

  void _removeCharacterField(int index) {
    setState(() {
      if (_characterControllers.length > 1) {
        _characterControllers[index].dispose();
        _characterControllers.removeAt(index);
      }
    });
  }

  void _showErrorSnackbar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        backgroundColor: const Color(0xffbaa4f5),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    int width = MediaQuery.of(context).size.width.toInt();
    bool isSubscribed = Provider.of<SubscriptionProvider>(context).isSubscribed;

    return Scaffold(
        appBar: MyAppBar(
          title: localizations!.create_story_title,
          action: true,
        ),
        body: Stack(children: [
              Center(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10,),
                       Text(
                          "${localizations.select} ${localizations.style}",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                       /*
                        Checkbox(value: generateImage, onChanged: (newValue) {
                          setState(() {
                            generateImage = newValue!;
                          });
                        }), */
                        ////////////////////
                        const SizedBox(
                          height: 15,
                        ),
                        _buildCarousel(),
                        const SizedBox(height: 10),
                        CustomSliderWidget(
                          selectedValue: _selectedOption,
                          onValueChanged: (int newValue) {
                            setState(() {
                              _selectedOption = newValue;
                              if (newValue < 2) {
                                if (_characterControllers.length == 4) {
                                  _characterControllers.removeLast();
                                }
                                if (_characterControllers.length == 5) {
                                  _characterControllers.removeLast();
                                  _characterControllers.removeLast();
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        MyDropdownButton(
                          title: localizations.genre,
                          themeOrGenre: false,
                          selectedValue: _genre,
                          onValueChanged: (String? newGenre) {
                            setState(() {
                              _genre = newGenre!;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        MyDropdownButton(
                          title: localizations.theme,
                          themeOrGenre: true,
                          selectedValue: _theme,
                          onValueChanged: (String? newTheme) {
                            setState(() {
                              _theme = newTheme!;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Text(
                              "${localizations.characters} ${localizations.optional}",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 10,),
                            TextButton.icon(
                              onPressed: _addCharacterField,
                              icon: const Icon(
                                Icons.add,
                                size: 15,
                              ),
                              label: Text(
                                localizations.add_more,
                                style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5,),
                        //character input fields with dynamic addition
                        ..._buildCharacterFields(),
                        const SizedBox(height: 20),
                        Text(
                          "${localizations.story_plot} ${localizations.optional}",
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _plot,
                          maxLines: 3,
                          maxLength: 200,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText:
                            localizations.description,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "${localizations.story_setting} ${localizations.optional}",
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _setting,
                          maxLines: 2,
                          maxLength: 100,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: localizations.describe,
                            helperText:
                                "Ex: ${localizations.forest}",
                            helperMaxLines: 2,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                           // const SizedBox(width: 4.0),
                            Text(localizations.kids),
                            const SizedBox(width: 2,),
                            Transform.translate(
                              offset: const Offset(2, -8),
                              child: Tooltip(
                                showDuration: const Duration(seconds: 10),
                                triggerMode: TooltipTriggerMode.tap,
                                message: localizations.kids_info,
                                child: const Icon(
                                  Icons.info_outline,
                                  size: 17.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Checkbox(
                              value: _isForKids,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _isForKids = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _createStory,
                            child: Text(localizations.create_button),
                          ),
                        ),
                        isSubscribed ? const SizedBox(height: 20) : const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
              isSubscribed ? Container() : Align(
                alignment: Alignment.bottomCenter,
                child: BannerAdWidget(width: width,),
              )
            ]));
  }

  List<Widget> _buildCharacterFields() {
    var localizations = AppLocalizations.of(context);

    return List<Widget>.generate(_characterControllers.length, (index) {
      return Column(children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                maxLength: 30,
                controller: _characterControllers[index],
                decoration: index != 0
                    ? InputDecoration(
                        hintText: '${localizations!.character} ${index + 1}', counterText: '')
                    : InputDecoration(
                        helperText: "Ex: Ivar, ${localizations!.the_dragon}",
                        hintText: localizations.main_character,
                        counterText: ''),
              ),
            ),
            const SizedBox(width: 10),
            index != 0
                ? IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () => _removeCharacterField(index),
                  )
                : const SizedBox(
                    width: 48,
                  )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ]);
    });
  }

  Map<String, String> getTranslatedStyles(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return {
      'cartoon': localizations.cartoon,
      'fantasy': localizations.fantasy,
      'realistic': localizations.realistic,
      'painting': localizations.painting,
      'anime': localizations.anime,
      'comics': localizations.comics,
      'cyberpunk': localizations.cyberpunk,
    };
  }

  Widget _buildCarousel() {
    final translatedStyles = getTranslatedStyles(context);

    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        enlargeFactor: 0.3,
        height: 150.0,
        enlargeCenterPage: true,
        viewportFraction: 0.35,
        onPageChanged: (index, reason) {
          setState(() {
            _currentCover = index;
          });
        },
      ),
      items: _styles.map((styleKey) {
        int index = _styles.indexOf(styleKey);

        return Builder(
          builder: (BuildContext context) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/covers/$styleKey.png",
                    scale: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  textAlign: TextAlign.center,
                  translatedStyles[styleKey]!,
                  style: (index == _currentCover)
                      ? Theme.of(context).textTheme.headlineSmall
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }
}
