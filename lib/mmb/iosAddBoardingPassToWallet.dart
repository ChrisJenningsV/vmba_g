
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class AppleBoardingPassHandler {

  AppleBoardingPassHandler();

  void launchPass(String url, String apiKey) async {
    print("Fetching Boarding Pass..");
    _launchInWebViewOrVC(url, apiKey);
    print("Pass installed");
  }

  Future<void> _launchInWebViewOrVC(String url, String apiKey) async {
    /*   Map<String, String> userHeader = {
      'Content-Type': 'application/json',
      'Videcom_ApiKey': '2edd1519899a4e7fbf9a307a0db4c17a'
    };*/

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
        headers: <String, String>{'Videcom_ApiKey': apiKey},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

}