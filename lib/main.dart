import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permisouttec/config/router/app_router.dart';
import 'package:permisouttec/constants/enviroment.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/services/firebase_service.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

TextTheme _buildAppTextTheme() {
  final base = GoogleFonts.interTextTheme(ThemeData(useMaterial3: true).textTheme);
  return base.copyWith(
    headlineSmall: GoogleFonts.montserrat(
      textStyle: base.headlineSmall,
      fontWeight: FontWeight.w600,
      color: LoginColors.deepEmerald,
    ),
    titleMedium: GoogleFonts.inter(
      textStyle: base.titleMedium,
      color: LoginColors.onSurfaceVariant,
    ),
    bodySmall: GoogleFonts.inter(
      textStyle: base.bodySmall,
      color: LoginColors.outline,
    ),
    labelLarge: GoogleFonts.montserrat(
      textStyle: base.labelLarge,
      fontWeight: FontWeight.w600,
      color: LoginColors.onPrimary,
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await FirebaseService.initialize();
  await initializeDateFormatting('es_MX');
  runApp(const ProviderScope(child: MyApp()));
}
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: Enviroment.appTitle,
      locale: const Locale('es', 'MX'),
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: LoginColors.deepEmerald,
          primary: LoginColors.deepEmerald,
          onPrimary: LoginColors.onPrimary,
          secondary: LoginColors.secondary,
          surface: LoginColors.paperWhite,
          onSurface: LoginColors.onSurface,
        ),
        scaffoldBackgroundColor: LoginColors.background,
        textTheme: _buildAppTextTheme(),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: LoginColors.paperWhite,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: LoginColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: LoginColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: LoginColors.deepEmerald,
              width: 2,
            ),
          ),
          hintStyle: UttTextStyles.inputHint,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: LoginColors.deepEmerald,
            foregroundColor: LoginColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
