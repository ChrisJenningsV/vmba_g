import 'package:flutter/material.dart';

class BulletList extends StatelessWidget {
  final List<String> strings;

  BulletList(this.strings);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(6, 5, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings.map((str) {
          return Padding(
              padding: EdgeInsets.all(2),
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u2022',
                style: TextStyle(
              //    fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    str.replaceAll('\r\n', ''),
                    textAlign: TextAlign.left,
                    softWrap: true,
/*
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                      height: 1.55,
                    ),
*/
                  ),
                ),
              ),
            ],
          ));
        }).toList(),
      ),
    );
  }
}