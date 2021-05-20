import 'package:flutter/material.dart';
import 'package:vmba/calendar/outboundFlightPage.dart';

import 'package:vmba/data/SystemColors.dart';
//import 'package:vmba/availability/flight_page.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/globals.dart';

// ignore: must_be_immutable
class SearchButtonWidget extends StatelessWidget {
  SearchButtonWidget(
      {Key key, this.systemColors, this.newBooking, this.onChanged})
      : super(key: key);

  final ValueChanged<NewBooking> onChanged;

  List<String> errors = [];
  // new List<String>();
  _validate(NewBooking newBooking) {
    errors.clear();
    bool isValid = true;
    if (newBooking.departure == null || newBooking.departure == '') {
      errors.add('Departure airport is missing.');
      isValid = false;
    }

    if (newBooking.arrival == null || newBooking.arrival == '') {
      errors.add('Arrival airport is missing.');
      isValid = false;
    }

    if (newBooking.departureDate == null) {
      errors.add('Departure date is missing.');
      isValid = false;
    }

    if (newBooking.isReturn && (newBooking.returnDate == null)) {
      errors.add('Return date is missing.');
      isValid = false;
    }

    if (newBooking.passengers.adults +
            newBooking.passengers.youths +
            newBooking.passengers.children >
        gbl_settings.maxNumberOfPax) {
      String email = gbl_settings.groupsBookingsEmail != null
          ? gbl_settings.groupsBookingsEmail
          : 'groups@videcom.com';
      errors.add('If booking more than ' +
          gbl_settings.maxNumberOfPax.toString() +
          ' passengers, please contact ' +
          email +
          '.');
      // 'If booking more than 8 passengers, please contact groups@loganair.co.uk.');
      isValid = false;
    }

    if (newBooking.passengers.infants > newBooking.passengers.adults) {
      errors.add(
          'The number of infants cannot be greater than the number of adult passengers.');
      isValid = false;
    }
    return isValid;
  }

  _clearNewBookingObject() {
    newBooking.outboundflight = [];
    // List<String>();
    newBooking.returningflight = [];
    // List<String>();
    newBooking.passengerDetails = [];
    // List<PassengerDetail>();
    newBooking.paymentDetails = PaymentDetails();
    newBooking.contactInfomation = ContactInfomation();
  }

  showSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //Scaffold.of(context).showSnackBar(snackbar(message));
  }

  final NewBooking newBooking;
  final SystemColors systemColors;
  //final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FloatingActionButton.extended(
              elevation: 0.0,
              isExtended: true,
              label: Text(
                'SEARCH FLIGHTS',
                style: TextStyle(color: systemColors.primaryButtonTextColor),
              ),
              icon: Icon(Icons.check, color: systemColors.primaryButtonTextColor),
              backgroundColor:
                  systemColors.primaryButtonColor, //new Color(0xFF000000),
              onPressed: () {
                _clearNewBookingObject();
                hasDataConnection().then((result) async {
                  if (result == true) {
                    _validate(newBooking)
                        ? this.onChanged(await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => FlightSeletionPage(
                                    newBooking: newBooking))))
                        : _ackErrorAlert(context);
                  } else {
                    showSnackBar(
                        context, 'Please check your internet connection');
                  }
                });
              },
            ),
          ],
        ));
  }

  Future<void> _ackErrorAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops'),
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
