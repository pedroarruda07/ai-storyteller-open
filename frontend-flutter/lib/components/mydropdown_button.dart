import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyDropdownButton extends StatefulWidget {
  //true for theme, false for genre
  final bool themeOrGenre;
  final String selectedValue;
  final Function(String) onValueChanged;
  final String title;

  const MyDropdownButton({
    super.key,
    required this.themeOrGenre,
    required this.selectedValue,
    required this.onValueChanged,
    required this.title,
  });

  @override
  MyDropdownButtonState createState() => MyDropdownButtonState();
}

class MyDropdownButtonState extends State<MyDropdownButton> {

  ScrollController controller = ScrollController(initialScrollOffset: 0.0,);

  Map<String, String> getTranslatedThemes(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return {
      'Random': localizations.random,
      'Love': localizations.theme1,
      'Family': localizations.theme2,
      'Friendship': localizations.theme3,
      'Hero': localizations.theme4,
      'Revenge': localizations.theme5,
      'Good vs evil': localizations.theme6,
      'Justice': localizations.theme7,
      'Power': localizations.theme8,
      'Faith': localizations.theme9,
    };
  }

  Map<String, String> getTranslatedGenres(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return {
      'Random': localizations.random,
      'Fantasy': localizations.genre1,
      'Action': localizations.genre2,
      'Mystery': localizations.genre3,
      'Sci-Fi': localizations.genre4,
      'Thriller': localizations.genre5,
      'Drama': localizations.genre6,
      'Romance': localizations.genre7,
    };
  }


  void _showCustomMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = button.localToGlobal(Offset.zero, ancestor: overlay);

    final translatedThemes = widget.themeOrGenre ? getTranslatedThemes(context) : getTranslatedGenres(context);

    final selectedValue = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + 20,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 200,
            ),
            child: Scrollbar(
              thumbVisibility: true,
              controller: controller,
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: translatedThemes.keys.map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(translatedThemes[value]!),
                      ),
                    );
                  }).toList(),
                ),
            ),
          ),
        ),
        )],
    );

    if (selectedValue != null) {
      widget.onValueChanged(selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translatedThemes = widget.themeOrGenre ? getTranslatedThemes(context) : getTranslatedGenres(context);
    var translations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${translations.select} ${widget.title}", style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _showCustomMenu(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(translatedThemes[widget.selectedValue]!),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
