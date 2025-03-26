
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Helpers/networkHelper.dart';
import '../data/globals.dart';
import '../data/models/models.dart';
import '../data/models/vrsRequest.dart';
import '../utilities/helper.dart';

Future<String> callSmartApi(String action, String data) async {
  VrsApiRequest rq =
    VrsApiRequest(gblSession as Session, action,
      gblSettings.xmlToken.replaceFirst('token=', ''),
      vrsGuid: gblSettings.vrsGuid,
      undoCmd: gblUndoCommand,
      data: data,
      notifyToken: gblNotifyToken,
      rloc: gblCurrentRloc,
      language: gblLanguage,
      phoneId: gblDeviceId
    ); // '{VrsApiRequest: ' + + '}' ;
  if( gblCurLocation != null ){
    rq.countryCode = gblCurLocation!.isoCountryCode;
    rq.country = gblCurLocation!.country;
    rq.city = gblCurLocation!.locality;

    rq.latitude = gblLatitude;
    rq.longitude = gblLongitude;
  }
  String msg =  json.encode(rq);

  print('callSmartApi::${gblSettings.smartApiUrl}?VarsSessionID=${gblSession!.varsSessionId}&req=$msg sid=${gblSession!.sessionId}');
  http.Response? response;

  //if( gblSettings.smartApiVersion == 2) {
    response = await http
        .post(
          Uri.parse("${gblSettings.smartApiUrl}?VarsSessionID=${gblSession!.varsSessionId}"), //?VarsSessionID=${gblSession!.varsSessionId}"),
          headers: getXmlHeaders(),
          body: { "req": msg }
        )
        .catchError((resp) {
      logit(resp);
      return '';
    });
/*
  if (response == null) {
    throw 'No Internet';
    //return new ParsedResponse(noInterent, null);
  }
*/

  //If there was an error return null
  if (response.statusCode < 200 || response.statusCode >= 300) {
    logit('callSm (): ' + response.statusCode.toString() + ' ' + (response.reasonPhrase as String));
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
    if(  rs.data.isNotEmpty) {
      gblError =rs.data;
     throw rs.data;
    } else {
      gblError =rs.errorMsg;
      throw rs.errorMsg;
    }
  }


/*
  if( rs.data == null ) {
    throw 'no data returned';
  }
*/
  if( gblCurLocation != null && gblCurLocation!.locality == '' ) {
    gblCurCity = rs.city;
  }
  return rs.data;
}

