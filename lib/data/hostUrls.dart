import 'package:vmba/data/settings.dart';
import 'package:vmba/data/globals.dart';

class HostURLs {
  final imageFolder = '/images/app/';

  String get appBarImage {
    return gbl_settings.hostBaseUrl + 'logo.png';
  }
}
