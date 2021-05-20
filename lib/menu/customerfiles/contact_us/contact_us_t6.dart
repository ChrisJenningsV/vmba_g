import 'package:flutter/widgets.dart';
//import 'package:vmba/utilities/helper.dart';

class ContactUs extends StatelessWidget {
  List<Widget> renderDefault() {
    return <Widget>[
      Padding(padding: EdgeInsets.all(8)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: renderDefault());
  }
}
