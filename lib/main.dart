import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Quick Open IM',
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
          return const MainScreen();
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
