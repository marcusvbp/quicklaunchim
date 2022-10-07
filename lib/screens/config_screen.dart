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
                ListTile(
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeCtrl.themeMode,
                    items: ThemeMode.values
                        .map((ThemeMode tm) => DropdownMenuItem(
                              value: tm,
                              child: Text(tm.name),
                            ))
                        .toList(),
                    onChanged: (v) => themeCtrl.set(v!),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Language'),
                  trailing: DropdownButton<Locale>(
                    value: langCtrl.current,
                    items: langCtrl.supportedLocales
                        .map(
                          (Locale l) => DropdownMenuItem(
                            value: l,
                            child: Text(l.languageCode),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      await langCtrl.set(v!);
                      setState(() {});
                    },
                  ),
                ),
              ],
            );
          },
        ));
  }
}
