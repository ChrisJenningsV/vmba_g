



import '../data/globals.dart';

void setLiveTest() {
  if(gblIsLive == true) {
    //gblSettings.payUrl = gblSettings.livePayUrl;
    gblSettings.payPage = gblSettings.livePayPage;
    gblSettings.xmlUrl = gblSettings.liveXmlUrl;
    gblSettings.apisUrl = gblSettings.liveApisUrl;
    gblSettings.apiUrl = gblSettings.liveApiUrl;
    gblSettings.smartApiUrl = gblSettings.liveSmartApiUrl;
    gblSettings.creditCardProvider  = gblSettings.liveCreditCardProvider;
  } else {
    // gblSettings.payUrl = gblSettings.testPayUrl;
    gblSettings.payPage = gblSettings.testPayPage;
    gblSettings.xmlUrl = gblSettings.testXmlUrl;
    gblSettings.apisUrl = gblSettings.testApisUrl;
    gblSettings.apiUrl = gblSettings.testApiUrl;
    gblSettings.smartApiUrl = gblSettings.testSmartApiUrl;
    gblSettings.creditCardProvider  = gblSettings.testCreditCardProvider;
    if( gblSettings.testServerFiles != null && gblSettings.testServerFiles.isNotEmpty){
      gblSettings.gblServerFiles = gblSettings.testServerFiles;
    }
  }
}

bool wantRtl() {
  if( gblLanguage == 'ar'){
    return true;
  }
  return false;
}

bool wantPageV2() {
  if( gblSettings.pageStyle == 'V2') {
    return true;
  } else {
    return false;
  }
}