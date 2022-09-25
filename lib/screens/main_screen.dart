// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:openim/controllers/code.dart';
import 'package:openim/controllers/message_history.dart';
import 'package:openim/controllers/messenger.dart';
import 'package:openim/data/countries.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/history.dart';

class MainScreen extends StatefulWidget {
  final MainScreenArguments? arguments;
  const MainScreen({
    super.key,
    this.arguments,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final formKey = GlobalKey<FormState>();
  String code = '';
  String phone = '';
  String message = '';
  bool phoneNumberIsInvalid = true;
  Countries countries = Countries();
  Map<String, String>? country;
  late InstantMessenger messenger;

  late TextEditingController _inputCodeController;
  late TextEditingController _inputPhoneController;
  late TextEditingController _inputMessageController;

  FocusNode codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    codeFocusNode.addListener(() {
      setState(() => country = countries.findCountryByCode(code));
    });
  }

  @override
  void didChangeDependencies() {
    final c = Provider.of<CodeValue>(context, listen: false).code;

    _inputPhoneController = TextEditingController(
      text: widget.arguments?.phone,
    );
    _inputMessageController = TextEditingController(
      text: widget.arguments?.message,
    );

    _inputCodeController =
        TextEditingController(text: widget.arguments?.code ?? c);
    messenger = Provider.of<MessengerValue>(context, listen: false).messenger;
    country = countries.findCountryByCode(widget.arguments?.code ?? c);
    setState(() {
      code = widget.arguments?.code ?? c;
      messenger = widget.arguments?.messenger ?? InstantMessenger.whatsapp;
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
        onPressed: _saveAndSendMessage,
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
                SizedBox(
                  height: 85,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (country != null)
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 35,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              '${country!["flag"]}',
                              style: const TextStyle(
                                fontSize: 36,
                              ),
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
                          onChanged: _inputPhoneChange,
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
                            FilteringTextInputFormatter.allow(
                                RegExp('[0-9/+/-]'))
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

  String? _phoneNumberParser(String phone) {
    final parsed = PhoneNumber.parse(phone);
    setState(() {
      phoneNumberIsInvalid = !parsed.isValid(type: PhoneNumberType.mobile);
    });
    _inputCodeController.value = TextEditingValue(text: parsed.countryCode);
    _inputPhoneController.value = TextEditingValue(text: parsed.nsn);
    _inputPhoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputPhoneController.text.length));
    setState(() {
      code = parsed.countryCode;
      country = countries.findCountryByCode(parsed.countryCode);
    });
    if (parsed.isValid(type: PhoneNumberType.mobile)) {
      return parsed.nsn;
    }
    return null;
  }

  void _inputPhoneChange(v) {
    String? nsn;
    try {
      if (v.contains('+') && v.length > 4) {
        nsn = _phoneNumberParser(v);
      }
    } on PhoneNumberException catch (err) {
      setState(() {
        phoneNumberIsInvalid = true;
      });
      if ((err.code == Code.notFound || err.code == Code.invalidIsoCode) &&
          phoneNumberIsInvalid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            content: const Text(
              'The country code is not found, or is invalid.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
    setState(() => phone = nsn ?? v);
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

  void _saveAndSendMessage() {
    if (formKey.currentState!.validate()) {
      Provider.of<CodeValue>(context, listen: false).set(code);
      Provider.of<MessengerValue>(context, listen: false).set(messenger);
      Provider.of<MessageHistory>(context, listen: false).set(
        History(code, phone, messenger, DateTime.now(), message),
      );
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
    // if (phoneNumberIsInvalid) {
    //   return 'This phone number does not look lika a mobile number';
    // }
    return null;
  }
}

class MainScreenArguments {
  final String? code;
  final String? phone;
  final String? message;
  final InstantMessenger? messenger;

  MainScreenArguments({
    this.code,
    this.phone,
    this.message,
    this.messenger,
  });
}
