import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

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
      body: const Center(
        child: Text('config screen'),
      ),
    );
  }
}
