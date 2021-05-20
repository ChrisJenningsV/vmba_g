import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vmba/utilities/helper.dart';

class Faqs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'I can’t see a booking, how do I add it?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'If your booking isn’t in the ‘My Bookings & Check-In’ screen, from the menu press the “add an existing booking” button. Simply enter your booking reference and surname, and it will be added to your booking list in flight date order.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I amend my booking?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Wrap(children: renderAmendBooking()),
/*         Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I add my Blue Skies number to my bookings?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Wrap(children: renderAddMyFqtvNumber()), */
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'How do I get a mobile boarding pass?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'On the home screen, select My Bookings & Check-in. Your bookings are displayed in flight date order. You can check-in 48 hours ahead of your departure time, and once checked-in your boarding pass will be visible. When you’re at the airport, select your booking, and press “Boarding Pass”'),
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
            'No need. Your boarding pass can be retrieved via the app when you’re offline.'),
        Padding(padding: EdgeInsets.all(8)),
        Text(
          'What happens if my phone runs out of charge?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
            'Please go to a Air Swift check-in desk where we will print a boarding pass for you at nil charge.'),
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
            'Bookings can be amended using the App. Select “My Bookings & Check-in”, retrieve the booking you wish to amend, and make any itinerary changes as required. Alternatively, call our customer contact centre on ')
        .forEach((widget) {
      widgets.add(widget);
    });

    widgets.add(appLinkWidget(
        'tel;+63 5318 5940',
        RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(Icons.phone, size: 14),
              ),
              TextSpan(
                text: ' ',
              ),
              TextSpan(
                  text: '+63 (2) 5318 5940',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  )),
            ],
          ),
        )));
    widgets.add(appLinkWidget(
        'tel;+63 917 816 8763',
        RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(Icons.phone_iphone, size: 14),
              ),
              TextSpan(
                text: ' ',
              ),
              TextSpan(
                  text: '+63 917 816 8763',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  )),
            ],
          ),
        )));

    return widgets;
  }

  List<Widget> renderAddMyFqtvNumber() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
            'You can add it manually when completing the passenger details section.')
        .forEach((widget) {
      widgets.add(widget);
    });
    // widgets.add(appLinkWidget(
    //     'https://loganair.co.uk/claim-missing-clan-points/',
    //     Text('loganair.co.uk/claim-missing-clan-points/',
    //         style: TextStyle(
    //           decoration: TextDecoration.underline,
    //         ))));
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
        'tel:01234 589200',
        Text('01234 589200',
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
        'https://air-swift.com',
        Text('www.air-swift.com',
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w700,
            ))));
    textSpliterBoldText(', or call our customer contact centre on ')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'tel;+63 5318 5940',
        RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(Icons.phone, size: 14),
              ),
              TextSpan(
                text: ' ',
              ),
              TextSpan(
                  text: '+63 (2) 5318 5940',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  )),
            ],
          ),
        )));
    widgets.add(appLinkWidget(
        'tel;+63 917 816 8763',
        RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(Icons.phone_iphone, size: 14),
              ),
              TextSpan(
                text: ' ',
              ),
              TextSpan(
                  text: '+63 917 816 8763',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  )),
            ],
          ),
        )));
    return widgets;
  }
}
