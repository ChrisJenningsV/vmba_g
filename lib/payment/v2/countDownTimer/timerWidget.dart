import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CountDownTimer.dart';

class TimerWidget extends StatelessWidget {
  final VoidCallback timerExpired;

  const TimerWidget({Key key, this.timerExpired}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<CountDownTimer>(context, listen: false).start();
    return Consumer<CountDownTimer>(builder: (context, countDownTimer, child) {
      if (countDownTimer.formattedTime == '0:00') {
        timerExpired();
      }
      return Text(
        '${countDownTimer.formattedTime}',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
      );
    });
  }
}
