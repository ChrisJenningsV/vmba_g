import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/language.dart';

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
    if ( gblServerFiles != null && gblServerFiles.isNotEmpty) {
      try {
        final jsonString = await http.get(Uri.parse('$gblServerFiles$lang.json'));
        String data = jsonString.body;
        if( data.startsWith('{')) {
          gblLangMap = json.decode(jsonString.body);
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
//    color: Colors.grey,
  height: 200,
    child: Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(5.0),
          alignment: Alignment.topRight,
          child: Icon(
            Icons.close,
            color: Colors.grey,
            size: 20.0,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0, bottom: 10.0),
          color: Colors.white,
          child: TrText(
            "Select your preferred language",
            style: TextStyle( fontSize: 20.0, fontWeight: FontWeight.bold),
            //labelColor: AppColors.dialogTitleColor,
            //fontWeight: FontWeight.bold,
          ),
        ),
        Flexible(
          child: new MyDialogContent(),//Custom ListView
        ),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Padding(
              padding:
            const EdgeInsets.only(left: 8.0, right: 8.0, top: 3.0, bottom: 3.0),
            child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: gblSystemColors.primaryButtonColor ,
                side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                primary: gblSystemColors.primaryButtonTextColor),
            onPressed: () {
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
    /*
    return AlertDialog(
      title: Row(
          children: [
            Image.network('$gblServerFiles/images/world.png',
              width: 25, height: 25, fit: BoxFit.contain,),
            TrText('Select preferred language')
          ]
      ),
      content: myContent(),
//    Text('test'), //contentBox(context),MyDialogContent(), //
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.black12),
          child: TrText("CANCEL", style: TextStyle(
              backgroundColor: Colors.black12, color: Colors.black),),
          onPressed: () {
            //Put your code here which you want to execute on Cancel button click.
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child:
          new TrText("Save", style: TextStyle(color: Colors.white)),
          onPressed: () {
            gblLanguage = selectedLang;
            initLang(gblLanguage);
            saveLang(gblLanguage);
            Navigator.of(context).pop();
          },
        ),
      ],
    );


     */

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

  Widget myContent() {
    List<CustomRowModel> sampleData = [];
    if (gblLanguages == null || gblLanguages.isEmpty) {
      // test data
      gblLanguages = 'en,English,fr,French';
    }

    List<String> langs = gblLanguages.split(',');
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

    return Container(height: 200, child: Column(children: list,));
  }
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
    if( gblLanguages == null || gblLanguages.isEmpty ) {
      // test data
      gblLanguages = 'en,English,fr,French';
    }

    List<String> langs = gblLanguages.split(',');
    var count = langs.length /2;
    for( var i = 0 ; i <= count; i+=2){
      var selected = false;
      if( langs[i] == gblLanguage) {
        selected=true;
      }
      sampleData.add(CustomRowModel(title: langs[i+1], selected: selected, code: langs[i]));
    }

/*    sampleData.add(CustomRowModel(title: "English", selected: false, code: 'en'));
    sampleData.add(CustomRowModel(title: "French", selected: false, code: 'fr'));
    sampleData.add(CustomRowModel(title: "Swedish", selected: false, code: 'sw'));

 */
  }

  @override
  Widget build(BuildContext context) {
    return sampleData.length == 0
        ? Container()
        : Container(
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
