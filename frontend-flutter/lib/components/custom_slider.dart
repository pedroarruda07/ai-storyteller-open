import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomSliderWidget extends StatefulWidget {
  final int selectedValue;
  final Function(int) onValueChanged;

  const CustomSliderWidget({super.key, required this.selectedValue,
      required this.onValueChanged});
  @override
  State<CustomSliderWidget> createState() => _CustomSliderWidgetState();
}

class _CustomSliderWidgetState extends State<CustomSliderWidget> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.selectedValue.toDouble();
  }

  @override
  void didUpdateWidget(covariant CustomSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() {
        _currentSliderValue = widget.selectedValue.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var translations = AppLocalizations.of(context)!;
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                translations.set_story_size, style: Theme.of(context).textTheme.labelMedium
              ),
            ),
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: Colors.white,
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                  ),
                  child: Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 2,
                    divisions: 2,
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                      widget.onValueChanged(value.toInt());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            translations.short,
                            style: TextStyle(
                              fontWeight: _currentSliderValue == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: _currentSliderValue == 0 ? 16 : 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '~200 ${translations.words}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600], // Lighter color for description
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            translations.medium,
                            style: TextStyle(
                              fontWeight: _currentSliderValue == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: _currentSliderValue == 1 ? 16 : 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '~500 ${translations.words}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            translations.long,
                            style: TextStyle(
                              fontWeight: _currentSliderValue == 2
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: _currentSliderValue == 2 ? 16 : 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '~1000 ${translations.words}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ],
      );
  }
}

