import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
import 'package:openim/controllers/message_history.dart';
import 'package:openim/screens/main_screen.dart';
import 'package:provider/provider.dart';

import '../models/history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('historyScreenTitle'.i18n()),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Consumer<MessageHistory>(
          builder: (context, history, _) => ListView.separated(
            itemCount: history.items.length,
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemBuilder: (context, index) {
              final removeHistory =
                  Provider.of<MessageHistory>(context, listen: false).remove;
              final item = history.items[index];
              final tile = ListTile(
                title: Row(
                  children: [
                    Text('+${item.countryCode} ${item.phoneNumber}'),
                    const Spacer(),
                    Tooltip(
                      message: DateFormat('dd/MM/yyyy - kk:mm:ss')
                          .format(item.dateTime),
                      child: Text(
                        DateFormat('dd/MM - kk:mm').format(item.dateTime),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                subtitle: item.message != null
                    ? Text(
                        '${item.message}',
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                leading: Image.asset(
                  History.imMessengers[item.messenger]!,
                  height: 40,
                ),
                trailing: TextButton(
                  onPressed: () {
                    context.push(
                      '/',
                      extra: MainScreenArguments(
                        code: item.countryCode,
                        phone: item.phoneNumber,
                        message: item.message,
                        messenger: item.messenger,
                      ),
                    );
                  },
                  child: Text('resend'.i18n()),
                ),
              );

              return Slidable(
                startActionPane: ActionPane(
                  extentRatio: .3,
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        Future.delayed(const Duration(milliseconds: 100)).then(
                          (value) => removeHistory(item),
                        );
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: tile,
              );
            },
          ),
        ),
      ),
    );
  }
}
