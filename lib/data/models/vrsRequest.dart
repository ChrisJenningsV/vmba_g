


import 'models.dart';

class VrsApiRequest extends Session {
  String cmd;
  String brandId;
  String appFile;
  String token;
  String vrsGuid;
  String phoneId;
  String notifyToken;
  String rloc;

  VrsApiRequest(
      Session session,
      this.cmd,
      this.token,
  {this.brandId, this.appFile, this.vrsGuid, this.phoneId, this.rloc, this.notifyToken}
      ) : super(session.sessionId, session.varsSessionId, session.vrsServerNo);

  Map toJson() {
    Map map = new Map();
    map['sessionID'] = sessionId;
    map['VARSSessionID'] = varsSessionId;
    map['vrsServerNo'] = vrsServerNo == "" ? '0' : vrsServerNo;
    map['cmd'] = cmd;
    map['brandId'] = brandId;
    map['Token'] = token;
    map['appFile'] = appFile;
    map['vrsGuid'] = vrsGuid;
    map['notifyToken'] = notifyToken;
    map['phoneId'] = phoneId;
    map['rloc'] = rloc;
    return map;
  }
}

class VrsApiResponse  {
  String data;
  String errorMsg;
  String sessionId;
  String varsSessionId;
  String vrsServerNo;
  String serverIP;
  bool isSuccessful;

  VrsApiResponse( this.data, this.varsSessionId, this.sessionId, this.vrsServerNo, this.errorMsg, this.isSuccessful) ;

  VrsApiResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    errorMsg = json['errorMsg'];
    sessionId = json['sessionID'];
    varsSessionId = json['VARSSessionID'];
    vrsServerNo = json['vrsServerNo'];
    isSuccessful = json['isSuccessful'];
    serverIP = json['serverIP'];
  }
}
