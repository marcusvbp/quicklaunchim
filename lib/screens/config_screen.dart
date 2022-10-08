import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:openim/controllers/appsettings/language.dart';
import 'package:openim/controllers/appsettings/theme.dart';
import 'package:provider/provider.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('configurationsScreenTitle'.i18n()),
      ),
      body: Consumer2<LanguageController, ThemeController>(
        builder: (context, langCtrl, themeCtrl, _) {
          return ListView(
            children: [
              // ListTile(
              //   title: Text('Theme'.i18n()),
              //   trailing: DropdownButton<ThemeMode>(
              //     value: themeCtrl.themeMode,
              //     items: ThemeMode.values
              //         .map((ThemeMode tm) => DropdownMenuItem(
              //               value: tm,
              //               child: Text('Theme${tm.name}'.i18n()),
              //             ))
              //         .toList(),
              //     onChanged: (v) => themeCtrl.set(v!),
              //   ),
              // ),
              DropdownButtonFormField<ThemeMode>(
                value: themeCtrl.themeMode,
                decoration: InputDecoration(
                  label: Text(
                    'Theme'.i18n(),
                    style: const TextStyle(fontSize: 18, height: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
                items: ThemeMode.values
                    .map((ThemeMode tm) => DropdownMenuItem(
                          value: tm,
                          child: Text('Theme${tm.name}'.i18n()),
                        ))
                    .toList(),
                onChanged: (v) => themeCtrl.set(v!),
              ),
              const Divider(height: 1),
              DropdownButtonFormField<Locale>(
                decoration: InputDecoration(
                  label: Text(
                    'Language'.i18n(),
                    style: const TextStyle(fontSize: 18, height: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
                value: langCtrl.current,
                items: langCtrl.supportedLocales
                    .map(
                      (Locale l) => DropdownMenuItem(
                        value: l,
                        child: Text('Lang${l.languageCode}'.i18n()),
                      ),
                    )
                    .toList(),
                onChanged: (v) async {
                  await langCtrl.set(v!);
                  setState(() {});
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
