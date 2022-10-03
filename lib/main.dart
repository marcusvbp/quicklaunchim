import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:openim/controllers/message_history.dart';
import 'package:openim/controllers/messenger.dart';
import 'package:openim/data_storage/history_storage.dart';
import 'package:openim/data_storage/messenger_storage.dart';
import 'package:openim/screens/config_screen.dart';
import 'package:openim/screens/history_screen.dart';
import 'package:openim/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'controllers/code.dart';
import 'data_storage/code_storage.dart';

class ThemeClass {
  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(),
    appBarTheme: const AppBarTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final messengerController = MessengerValue(
    storage: MessengerStorage(),
  );
  final codeController = CodeValue(
    storage: CodeStorage(),
  );
  final messageHistoryController = MessageHistory(
    storage: HistoryStorage(),
  );

  await messengerController.rehydrate();
  await codeController.rehydrate();
  await messageHistoryController.rehydrate();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => messengerController),
        ChangeNotifierProvider(create: (context) => codeController),
        ChangeNotifierProvider(create: (context) => messageHistoryController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return MaterialApp.router(
      title: 'Quick Open IM',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
        Locale('pt', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }

        // define pt_BR as default when de language code is 'pt'
        // if (locale?.languageCode == 'pt') {
        //   return const Locale('pt', '');
        // }

        // default language
        return const Locale('en', '');
      },
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeClass.darkTheme,
      theme: ThemeClass.lightTheme,
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          final MainScreenArguments? args =
              state.extra != null ? state.extra as MainScreenArguments : null;
          return MainScreen(
            arguments: args,
          );
        },
        routes: [
          GoRoute(
            path: 'config',
            builder: (BuildContext context, GoRouterState state) {
              return const ConfigScreen();
            },
          ),
          GoRoute(
            path: 'history',
            builder: (BuildContext context, GoRouterState state) {
              return const HistoryScreen();
            },
          ),
        ],
      ),
    ],
  );
}
