import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class SelectPhoneNumberDialog extends StatelessWidget {
  final List<String?> phoneNumbers;
  const SelectPhoneNumberDialog({super.key, required this.phoneNumbers});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Text(
              'selectPhoneNumberDialogTitle'.i18n(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .45,
            ),
            child: ListView.separated(
              itemBuilder: (context, index) => ListTile(
                title: Text(phoneNumbers[index]!.replaceAll("\n", "")),
                onTap: () {
                  Navigator.pop(
                      context, phoneNumbers[index]!.replaceAll("\n", ""));
                },
              ),
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
              ),
              itemCount: phoneNumbers.length,
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            title: Text(
              'cancel'.i18n(),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
