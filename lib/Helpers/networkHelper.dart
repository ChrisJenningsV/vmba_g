


import '../data/globals.dart';

Map <String, String> getApiHeaders(){

  return  {'Content-Type': 'application/json',
    '__SkyFlyTok_V1': gblSettings.skyFlyToken,
    'Videcom_ApiKey': gblSettings.apiKey
  };
}
Map <String, String> getApiHeadersReferer(){

  return  {'Content-Type': 'application/json',
    'Referer': 'https://customertest.videcom.com/LoganAirInhouse/VARS/public/default/home.aspx',
    '__SkyFlyTok_V1': gblSettings.skyFlyToken,
    'Videcom_ApiKey': gblSettings.apiKey
  };
}

Map <String, String> getXmlHeaders(){
  return  {
    '__SkyFlyTok_V1': gblSettings.skyFlyToken
  };
}
