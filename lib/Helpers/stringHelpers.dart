import 'package:html_unescape/html_unescape.dart';


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