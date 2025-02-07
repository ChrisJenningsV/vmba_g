import 'package:flutter/material.dart';
import 'package:vmba/calendar/outboundFlightPage.dart';

import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

import '../../Helpers/settingsHelper.dart';
import '../../components/vidButtons.dart';

// ignore: must_be_immutable
class SearchButtonWidget extends StatelessWidget {
  SearchButtonWidget(
      {Key key= const Key("searchbtn_key"), required this.newBooking, required this.onChanged})
      : super(key: key);

  final ValueChanged<NewBooking> onChanged;

  List<String> errors = [];
  // new List<String>();


  _clearNewBookingObject() {
    newBooking.clear();
/*
    newBooking.outboundflight = [];
    // List<String>();
    newBooking.returningflight = [];
    // List<String>();
    newBooking.passengerDetails = [];
    // List<PassengerDetail>();
    newBooking.paymentDetails = PaymentDetails();
    newBooking.contactInfomation = ContactInfomation();
*/
  }

  showSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //Scaffold.of(context).showSnackBar(snackbar(message));
  }

  final NewBooking newBooking;
  //final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
      String text ='SEARCH FLIGHTS';
      if( wantHomePageV2() || wantHomePageV3() ) {
        text ='Show flights';
      }
      return vidWideActionButton(context,text, _onPressed, icon: Icons.check, offset: 35.0 , disabled:  !_validate(newBooking));
  }
  _validate(NewBooking newBooking) {
    errors.clear();
    bool isValid = true;
    if (newBooking.departure == null || newBooking.departure == '') {
      errors.add(translate('Departure airport is missing.'));
      isValid = false;
    }

    if (newBooking.arrival == null || newBooking.arrival == '') {
      errors.add(translate('Arrival airport is missing.'));
      isValid = false;
    }

    if (newBooking.departureDate == null) {
      errors.add(translate('Departure date is missing.'));
      isValid = false;
    }

    if (newBooking.isReturn && (newBooking.returnDate == null)) {
      errors.add(translate('Return date is missing.'));
      isValid = false;
    }

    if (newBooking.passengers.adults +
        newBooking.passengers.youths +
        newBooking.passengers.seniors +
        newBooking.passengers.students +
        newBooking.passengers.children >
        gblSettings.maxNumberOfPax) {
      String email = gblSettings.groupsBookingsEmail != null
          ? gblSettings.groupsBookingsEmail
          : 'groups@videcom.com';
      errors.add(translate('If booking more than')  + ' '+
          gblSettings.maxNumberOfPax.toString() + ' ' +
          translate('passengers, please contact') + ' ' +
          email +
          '.');
      // 'If booking more than 8 passengers, please contact groups@loganair.co.uk.');
      isValid = false;
    }

    if (newBooking.passengers.infants > newBooking.passengers.adults) {
      errors.add(
          translate('The number of infants cannot be greater than the number of adult passengers.'));
      isValid = false;
    }

    gblSearchParams.departDate = newBooking.departureDate;
    gblSearchParams.returnDate = newBooking.returnDate;

    return isValid;
  }
void _onPressed(BuildContext context, dynamic p ) {
  {
    _clearNewBookingObject();
    hasDataConnection().then((result) async {
      if (result == true) {
        _validate(newBooking)
            ? this.onChanged(await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    FlightSeletionPage(
                        newBooking: newBooking))))
            : _ackErrorAlert(context);
      } else {
//showSnackBar(context, translate('Please, check your internet connection'));
        //noInternetSnackBar(context);
      }
    });
  }
}


  Future<void> _ackErrorAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TrText('Oops'),
          content: Text(errors
              .join('\n')), //const Text('This item is no longer available'),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
