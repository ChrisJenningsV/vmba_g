


import '../data/globals.dart';

Map <String, String> getApiHeaders(){
  return  {'Content-Type': 'application/json',
    '__SkyFlyTok_V1': gblSettings.skyFlyToken,
    'Videcom_ApiKey': gblSettings.apiKey
  };
}
Map <String, String> getXmlHeaders(){
  return  {
    '__SkyFlyTok_V1': gblSettings.skyFlyToken
  };
}
