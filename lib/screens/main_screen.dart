import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:openim/controllers/code.dart';
import 'package:openim/controllers/message_history.dart';
import 'package:openim/controllers/messenger.dart';
import 'package:openim/data/countries.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/history.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final formKey = GlobalKey<FormState>();
  String code = '';
  String phone = '';
  String message = '';
  Countries countries = Countries();
  Map<String, String>? country;
  InstantMessenger messenger = InstantMessenger.whatsapp;

  late TextEditingController _inputCodeController;
  late TextEditingController _inputPhoneController;
  late TextEditingController _inputMessageController;

  FocusNode codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputPhoneController = TextEditingController();
    _inputMessageController = TextEditingController();

    codeFocusNode.addListener(() {
      setState(() => country = countries.findCountryByCode(code));
    });
  }

  @override
  void didChangeDependencies() {
    final c = Provider.of<CodeValue>(context, listen: false).code;

    _inputCodeController = TextEditingController(text: c);
    messenger = Provider.of<MessengerValue>(context, listen: false).messenger;
    country = countries.findCountryByCode(c);
    setState(() {
      code = c;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Open IM'),
        actions: [
          IconButton(
            onPressed: () => context.go('/config'),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Provider.of<CodeValue>(context, listen: false).set(code);
          Provider.of<MessengerValue>(context, listen: false).set(messenger);
          Provider.of<MessageHistory>(context, listen: false).set(
            History(code, phone, messenger, DateTime.now(), message),
          );
        },
        label: const Text('Open'),
        icon: const Icon(Icons.open_in_browser),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      if (country != null)
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 35,
                          child: Center(
                            child: Image.asset(
                              'assets/country_flags/png250px/${country!['iso']!.toLowerCase()}.png',
                            ),
                          ),
                        ),
                      Container(
                        width: 87,
                        margin: const EdgeInsets.only(right: 10),
                        child: TextFormField(
                          controller: _inputCodeController,
                          focusNode: codeFocusNode,
                          onChanged: (v) => setState(() => code = v),
                          onTap: () =>
                              _inputCodeController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset:
                                _inputCodeController.value.text.length,
                          ),
                          maxLength: 5,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.phone,
                          validator: validateCode,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9/-]'))
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            border: const OutlineInputBorder(),
                            label: const Text(
                              'Code',
                            ),
                            labelStyle: const TextStyle(fontSize: 14),
                            prefix: const Text('+'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _inputPhoneController,
                          onChanged: (v) => setState(() => phone = v),
                          onTap: () =>
                              _inputPhoneController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset:
                                _inputPhoneController.value.text.length,
                          ),
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.phone,
                          validator: validatePhone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                          ],
                          decoration: InputDecoration(
                            hintText: '0123456',
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            border: const OutlineInputBorder(),
                            label: const Text(
                              'Phone number',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: PopupMenuButton<InstantMessenger>(
                          tooltip: 'Select Instant Messenger',
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: InstantMessenger.whatsapp,
                              child: Text('Whatsapp'),
                            ),
                            const PopupMenuItem(
                              value: InstantMessenger.telegram,
                              child: Text('Telegram'),
                            ),
                          ],
                          onSelected: (v) => setState(() => messenger = v),
                          child: Image.asset(
                            History.imMessengers[messenger]!,
                            height: 40,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                TextFormField(
                  controller: _inputMessageController,
                  onTap: () =>
                      _inputMessageController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _inputMessageController.value.text.length,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  maxLength: 70,
                  onChanged: (v) => setState(() => message = v),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text(
                      'Message (optional)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/history'),
                  child: const Text('History'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl() async {
    // final Uri url = Uri.parse(
    //     'whatsapp://send?text=Hello World!&phone=+5599988094216'); // whatsapp
    final Uri url =
        Uri.parse('tg://msg?text=Mi_mensaje&to=+5599988094216'); // telegram
    if (!await launchUrl(url)) {
      throw 'Não foi possível abrir $url';
    }
  }

  String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not Empty';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not Empty';
    }
    return null;
  }
}
