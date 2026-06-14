import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/app_state.dart';
import 'screens/inicio_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/onboarding_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.carregarDados();
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    Widget home;
    if (appState.onboardingCompleto) {
      home = const InicioScreen();
    } else if (appState.idiomaSelecionado) {
      home = const OnboardingScreen();
    } else {
      home = const LanguageSelectionScreen();
    }

    return MaterialApp(
      key: ValueKey(appState.idioma),
      title: '',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      locale: Locale(appState.idioma.split('_')[0], appState.idioma.split('_')[1]),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: appState.corPrimaria,
        colorScheme: ColorScheme.dark(
          primary: appState.corPrimaria,
          secondary: appState.corPrimaria,
          surface: Colors.black,
          onPrimary: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appState.corPrimaria,
          foregroundColor: Colors.black,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: appState.corPrimaria,
          thumbColor: appState.corPrimaria,
          inactiveTrackColor: Colors.white24,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(appState.corPrimaria),
          checkColor: WidgetStateProperty.all(Colors.black),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: appState.corPrimaria),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: home,
    );
  }
}