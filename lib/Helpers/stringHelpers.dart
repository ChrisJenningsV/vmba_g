import 'package:html_unescape/html_unescape.dart';
import 'package:vmba/Helpers/settingsHelper.dart';


String convertNumberIntoWord(int number) {
  var _arrWordList = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen'
  ];
  return _arrWordList[number];
}
String parseHtmlString(String htmlString) {
  return  HtmlUnescape().convert(htmlString);
}

String translateNo(String input) {
  if( input == '' || input.isEmpty) {
    return '';
  }
  if( wantRtl()){
    return numberToArabic(input);
  }
  return input;
}

String numberToArabic(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], farsi[i]);
  }

  return input;
}
