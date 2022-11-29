import 'package:flutter/material.dart';

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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Text(
              'Múltiplos Números de Telefone detectados. Selecione uma das opções abaixo:',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
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
                title: Text(phoneNumbers[index]!),
                onTap: () {
                  Navigator.pop(context, phoneNumbers[index]);
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
            title: const Text(
              'Cancelar',
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
