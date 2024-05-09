import 'package:flutter/widgets.dart';
import 'package:vmba/utilities/helper.dart';

class ContactUs extends StatelessWidget {
  List<Widget> renderOne() {
    List<Widget> widgets = [];
    // List<Widget>();
    textSpliter(
            'If you need any help with a new booking, amending a booking, or have a general enquiry then call our customer contact centre on ')
        .forEach((widget) {
      widgets.add(widget);
    });
    //widgets.add(appLink('tel:+44 344 800 2855', '0344 800 2855'));
    widgets.add(appLinkWidget(
        'tel',
        '0344-800-2855',
        Text('0344 800 2855',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    widgets.add(Text(' or email '));
    widgets.add(appLinkWidget(
        'mailto',
        'bookings@loganair.co.uk',
        Text('bookings@loganair.co.uk',
            style: TextStyle(
              decoration: TextDecoration.underline,
            )),
      queryParameters: {'subject': 'bookings'}
    )
    );
    widgets.add(Text('. '));
    widgets.add(Text('If calling from outside the UK, call '));
    widgets.add(appLinkWidget(
        'tel',
        '+44-141-642-9407',
        Text('+44 141 642 9407',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    //widgets.add(appLink('tel:+44 344 800 2855', '+44 141 642 9407'));
    return widgets;
  }

  List<Widget> render4() {
    List<Widget> widgets = [];
    // List<Widget>();

    textSpliter(
            'If you want to get in touch on a customer service issue, please complete our online')
        .forEach((widget) {
      widgets.add(widget);
    });
    widgets.add(appLinkWidget(
        'https',
        '//loganair.co.uk/contact-3/customer-relations/feedback-form/',
        Text('feedback form',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ))));
    return widgets;
  }

  List<Widget> renderDefault() {
    return <Widget>[
      Wrap(children: renderOne()),
      Padding(padding: EdgeInsets.all(8)),
      Wrap(children: <Widget>[
        Wrap(
          children: <Widget>[
            Text('If you have a group booking enquiry, please email'),
            appLinkWidget(
                'mailto',
                'groups@loganair.co.uk?subject=groups',
                Text('groups@loganair.co.uk',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ))),
            //appLink('mailto:groups@loganair.co.uk?subject=groups',
            //    'groups@loganair.co.uk'),
          ],
        ),
      ]),
      Padding(padding: EdgeInsets.all(8)),
      Wrap(children: <Widget>[
        Text('If you are enquiring about a refund, please email '),
        appLinkWidget(
            'mailto',
            'refunds@loganair.co.uk?subject=refunds',
            Text('refunds@loganair.co.uk',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ))),

        // appLink('mailto:refunds@loganair.co.uk?subject=refunds',
        //     'refunds@loganair.co.uk'),
      ]),
      Padding(padding: EdgeInsets.all(8)),
      Wrap(children: render4()),
      Padding(padding: EdgeInsets.all(8)),
      Expanded(
        child: Center(
          child: Column(
            children: <Widget>[
              Text('Opening Hours'),
              Padding(padding: EdgeInsets.all(8)),
              Text('Monday - Friday 07:00 - 19:00'),
              Text('Saturday 08:00 - 16:00'),
              Text('Sunday 10:00 - 18:00'),
            ],
          ),
        ),
      ),
      Padding(padding: EdgeInsets.all(8)),
      Padding(
        padding: EdgeInsets.all(8),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: renderDefault());
  }
}
