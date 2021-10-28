
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class AppleBoardingPassHandler {

  AppleBoardingPassHandler();

  String createPassRequestUrl(String webApiUrl)  {
    print("Creating webapi url..");
    //String webApiUrl = 'https://customertest.videcom.com/videcomair/VARS/webapiv2/api/PassGeneratorAppleHC/createboardingpass';

    String queryParams = '?LogoText=Videcom Airways';
    queryParams = queryParams + '&Gate=B2';
    queryParams = queryParams + '&BoardingTime=10:15';
    queryParams = queryParams + '&FltNo=FL2168&';
    queryParams = queryParams + '&DepDate=12-11-2021';
    queryParams = queryParams + '&Depart=Stockholm Bromma';
    queryParams = queryParams + '&DepartCityCode=BMA';
    queryParams = queryParams + '&Arrive=Gatwick';
    queryParams = queryParams + '&ArriveCityCode=LGW';
    queryParams = queryParams + '&PaxName=Tom Burt';
    queryParams = queryParams + '&ClassBand=Blue Flex';
    queryParams = queryParams + '&Seat=25A';
    queryParams = queryParams + '&FastTrack=true';
    queryParams = queryParams + '&LoungeAccess=false';
    queryParams = queryParams + '&BarcodeData=BPPLM0037:10Apr2019:KOI:ABZ:AATPCR1';
    queryParams = queryParams + '&BarcodeType=pdf417';

    String url = webApiUrl + queryParams;
    return Uri.encodeFull(url);
  }

  void launchPass(String url) async {
    print("Fetching Boarding Pass..");
    _launchInWebViewOrVC(url);
    print("Pass installed");
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    /*   Map<String, String> userHeader = {
      'Content-Type': 'application/json',
      'Videcom_ApiKey': '2edd1519899a4e7fbf9a307a0db4c17a'
    };*/

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
        headers: <String, String>{'Videcom_ApiKey': '2edd1519899a4e7fbf9a307a0db4c17a'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

}