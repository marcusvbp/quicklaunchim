import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateBanner extends StatefulWidget {
  const DonateBanner({super.key});

  @override
  State<DonateBanner> createState() => _DonateBannerState();
}

class _DonateBannerState extends State<DonateBanner> {
  //
  @override
  Widget build(BuildContext context) {
    Widget paypal = InkWell(
      onTap: () async {
        var url = Uri.parse(
          'https://www.paypal.com/donate/?hosted_button_id=D97Q7PNRGLXKU',
        );
        if (!await launchUrl(url)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              content: Text(
                'openUrlError'.i18n(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('donateWith'.i18n()),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Image.asset(
                'assets/images/paypal-logo.png',
                width: 100,
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(
            Radius.circular(6),
          )),
      child: Row(children: [
        Expanded(
            child: Text(
          'donateMessage'.i18n(['appName'.i18n()]),
          textAlign: TextAlign.center,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: paypal,
        ),
        Image.asset(
          'assets/images/paypal_qrcode.png',
          width: 100,
        ),
      ]),
    );
  }
}
