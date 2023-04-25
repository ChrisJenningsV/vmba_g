import 'package:flutter/widgets.dart';
import 'package:vmba/utilities/helper.dart';

class ContactUs extends StatelessWidget {
  List<Widget> renderOne() {
    List<Widget> widgets = [];
    // List<Widget>();
    textSpliter(
            'As well as making a flight booking, our Customer Care team can answer your questions regarding flying with Blue Islands.')
        .forEach((widget) {
      widgets.add(widget);
    });
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
        'https:loganair.co.uk/contact-3/customer-relations/feedback-form/',
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
      appLinkWidget(
          'mailto:customercare@blueislands.com?subject=enquire',
          Text('customercare@blueislands.com',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ))),
      Padding(padding: EdgeInsets.all(8)),
      appLinkWidget(
          'tel:01234 589200',
          Text('01234 589200',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ))),
      Padding(padding: EdgeInsets.all(8)),
      Text('09:00-17:30 Mon-Fri (except bank holidays)'),
      Padding(padding: EdgeInsets.all(8)),
      Text('10:00-16:00 Sat-Sun (and bank holidays)'),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: renderDefault());
  }
}
