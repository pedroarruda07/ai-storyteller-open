import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primaryColor: isDarkTheme ? Colors.black : Colors.white,
      indicatorColor: isDarkTheme ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme
              ? const ColorScheme.dark().copyWith(background: const Color(0xff3B3B3B))
              : const ColorScheme.light().copyWith(background: const Color(0xffF1F5FB))),
      hoverColor: isDarkTheme
          ? const Color.fromARGB(202, 25, 26, 28)
          : const Color.fromARGB(224, 204, 195, 197),
      focusColor: isDarkTheme ? const Color(0xff0B2512) : const Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? const Color.fromARGB(255, 21, 21, 21) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkTheme ? const Color(0xff1b1c1c) : Colors.grey[200],
        selectedItemColor: isDarkTheme ? const Color(0xffbaa4f5) : Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkTheme ? const Color(0xff1b1c1c) : Colors.grey[200],
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        titleTextStyle: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: .5, color: isDarkTheme ? Colors.white : Colors.black ))
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: .5,
          color: isDarkTheme ? Colors.white : Colors.black,
        )),
        bodyMedium: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: .5,
          color: isDarkTheme ? Colors.white : Colors.black,
        )),
        bodySmall: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 12,
          color: isDarkTheme ? Colors.white : Colors.black,
        )),
        headlineLarge: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: .5,
          color: isDarkTheme ? Colors.white : Colors.black,
        )),
        labelMedium: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
          color: isDarkTheme ? Colors.white : Colors.black,
        )),
        headlineSmall: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: .5,
          color: isDarkTheme ? Colors.white : Colors.black,
        )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        labelStyle: TextStyle(
          fontSize: 14,
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        hintStyle: TextStyle(
          fontSize: 12,
          color: isDarkTheme ? Colors.grey : Colors.black54,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkTheme ? Colors.grey : Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkTheme ? Colors.grey : Colors.grey,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: isDarkTheme ? Colors.white : Colors.black,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.pressed)) {
              return isDarkTheme ? Colors.white : Colors.black; // Cor do ícone quando pressionado
            } else {
              return isDarkTheme ? Colors.white : Colors.black;
            }
          }),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        //backgroundColor: Color.fromARGB(255, 173, 20, 48),
        //hoverColor: Color.fromARGB(136, 173, 20, 48),
      ),
    );
  }
}