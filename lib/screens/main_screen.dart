// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:developer';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:provider/provider.dart';
import 'package:quicklaunchim/controllers/code.dart';
import 'package:quicklaunchim/controllers/message_history.dart';
import 'package:quicklaunchim/controllers/messenger.dart';
import 'package:quicklaunchim/data/countries.dart';
import 'package:quicklaunchim/utils/phonenumber.dart';
import 'package:quicklaunchim/widgets/donate_banner.dart';
import 'package:quicklaunchim/widgets/select_phonenumber_dialog.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:universal_io/io.dart';
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
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

  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _getFromClipboard();

    codeFocusNode.addListener(() {
      setState(() => country = countries.findCountryByDialCode(code));
    });

    if (Platform.isAndroid || Platform.isIOS) {
      // For sharing or opening urls/text coming from outside the app while the app is in the memory
      _intentDataStreamSubscription =
          ReceiveSharingIntent.getTextStream().listen((String value) async {
        _inputPhoneChange(
          await _phoneNumberParser(
            await _findAndSelectPhoneNumber(value),
          ),
        );
      }, onError: (err) {
        log("getLinkStream error: $err");
      });

      // For sharing or opening urls/text coming from outside the app while the app is closed
      ReceiveSharingIntent.getInitialText().then((value) async {
        if (value != null) {
          _inputPhoneChange(
            await _phoneNumberParser(
              await _findAndSelectPhoneNumber(value),
            ),
          );
        }
      });
    }
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
    country = countries.findCountryByDialCode(widget.arguments?.code ?? c);
    setState(() {
      code = widget.arguments?.code ?? c;
      phone = widget.arguments?.phone ?? '';
      message = widget.arguments?.message ?? '';
      messenger = widget.arguments?.messenger ?? InstantMessenger.whatsapp;
    });
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getFromClipboard();
    }
  }

  @override
  void dispose() {
    codeFocusNode.dispose();
    if (Platform.isAndroid || Platform.isIOS) {
      _intentDataStreamSubscription.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int? flag;
    if (country != null && country!.keys.isNotEmpty) {
      flag = int.tryParse(country!['flag']!);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('appName'.i18n()),
        actions: [
          IconButton(
            onPressed: () => context.go('/config'),
            icon: const Icon(Icons.settings),
            tooltip: "settings".i18n(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAndSendMessage,
        label: Text('open'.i18n()),
        icon: const Icon(Icons.open_in_browser),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: 85,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (country != null && country!.keys.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 35,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              flag != null
                                  ? String.fromCharCode(flag)
                                  : country!['flag']!,
                              style: const TextStyle(
                                fontSize: 32,
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
                            label: Text(
                              'code'.i18n(),
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
                            label: Text(
                              'phoneNumber'.i18n(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: PopupMenuButton<InstantMessenger>(
                          tooltip: 'selectIM'.i18n(),
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
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(
                      "${'message'.i18n()} (${'optional'.i18n()})",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.go('/history'),
                    child: Text('history'.i18n()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const DonateBanner(),
    );
  }

  Future<void> _processDataFromClipboard(String value) async {
    final matches = PhoneNumberUtils.findPhoneNumbersInString(value);
    if (matches.isNotEmpty) {
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('clipboardDialogTitle'.i18n()),
          content: Text(
            'clipboardDialogBody'.i18n([matches.length.toString()]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('clipboardDialogNoButton'.i18n()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('clipboardDialogYesButton'.i18n()),
            ),
          ],
        ),
      );
      if (confirm == true) {
        _inputPhoneChange(
          await _phoneNumberParser(
            await _findAndSelectPhoneNumber(value),
          ),
        );
      }
    }
  }

  void _getFromClipboard() {
    if (kIsWeb) {
      var document = html.window.document;
      var helperdiv = document.createElement("div");
      var range = document.createRange();
      helperdiv.contentEditable = 'true';
      html.document.body!.append(helperdiv);
      range.selectNode(helperdiv);
      var selection = html.window.getSelection();
      if (selection != null) {
        selection.removeAllRanges();
        selection.addRange(range);
      }
      helperdiv.focus();
      document.execCommand('paste');
      _processDataFromClipboard(helperdiv.innerText);
    }
  }

  Future<String?> _findAndSelectPhoneNumber(String source) async {
    final matches = PhoneNumberUtils.findPhoneNumbersInString(source);
    String? phoneString;
    if (matches.length == 1) {
      phoneString = matches[0];
    } else {
      phoneString = await showDialog(
        context: context,
        builder: (context) => SelectPhoneNumberDialog(phoneNumbers: matches),
      );
    }
    return phoneString;
  }

  Future<String?> _phoneNumberParser(String? source) async {
    try {
      if (source != null) {
        final parsed = PhoneNumber.parse(source);
        bool isValid = parsed.isValid(type: PhoneNumberType.mobile);
        setState(() {
          phoneNumberIsInvalid = !isValid;
        });
        if (source.contains('+')) {
          _inputCodeController.value =
              TextEditingValue(text: parsed.countryCode);
          _inputPhoneController.value = TextEditingValue(text: parsed.nsn);
        } else {
          _inputPhoneController.value = TextEditingValue(
            text: '${parsed.countryCode}${parsed.nsn}',
          );
        }
        _inputPhoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: parsed.nsn.length),
        );
        setState(() {
          code = parsed.countryCode;
          if (source.contains('+')) {
            country = countries.findCountryByDialCode(parsed.countryCode);
          }
        });
        if (isValid) {
          return parsed.nsn;
        }
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
              label: 'dismiss'.i18n(),
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            content: Text(
              'invalidCode'.i18n(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
    return null;
  }

  void _inputPhoneChange(v) {
    setState(() => phone = v ?? '');
  }

  Future<void> _openUrl() async {
    final Uri? urlScheme = _getUrlScheme(messenger, message, phone);
    final Uri? urlLink = _getUrlLink(messenger, message, phone);
    try {
      log(urlScheme.toString());
      if (urlScheme != null) {
        await launchUrl(urlScheme);
      }
    } catch (_) {
      try {
        log(urlLink.toString());
        if (urlLink != null &&
            !await launchUrl(
              urlLink,
              mode: LaunchMode.externalApplication,
            )) {
          throw OpenUrlException('cantOpenLink');
        }
      } on OpenUrlException catch (e) {
        final msg = e.message.i18n([messenger.name]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'dismiss'.i18n(),
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            content: Text(
              msg,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _saveAndSendMessage() async {
    if (formKey.currentState!.validate()) {
      Provider.of<CodeValue>(context, listen: false).set(code);
      Provider.of<MessengerValue>(context, listen: false).set(messenger);
      Provider.of<MessageHistory>(context, listen: false).set(
        History(code, phone, messenger, DateTime.now(), message),
      );
      await _openUrl();
    }
  }

  String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'notEmpty'.i18n();
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'notEmpty'.i18n();
    }
    return null;
  }

  Uri? _getUrlScheme(InstantMessenger im, String text, String phone) {
    switch (im) {
      case InstantMessenger.telegram:
        return Uri.parse('tg://msg?text=$text&to=+$code$phone');
      case InstantMessenger.whatsapp:
        return Uri.parse('whatsapp://send?text=$text&phone=+$code$phone');
      default:
        return null;
    }
  }

  Uri? _getUrlLink(InstantMessenger im, String text, String phone) {
    switch (im) {
      case InstantMessenger.telegram:
        return Uri.parse('https://t.me/+$code$phone?msg=$text');
      case InstantMessenger.whatsapp:
        return Uri.parse('https://wa.me/+$code$phone?text=$text');
      default:
        return null;
    }
  }
}

class OpenUrlException {
  final String message;

  OpenUrlException(this.message);
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
