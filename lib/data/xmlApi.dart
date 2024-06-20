
import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/helper.dart';

import '../Helpers/networkHelper.dart';


Future<String> sendValidateEmailMsg( String email , String code) async {
  try {

    http.Response
    response = await http.post(
        Uri.parse(gblSettings.xmlUrl.replaceFirst('VrsApi.asmx/PostVRSCommand?', 'MobileAppWS.asmx/') + "DoSendMobileValidationEmail"),
        //Uri.parse('https://customertest.videcom.com/LoganAir/VARS/Public/WebServices/MobileAppWS.asmx/DoSendMobileValidationEmail'),
        headers: getXmlHeaders(),
        body: {"email": email,"appCode": code  })
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
      logit('sendValidateEmailMsg: null reply');
      return 'Error';
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      logit('sendXmlMsg: error statue ${response.statusCode}');
      String error = response.reasonPhrase as String;
      return error;
    }

    String rsJson;

    rsJson = response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '');
    //String data = rsJson;
    Map map = json.decode(rsJson);
    if( map['Result'] == 'OK') {
      return 'OK';
    } else {
      return map['Data'];
    }
  } catch(e) {
    return e.toString();
  }
}


Future<XmlResponse> sendXmlMsg(XmlRequest xmlRequest) async {
  XmlResponse xmlResponse = new XmlResponse(success: true,);

  logit('sendXmlMsg: cmd=${xmlRequest.command}');
  try {
    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=${xmlRequest.command}"),
        headers: getXmlHeaders())
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
      logit('sendXmlMsg: null reply');
      xmlResponse.success = false;
      xmlResponse.error = 'no reply';
      return xmlResponse;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      logit('sendXmlMsg: error statue ${response.statusCode}');
      xmlResponse.statusCode = response.statusCode;
      xmlResponse.success = false;
      xmlResponse.error = response.reasonPhrase as String ;
      return xmlResponse;
    }

    String rsJson;

    rsJson = response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '');
    xmlResponse.data = rsJson;

    xmlResponse.map = json.decode(rsJson);

/*  print('Fetch PNR');
  PnrModel pnrModel = new PnrModel.fromJson(map);

  PnrDBCopy pnrDBCopy = new PnrDBCopy(
      rloc: pnrModel.pNR.rLOC, //_rloc,
      data: pnrJson,
      delete: 0,
      nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
  Repository.get().updatePnr(pnrDBCopy);

  return pnrDBCopy;
*/
  } catch(e) {
    xmlResponse.success = false;
    xmlResponse.error = e.toString();
  }
  return xmlResponse;
}










class XmlRequest {
  String command ='';
  int retries =0;
  BuildContext? context;

  XmlRequest (
  {
    this.command ='',
    this.retries =0,
    this.context,
  }
      );

}

class XmlResponse {
  String data;
  String error;
  Map? map;
  bool success;
  int statusCode;

  XmlResponse(
  {
    this.data='',
    this.error='',
    this.map,
    this.success=true,
    this.statusCode=0,
  }
      );
}
