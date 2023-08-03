
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utilities/helper.dart';
import 'globals.dart';
import 'models/models.dart';
import 'models/vrsRequest.dart';

Future<String> callSmartApi(String action, String data) async {
  String msg =  json.encode(VrsApiRequest(gblSession as Session, action,
      gblSettings.xmlToken.replaceFirst('token=', ''),
      vrsGuid: gblSettings.vrsGuid,
      undoCmd: gblUndoCommand,
      data: data,
      notifyToken: gblNotifyToken,
      rloc: gblCurrentRloc,
      language: gblLanguage,
      phoneId: gblDeviceId
  )); // '{VrsApiRequest: ' + + '}' ;

  print('callSmartApi::${gblSettings.smartApiUrl}?VarsSessionID=${gblSession!.varsSessionId}&req=$msg');

  http.Response response = await http
      .get(Uri.parse(
      "${gblSettings.smartApiUrl}?VarsSessionID=${gblSession!.varsSessionId}&req=$msg"))
      .catchError((resp) {
    logit(resp);
  });
  if (response == null) {
    throw 'No Internet';
    //return new ParsedResponse(noInterent, null);
  }

  //If there was an error return null
  if (response.statusCode < 200 || response.statusCode >= 300) {
    logit('callSmartApi (): ' + response.statusCode.toString() + ' ' + (response.reasonPhrase as String));
    throw 'callSmartApi: ' + response.statusCode.toString() + ' ' + (response.reasonPhrase as String);
    //return new ParsedResponse(response.statusCode, null);
  }

  print('callSmartApi_response::${response.body}');

  if (response.body.contains('<string xmlns="http://videcom.com/">Error')) {
    String er = response.body.replaceAll('<string xmlns="http://videcom.com/">' , '');
    throw er;

  }

  String responseData = response.body
      .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
      .replaceAll('<string xmlns="http://videcom.com/">', '')
      .replaceAll('<string xmlns="http://videcom.com/" />', '')
      .replaceAll('</string>', '');

  Map<String, dynamic> map = jsonDecode(responseData);

  // gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
  if (response.body.contains('ERROR')) {

    throw map["errorMsg"];
    //return new ParsedResponse(0, null, error: response.body);
  }

  //String jsn = response.body;

  VrsApiResponse rs = VrsApiResponse.fromJson(map);
  // gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
  logit('Server IP ${map['serverIP']}');
  if( rs.isSuccessful == false) {
    if( rs.data != null && rs.data.isNotEmpty) {
     throw rs.data;
    } else {
      throw rs.errorMsg;
    }
  }


  if( rs.data == null ) {
    throw 'no data returned';
  }
  return rs.data;
}

