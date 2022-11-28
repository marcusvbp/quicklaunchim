class PhoneNumberUtils {
  static List<String?> findPhoneNumbersInString(String value) {
    RegExp regex = RegExp(
        r"((\+\d{1,2}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?)?\d{3}[\s.-]?\d{4}");
    var result = regex.allMatches(value);
    return result.map((RegExpMatch i) => i[0]).toList();
  }
}
