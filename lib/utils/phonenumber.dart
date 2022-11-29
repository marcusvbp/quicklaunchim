class PhoneNumberUtils {
  static List<String?> findPhoneNumbersInString(String value) {
    // source: https://stackoverflow.com/questions/16699007/regular-expression-to-match-standard-10-digit-phone-number
    RegExp regex = RegExp(
        r"((\+\d{1,2}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?)?\d{3}[\s.-]?\d{4}");
    var result = regex.allMatches(value);
    return result.map((RegExpMatch i) => i[0]).toList();
  }
}
