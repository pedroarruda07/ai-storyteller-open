import 'package:flutter/material.dart';
import 'package:frontend_flutter/pages/home_page.dart';
import 'package:frontend_flutter/pages/library_page.dart';
import 'package:frontend_flutter/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/info_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  final bool showWelcome;

  const MainScreen({super.key, this.showWelcome = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<int> _navigationHistory = [];
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MyHomePage(),
      const LibraryPage(),
      const SettingsPage(),
    ];

    if (widget.showWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _showWelcomePopup();
            _updateIsNew();
          }
        });
      });
    }
  }

  void _updateIsNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isNew', false);
  }

  void _showWelcomePopup() {

    if (mounted) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Welcome',
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim1, anim2) {
          return const InfoDialogWidget();
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position:
                Tween(begin: const Offset(0, -1), end: const Offset(0, 0.01))
                    .animate(anim1),
            child: child,
          );
        },
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_navigationHistory.isEmpty) {
      return true;
    }

    setState(() {
      _selectedIndex = _navigationHistory.removeLast();
    });
    return false;
  }

  void _onBottomNavTap(int index) {
    setState(() {
      if (index == _selectedIndex) return;

      //add the current index to the history before changing tabs
      _navigationHistory.add(_selectedIndex);
      _selectedIndex = index;

      //handle the special case for HomeScreen (index 0)
      if (index == 0) {
        //if HomeScreen is already in the history, remove the most recent one except its first occurrence
        int homeIndexOccurrence = _navigationHistory.lastIndexOf(0);
        if (homeIndexOccurrence != -1 && homeIndexOccurrence != 0) {
          _navigationHistory.removeAt(homeIndexOccurrence);
        }
      } else {
        //remove the index from the history if it already exists (to prevent duplicates)
        _navigationHistory.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
            child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                showUnselectedLabels: true,
                selectedIconTheme: const IconThemeData(size: 22),
                unselectedIconTheme: const IconThemeData(size: 22),
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: localizations.home,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.library_books),
                    label: localizations.my_stories,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: localizations.settings,
                  ),
                ],
                onTap: _onBottomNavTap),
          ),
        ),
      ),
    );
  }
}
