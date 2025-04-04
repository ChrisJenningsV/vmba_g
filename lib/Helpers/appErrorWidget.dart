


import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  //final FlutterErrorDetails errorDetails;

  const AppErrorWidget( {/*required this.errorDetails,*/super.key});

  @override
  Widget build(BuildContext context) {
    return  Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              size: 200,
              color: Colors.amber,
            ),
            SizedBox(height: 48),
            Text(
              'So... something funny happened',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This error is crazy large it covers your whole screen. But no worries'
                  ' though, we\'re working to fix it.\n\n' /*+
                  errorDetails.summary.toString()*/,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}