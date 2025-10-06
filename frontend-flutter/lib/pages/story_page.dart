import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import '../utils/db_utils.dart';
import '../data/story.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoryPage extends StatefulWidget {
  final Story story;
  final bool isSaved;
  final bool isFirst;

  const StoryPage(
      {super.key,
      required this.story,
      required this.isSaved,
      this.isFirst = false});

  @override
  State<StatefulWidget> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late bool isSaved;
  final GlobalKey _info = GlobalKey();

  @override
  void initState() {
    super.initState();
    isSaved = widget.isSaved;

    if (widget.isFirst){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) {
          ShowCaseWidget.of(context).startShowCase([_info]);
        }
      }
      );
    }
  }

  void _showSavingSnackbar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xffbaa4f5),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _confirmationDialog() {
    var translations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(translations.remove_story, style: const TextStyle(fontSize: 25)),
      content: Text(translations.sure_remove),
      contentPadding: const EdgeInsets.all(20),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(translations.cancel)),
        TextButton(
            onPressed: () async {
              await removeStory(widget.story);
              _showSavingSnackbar(translations.story_removed);
              setState(() {
                isSaved = false;
              });
              Navigator.of(context).pop();
            },
            child: Text(translations.yes)),
      ],
      elevation: 5,
    );
  }

  Future<void> _downloadStoryAsPdf() async {
    final pdf = pw.Document();

    pw.ImageProvider? imageProvider;
    if (widget.story.photo != null) {
      try {
        img.Image? decodedImage = img.decodeImage(widget.story.photo!);
        if (decodedImage != null) {
          final pngBytes = img.encodePng(decodedImage);
          imageProvider = pw.MemoryImage(Uint8List.fromList(pngBytes));
        } else {
          imageProvider = null;
        }
      } catch (e) {
        imageProvider = null;
      }
    } else {
      imageProvider = null;
    }

    final fontRegular = await PdfGoogleFonts.montserratLight();
    final fontBold = await PdfGoogleFonts.montserratBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          List<pw.Widget> content = [];

          content.add(
            pw.Center(
              child: pw.Text(
                widget.story.title,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 24,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          );
          content.add(pw.SizedBox(height: 20));
          if (imageProvider != null) {
            content.add(
              pw.Center(
                child: pw.Image(
                  imageProvider,
                  width: 200,
                  height: 200,
                ),
              ),
            );
            content.add(pw.SizedBox(height: 20));
          }
          content.add(
            pw.Paragraph(
              text: widget.story.text,
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 14,
              ),
            ),
          );
          return content;
        },
      ),
    );

    final fileName = '${widget.story.title}.pdf';
    await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
  }

  Future<void> _handleMenuSelection(String value) async {
    var translations = AppLocalizations.of(context)!;
    switch (value) {
      case 'bookmark':
        if (isSaved) {
          try {
            showDialog(
                context: context, builder: (context) => _confirmationDialog());
          } catch (e) {
            _showSavingSnackbar("${translations.failed_remove} ${translations.try_again}");
          }
        } else {
          try {
            await saveStory(widget.story);
            _showSavingSnackbar(translations.story_added);
            setState(() {
              isSaved = true;
            });
          } catch (e) {
            _showSavingSnackbar("${translations.failed_save} ${translations.try_again}");
          }
        }
        break;
      case 'download':
        await _downloadStoryAsPdf();
        break;
      case 'copy':
        ClipboardData data = ClipboardData(
            text: "${widget.story.title}\n\n${widget.story.text}");
        await Clipboard.setData(data);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var translations = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(75),
            child: Container(
                height: 100,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AppBar(
                  leadingWidth: 50,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  actions: [Showcase(
                    showArrow: false,
                    targetBorderRadius: const BorderRadius. all(Radius. circular(10)),
                    key: _info,
                    title: translations.story_options,
                    description: translations.story_options_desc,
                    child:
                     PopupMenuButton<String>(
                        position: PopupMenuPosition.under,
                        onSelected: _handleMenuSelection,
                        icon:  const Icon(Icons.more_horiz_outlined),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'bookmark',
                            child: ListTile(
                              horizontalTitleGap: 7,
                              leading: isSaved
                                  ? const Icon(
                                      Icons.bookmark_remove,
                                      size: 25,
                                    )
                                  : const Icon(Icons.bookmark_add_outlined,
                                      size: 25),
                              title: Text(
                                isSaved ? translations.remove_story : translations.save_story,
                                style: const TextStyle(
                                    fontSize: 12, letterSpacing: .5),
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'download',
                            child: ListTile(
                              horizontalTitleGap: 7,
                              leading: const Icon(Icons.sim_card_download_outlined,
                                  size: 25),
                              title: Text(translations.export_pdf,
                                  style: const TextStyle(
                                      fontSize: 12, letterSpacing: .5)),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'copy',
                            child: ListTile(
                              horizontalTitleGap: 7,
                              leading: const Icon(Icons.copy, size: 22),
                              title: Text(translations.copy,
                                  style: const TextStyle(
                                      fontSize: 12, letterSpacing: .5)),
                            ),
                          ),
                        ],
                      ),

                  )],
                  centerTitle: true,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        widget.story.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        minFontSize: 14,
                        maxFontSize: 20,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ))),
        body: Scrollbar(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          widget.story.photo == null
                              ? const Icon(Icons.image)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.memory(widget.story
                                      .photo!)
                                  ),
                          const SizedBox(
                            height: 30,
                          ),
                          Text(widget.story.text,
                              style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: .5)))
                        ])))));
  }
}
