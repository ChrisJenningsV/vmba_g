import 'package:flutter/widgets.dart';
import 'package:vmba/utilities/helper.dart';

class Faqs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'What’s the benefit of the ‘My account’ feature?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'If you’re booking with Loganair for the first time using the App, set up ‘My account’ with your details. You only need do this once; it will save your details for future flights making the booking process quick and easy. Adding your Clan details here will ensure you do not have to enter your password every time.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'I can’t see a booking, how do I add it?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'If your booking isn’t in the ‘My Bookings & Check-In’ screen, from the menu press the “add an existing booking” button. Simply enter your booking reference and surname, and it will be added to your booking list in flight date order. Alternatively you may import all bookings associated to your Clan account using the “Import Bookings” function under “My Bookings”'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I amend my booking?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Wrap(children: renderAmendBooking()),
        //Text(
        //     'Bookings can’t be amended via the App. Visit loganair.co.uk and select “Manage Booking & Check-In” to make amendments to your booking. Alternatively call our customer contact centre on 0344 800 2855'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I add my Clan number to my bookings?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Wrap(children: renderAddMyClanNumber()),
        // Text(
        //     'If you have updated the ‘My account’ section with your Clan membership number, then it will populate the appropriate field in the booking, or you can add it manually when completing the passenger details section. If you forgot to include your clan number in your booking, don’t worry, you can use the “missing points” form to claim Clan points. Visit loganair.co.uk/claim-missing-clan-points/'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I get a mobile boarding pass?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'On the home screen, select My Bookings & Check-in. Your bookings are displayed in flight date order. You can check-in 96 hours ahead of your departure time, and once checked-in your boarding pass will be visible. When you’re at the airport, select your booking, and press “Boarding Pass”'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I use a mobile boarding pass?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'The mobile boarding pass can be used instead of a normal boarding pass. It can be scanned directly from your phone at check-in, security gates, and presented to the cabin attendant as you board the aircraft.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I store my boarding pass in my wallet? ',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'Simply press the “Add to Apple Wallet” button found under the boarding pass. Note that any changes to seat or Gate will not be reflected on a boarding pass stored within the wallet. For the most up to date information, check the boarding pass within the Loganair app.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'What happens if my phone runs out of charge?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'Please go to a Loganair check-in desk where we will print a boarding pass for you at nil charge.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'I am travelling with a group; can we all use boarding passes on my phone?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'Yes you can have more than one boarding pass on your phone, or alternatively you can screenshot each passengers boarding pass and send to the individual(s) travelling.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'My flight has departed; can I still see the boarding pass?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'Your boarding pass will be viewable for upto 24 hours after the departure of your flight.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I book a youth travelling solo?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Wrap(children: renderYouthTravellingSolo()),
        Padding(padding: EdgeInsets.all(8)),
        Wrap(
          children: renderAnyOtherQuestions(),
        ),
        Padding(
          padding: EdgeInsets.all(8),
        ),
      ],
    );
  }

  List<Widget> renderAmendBooking() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
            'Bookings can be amended using the App. Select “My Bookings & Check-in”, retrieve the booking you which to amend, and make any itinerary changes as required. Alternatively, call our customer contact centre on ')
        .forEach((widget) {
      widgets.add(widget);
    });

    widgets.add(appLinkWidget(
        'tel:0344 800 2855',
        Text('0344 800 2855',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));

    return widgets;
  }

  List<Widget> renderAddMyClanNumber() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
            'If you have updated the ‘My account’ section with your Clan membership number, then it will populate the appropriate field in the booking, or you can add it manually when completing the passenger details section. If you forgot to include your clan number in your booking, don’t worry, you can use the “missing points” form to claim Clan points. Visit  ')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'https://loganair.co.uk/claim-missing-clan-points/',
        Text('loganair.co.uk/claim-missing-clan-points/',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    // textSpliter('and select “Manage Booking & Check-In” to make amendments to your booking. Alternatively call our customer contact centre on').forEach((widget) {
    //   widgets.add(widget);
    // });

    // widgets.add(appLinkWidget(
    //     'tel:0344-800-2855',
    //     Text('0344 800 2855',
    //         style: TextStyle(
    //           decoration: TextDecoration.underline,
    //         ))));

    return widgets;
  }

  List<Widget> renderYouthTravellingSolo() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter('Please contact our customer contact centre on ')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'tel:0344-800-2855',
        Text('0344 800 2855',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    textSpliter(' to book.').forEach((widget) {
      widgets.add(widget);
    });

    return widgets;
  }

  List<Widget> renderAnyOtherQuestions() {
    List<Widget> widgets = [];
    // List<Widget>();

    // Text(
    //           'If you have other questions, please visit loganair.co.uk, or call our customer contact centre on 0344 800 2855',
    // style: TextStyle(fontWeight: FontWeight.w700),

    textSpliterBoldText('If you have other questions, please visit ')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'https://loganair.co.uk',
        Text('loganair.co.uk',
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ))));
    textSpliterBoldText(', or call our customer contact centre on ')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'tel;0344-800-2855',
        Text('0344 800 2855',
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ))));
    return widgets;
  }
}
