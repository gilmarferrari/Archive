import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/home_page.dart';
import 'utils/app_constants.dart';
import 'utils/app_routes.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
        navigatorKey: AppConstants.globalNavKey,
        locale: const Locale('pt', 'BR'),
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: AppConstants.primaryColor,
          scaffoldBackgroundColor: Colors.grey[100],
          actionIconTheme: ActionIconThemeData(
            backButtonIconBuilder: (ctx) => const Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        routes: {
          AppRoutes.HOME: (ctx) => const HomePage(),
        },
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate]);
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
