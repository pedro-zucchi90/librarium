import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de cores inspirada em Hollow Knight e Devil May Cry
  static const Color blackDeep = Color(0xFF0A0A0A);        // Preto profundo (fundo principal)
  static const Color blackSteel = Color(0xFF121212);       // Preto aço (fundo secundário)
  static const Color graySteel = Color(0xFF2C2C2C);       // Cinza aço (cards, menus)
  static const Color grayMedium = Color(0xFF3A3A3A);       // Cinza médio (bordas)
  static const Color whiteBroken = Color(0xFFE6E6E6);      // Branco quebrado (textos principais)
  static const Color whiteSilver = Color(0xFFF5F5F5);      // Prata (destaques)
  static const Color redCrimson = Color(0xFF8B0000);       // Vermelho carmesim (ações, poder)
  static const Color redBlood = Color(0xFFB22222);         // Vermelho sangue (destaques)
  static const Color blueEthereal = Color(0xFF3B60E4);     // Azul etéreo (magias, calma)
  static const Color blueMystic = Color(0xFF5A7FFF);       // Azul místico (estados especiais)
  static const Color goldAged = Color(0xFFC0A060);         // Dourado envelhecido (conquistas)
  static const Color goldNoble = Color(0xFFD4AF37);        // Dourado nobre (prestígio)
  static const Color greenSuccess = Color(0xFF4CAF50);     // Verde sucesso
  static const Color orangeWarning = Color(0xFFFF9800);    // Laranja aviso
  static const Color purpleLegendary = Color(0xFF9C27B0);  // Roxo lendário

  // Gradientes temáticos
  static const LinearGradient gradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [blackDeep, blackSteel, Color(0xFF1A1A2E)],
  );

  static const LinearGradient gradientRed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [redCrimson, redBlood],
  );

  static const LinearGradient gradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blueEthereal, blueMystic],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldAged, goldNoble],
  );

  // Tema escuro principal
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Cores principais
      colorScheme: const ColorScheme.dark(
        primary: redCrimson,
        secondary: blueEthereal,
        tertiary: goldAged,
        surface: graySteel,
        background: blackDeep,
        error: redBlood,
        onPrimary: whiteBroken,
        onSecondary: whiteBroken,
        onTertiary: blackDeep,
        onSurface: whiteBroken,
        onBackground: whiteBroken,
        onError: whiteBroken,
      ),

      // Scaffold
      scaffoldBackgroundColor: blackDeep,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: whiteBroken,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: whiteBroken),
        actionsIconTheme: const IconThemeData(color: whiteBroken),
      ),

      // Textos
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: whiteBroken,
          letterSpacing: 3,
          shadows: [
            Shadow(
              color: redCrimson.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: whiteBroken,
          letterSpacing: 2,
        ),
        displaySmall: GoogleFonts.cinzel(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: whiteBroken,
          letterSpacing: 1,
        ),
        headlineLarge: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: whiteBroken,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: whiteBroken,
        ),
        headlineSmall: GoogleFonts.cormorantGaramond(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteBroken,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: whiteBroken,
        ),
        titleMedium: GoogleFonts.cormorantGaramond(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: whiteBroken,
        ),
        titleSmall: GoogleFonts.cormorantGaramond(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: whiteBroken,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: whiteBroken,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: whiteBroken,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: whiteBroken,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: whiteBroken,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: whiteBroken,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: whiteBroken,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: graySteel,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: grayMedium, width: 1),
        ),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: redCrimson,
          foregroundColor: whiteBroken,
          elevation: 8,
          shadowColor: redCrimson.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: blueEthereal,
          side: const BorderSide(color: blueEthereal, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: blueMystic,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: graySteel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grayMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grayMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blueEthereal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: redBlood, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: whiteBroken.withOpacity(0.7)),
        hintStyle: GoogleFonts.inter(color: whiteBroken.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: graySteel,
        selectedItemColor: redCrimson,
        unselectedItemColor: whiteBroken.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: redCrimson,
        foregroundColor: whiteBroken,
        elevation: 12,
        shape: CircleBorder(),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: grayMedium,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: redCrimson,
        linearTrackColor: grayMedium,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return redCrimson;
          }
          return grayMedium;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return redCrimson.withOpacity(0.3);
          }
          return grayMedium.withOpacity(0.3);
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: graySteel,
        selectedColor: redCrimson.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(color: whiteBroken),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: grayMedium),
        ),
      ),
    );
  }

  // Tema claro (alternativo)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: redCrimson,
        secondary: blueEthereal,
        tertiary: goldAged,
        surface: whiteSilver,
        background: whiteBroken,
        error: redBlood,
        onPrimary: whiteBroken,
        onSecondary: whiteBroken,
        onTertiary: blackDeep,
        onSurface: blackDeep,
        onBackground: blackDeep,
        onError: whiteBroken,
      ),

      scaffoldBackgroundColor: whiteBroken,
      
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: blackDeep,
          letterSpacing: 3,
        ),
        displayMedium: GoogleFonts.cinzel(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: blackDeep,
          letterSpacing: 2,
        ),
        displaySmall: GoogleFonts.cinzel(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: blackDeep,
          letterSpacing: 1,
        ),
        headlineLarge: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: blackDeep,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: blackDeep,
        ),
        headlineSmall: GoogleFonts.cormorantGaramond(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: blackDeep,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: blackDeep,
        ),
        titleMedium: GoogleFonts.cormorantGaramond(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: blackDeep,
        ),
        titleSmall: GoogleFonts.cormorantGaramond(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: blackDeep,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: blackDeep,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: blackDeep,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: blackDeep,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: blackDeep,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: blackDeep,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: blackDeep,
        ),
      ),
    );
  }

  // Estilos de texto customizados
  static TextStyle get titleGothic => GoogleFonts.cinzel(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: whiteBroken,
    letterSpacing: 2,
    shadows: [
      Shadow(
        color: redCrimson.withOpacity(0.5),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static TextStyle get subtitleElegant => GoogleFonts.cormorantGaramond(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: whiteBroken.withOpacity(0.8),
    fontStyle: FontStyle.italic,
  );

  static TextStyle get bodyClean => GoogleFonts.inter(
    fontSize: 16,
    color: whiteBroken,
    height: 1.5,
  );

  static TextStyle get captionMystic => GoogleFonts.inter(
    fontSize: 12,
    color: blueMystic,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Sombras customizadas
  static List<BoxShadow> get shadowRed => [
    BoxShadow(
      color: redCrimson.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowBlue => [
    BoxShadow(
      color: blueEthereal.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowGold => [
    BoxShadow(
      color: goldAged.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowDark => [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 15,
      spreadRadius: 1,
      offset: const Offset(0, 3),
    ),
  ];
}
