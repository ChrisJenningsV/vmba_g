


import '../data/globals.dart';

Map <String, String> getApiHeaders(){
  return  {'Content-Type': 'application/json',
    '__SkyFkyTok': gblSettings.skyFlyToken,
    'Videcom_ApiKey': gblSettings.apiKey
  };
}
Map <String, String> getXmlHeaders(){
  return  {
    '__SkyFkyTok': gblSettings.skyFlyToken
  };
}
