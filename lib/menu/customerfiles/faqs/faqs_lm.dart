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
            "If you are booking with Loganair for the first time using the App, set up 'My Account' with your details. You only need to do this once and it will save your details for future flights, making the booking process quick and easy. Adding your Loyalty account details here will mean you do not have to enter your password every time." ),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'I can’t see a booking, how do I add it?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            "If your booking is not in the 'My Bookings' screen, you can select the tab 'Add an existing booking'. Simply enter your booking reference and surname and it will be added to your booking list in flight date order. Alternatively, using the 'Import Bookings' tab you may use your Loyalty number to import all of your future bookings."),
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
          'How do I add my Loyalty number to my bookings?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Wrap(children: renderAddMyClanNumber()),
        // Text(
        //     'If you have updated the ‘My account’ section with your Clan membership number, then it will populate the appropriate field in the booking, or you can add it manually when completing the passenger details section. If you forgot to include your clan number in your booking, don’t worry, you can use the “missing points” form to claim Clan points. Visit loganair.co.uk/claim-missing-clan-points/'),
        Padding(padding: EdgeInsets.all(8)),

        Text(
          'Can I receive Avios for past dated flights where I forgot to add my Loyalty number?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Wrap(children: renderAvios()),

        Padding(padding: EdgeInsets.all(8)),

        Text(
          'How do I get a mobile boarding pass?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            "On the home screen, select 'My Bookings'. Your bookings are displayed in flight date order. You can check-in 96 hours ahead of your departure time. Once checked in, a button will appear to display your boarding pass."),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I use a mobile boarding pass?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'The mobile boarding pass can be used in place of a paper boarding pass. It can be scanned directly from the phone screen at check-in, security gates, and as you board the aircraft.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I store my boarding pass in my wallet? ',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            "Simply press the 'Add to Wallet' button which appears underneath the boarding pass. Note that any changes to seat or gate may not be reflected dynamically on the boarding pass saved within the wallet. For the most up to date information please check the boarding pass within the Loganair app."),
        Padding(padding: EdgeInsets.all(8)),

        Text(
          'What happens if my phone runs out of charge?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            "Please go to a Loganair check-in desk, where we will print a paper boarding pass for you, free of charge."),
        Padding(padding: EdgeInsets.all(8)),

        Text(
          'I am travelling with a group; can we all use boarding passes on my phone?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'Yes, you may use the same phone to retrieve the boarding pass for multiple passengers. Alternatively, you may store one booking on multiple phones to allow each passenger access to their own boarding pass.'),
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
            "Flights can be changed using the App. Select 'My Bookings', retrieve the booking you wish to amend and press 'Change Flight'. Alternatively, call our customer contact centre on ")
        .forEach((widget) {
      widgets.add(widget);
    });

    widgets.add(appLinkWidget(
        'tel',
        '0344 800 2855',
        Text('0344 800 2855',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    textSpliter(
        " and we would be happy to help.")
        .forEach((widget) {
      widgets.add(widget);
    });
    return widgets;
  }

  List<Widget> renderAddMyClanNumber() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
            "If you have updated the 'My Account' section with your Loyalty number, then it will automatically add your Loyalty number when making bookings through the App. If you forget to include your Loyalty number on any booking, you can add it through Manage My Booking on the website, so long as you have not yet checked in for the flight.")
        .forEach((widget) {
      widgets.add(widget);
    });
   /* widgets.add(appLinkWidget(
        'https',
          '//loganair.co.uk/claim-missing-clan-points/',
        Text('loganair.co.uk/claim-missing-clan-points/',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
*/
    return widgets;
  }
  List<Widget> renderAvios() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
        "Yes, we allow customers to claim Avios for flights they have taken, so long as the claim is submitted within 3 months of travel. Submissions may be made via this online form: ")
        .forEach((widget) {
      widgets.add(widget);
    });
     widgets.add(appLinkWidget(
        'https',
          '//www.loganair.co.uk/loganair-loyalty/missing-avios',
        Text('www.loganair.co.uk/loganair-loyalty/missing-avios',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
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
        'tel',
          '0344-800-2855',
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
        'https',
          '//loganair.co.uk',
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
        'tel',
      '0344-800-2855',
        Text('0344 800 2855',
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ))));
    return widgets;
  }
}
