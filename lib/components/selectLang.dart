import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/language.dart';
import 'package:vmba/main.dart';


class CustomRowModel {
  bool selected;
  String title;
  String code;
  CustomRowModel({this.selected, this.title, this.code});
}
String selectedLang = 'en';

class CustomRow extends StatelessWidget {
  final CustomRowModel model;
  CustomRow(this.model);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(left: 8.0, right: 8.0, top: 3.0, bottom: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
// I have used my own CustomText class to customise TextWidget.
          Text( model.title,
          ),
          this.model.selected
              ? Icon(
            Icons.radio_button_checked,
            color: Colors.amber,
          )
              : Icon(Icons.radio_button_unchecked),
        ],
      ),
    );
  }
}

initLang(String lang) async {
  //Future<Countrylist> getCountrylist() async {
  if (gblLanguage != 'en') {
    if ( gblSettings.gblServerFiles != null && gblSettings.gblServerFiles.isNotEmpty) {
      try {

        final jsonString = await http.get(Uri.parse('${gblSettings.gblServerFiles}/$lang.json'), headers: {HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.acceptEncodingHeader: 'gzip,deflate,br'}); // , HttpHeaders.acceptCharsetHeader: "utf-8"

        // need to use byte and decode here otherwise special characters corrupted !
        String data = utf8.decode(jsonString.bodyBytes);
        if( data.startsWith('{')) {
          gblLangMap = json.decode(data);
        } else {
          String jsn = await rootBundle.loadString(
              'lib/assets/lang/$gblLanguage.json');
           gblLangMap = json.decode(jsn);

        }
      } catch(e) {
        print(e);
      }
    } else {
      String jsonString;
      jsonString = await rootBundle.loadString(
          'lib/assets/lang/$gblLanguage.json');
      gblLangMap = json.decode(jsonString);
    }
  }

}
dialogContent(BuildContext context) {
  return Container(
//  height: 270,
    constraints: BoxConstraints(
      maxHeight: double.infinity,
    ),
    child: Column(
      children: <Widget>[
    AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    brightness: gblSystemColors.statusBar,
      backgroundColor: gblSystemColors.primaryHeaderColor,
      iconTheme: IconThemeData(
          color: gblSystemColors.headerTextColor),
      title: new TrText('Select language',
        style: TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.bold,
            color: gblSystemColors.headerTextColor),
        ),
    ),



        Container( //) Flexible(
          child: new MyDialogContent(),//Custom ListView
        ),
        SizedBox(
          height: 70,
          width: double.infinity,
          child: Padding(
              padding:
            const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
            child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: gblSystemColors.primaryButtonColor ,
                side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                primary: gblSystemColors.primaryButtonTextColor),
            onPressed: () {
              //Intl.defaultLocale =selectedLang;
              Provider.of<LocaleModel>(context,listen:false).changelocale(Locale(selectedLang));
              gblLanguage=selectedLang;
              initLang(gblLanguage);
              saveLang(gblLanguage);
              Navigator.of(context).pop();
              },
            child: Text("Submit"
              //fontWeight: FontWeight.bold,
              //fontSize: 16.0,
            ),
          ),
        ),)
      ],
    ),
  );

}


class LanguageSelection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LanguageSelectionState();
  }
}

class LanguageSelectionState extends State<LanguageSelection> {
  @override
  void initState() {
    selectedLang = gblLanguage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      //margin: EdgeInsets.only(top: 50.0, bottom: 150.0),
      alignment: Alignment.center,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        elevation: 25.0,
        backgroundColor: Colors.white,
        child: dialogContent(context),
      ),
    );

  }

  /*
  Widget myContent() {
    List<CustomRowModel> sampleData = [];
    if (gblSettings.gblLanguages == null || gblSettings.gblLanguages.isEmpty) {
      // test data
      gblSettings.gblLanguages = 'en,English,fr,French';
    }

    List<String> langs = gblSettings.gblLanguages.split(',');
    List<Widget> list = [];
    var count = langs.length / 2;
    for (var i = 0; i <= count; i += 2) {
      var selected = false;
      if (langs[i] == selectedLang) {
        selected = true;
      }
      //sampleData.add(CustomRowModel(title: langs[i+1], selected: selected, code: langs[i]));
      var ink = new InkWell(
        //highlightColor: Colors.red,
        //splashColor: Colors.blueAccent,
        onTap: () {
          setState(() {
            sampleData.forEach((element) => element.selected = false);
            //sampleData[i].selected = true;
            selectedLang = sampleData[i].code;
          });
        },
        child: new CustomRow(CustomRowModel(
            title: langs[i + 1], selected: selected, code: langs[i]))
      );
      list.add(ink);
    }

/*  list.add(Text('text 1'));
  list.add(Text('text 2'));
  list.add(Text('text 3'));

 */

    return Container( child: Column(children: list,)); // height: 200,
  }

   */
}




class MyDialogContent extends StatefulWidget {
  @override
  _MyDialogContentState createState() => new _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {
  List<CustomRowModel> sampleData = [] ;

  @override
  void initState() {
    super.initState();
    if( gblSettings.gblLanguages == null || gblSettings.gblLanguages.isEmpty ) {
      // test data
      gblSettings.gblLanguages = 'en,English,fr,French';
    }

    List<String> langs = gblSettings.gblLanguages.split(',');
    var count = langs.length;
    for( var i = 0 ; i < count; i+=2){
      var selected = false;
      if( langs[i] == gblLanguage) {
        selected=true;
      }
      sampleData.add(CustomRowModel(title: langs[i+1], selected: selected, code: langs[i]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return sampleData.length == 0
        ? Container()
        : Container(
      padding: EdgeInsets.all(10) ,
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey,
        ),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: sampleData.length,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            //highlightColor: Colors.red,
            //splashColor: Colors.blueAccent,
            onTap: () {
              setState(() {
                sampleData.forEach((element) => element.selected = false);
                sampleData[index].selected = true;
                selectedLang = sampleData[index].code;
              });
            },
            child: new CustomRow(sampleData[index]),
          );
        },
      ),
    );
  }

}
