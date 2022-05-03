import 'dart:async' show Future;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/helper.dart';

import '../Helpers/networkHelper.dart';



Future <bool> serverLog(String msg) async {
  //http request, catching error like no internet connection.
  //If no internet is available for example response is
  logit('serverLog $msg');
  http.Response response = await http
      .post(
    //"${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=ssrpmacitylist")
    Uri.parse(
        '${gblSettings.apiUrl}/logging/LogMsg'),
    headers: getApiHeaders(),
      body: JsonEncoder().convert(msg)
    ).catchError((resp) {});

  if (response == null) {
    return false;
  }

  //If there was an error return an empty list
  if (response.statusCode < 200 || response.statusCode >= 300) {
    return false;
  }

  return true;
}
