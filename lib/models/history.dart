// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum InstantMessenger { whatsapp, telegram }

class History {
  final String countryCode;
  final String phoneNumber;
  // enum
  final InstantMessenger messenger;
  final DateTime dateTime;
  final String? message;

  History(this.countryCode, this.phoneNumber, this.messenger, this.dateTime,
      [this.message]);

  static const Map<InstantMessenger, String> imMessengers = {
    InstantMessenger.whatsapp: 'assets/images/icon_whatsapp.png',
    InstantMessenger.telegram: 'assets/images/icon_telegram.png',
  };

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'messenger': messenger.index,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'message': message,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      map['countryCode'] as String,
      map['phoneNumber'] as String,
      InstantMessenger.values[map['messenger'] as int],
      DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      map['message'] != null ? map['message'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory History.fromJson(String source) =>
      History.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'History(countryCode: $countryCode, phoneNumber: $phoneNumber, messenger: $messenger, dateTime: $dateTime, message: $message)';
  }
}
