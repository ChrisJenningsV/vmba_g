



import '../data/globals.dart';
import '../data/repository.dart';
import '../utilities/helper.dart';

Future<void> refreshBookingx() async {
  logit('_refreshBooking');
  await Repository.get().fetchPnr(gblCurrentRloc);
  if( gblSettings.wantApis) {
    await Repository.get().fetchApisStatus(gblCurrentRloc);
  }

  Repository.get().fetchApisStatus(gblCurrentRloc);
  Repository.get().fetchPnr(gblCurrentRloc);
}