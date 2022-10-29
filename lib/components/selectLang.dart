import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/language.dart';
import 'package:vmba/main.dart';
import 'package:vmba/utilities/helper.dart';


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

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}
initLangCached(String lang) async {
  if( gblSaveLangsFile) {
    final path = await _localPath;
    String filePath = '$path/lang.json';
    File file = File(filePath);
    if( file.existsSync()) {
      DateTime modified = file.lastModifiedSync();

      if( modified.isBefore(DateTime.now().subtract(Duration(hours: 24)))){
        // change to 2 days!
        // out of date - get new copy
        logit('lang file out of date');
        initLang(lang);
        return;
      }
      // is serverfile modified
      if( gblLangFileModTime != null && gblLangFileModTime.isNotEmpty){
        var serverFile = parseUkDateTime(gblLangFileModTime);
        if(modified.isBefore( serverFile )) {
          logit('lang new server file available');
          await initLang(lang);
          return;

        }
      }

      readLang( lang).then((result ) {
        gblLangMap = json.decode(result);
        gblLangFileLoaded = true;
        logit('using internal copy of $filePath');
/*
        Timer(Duration(seconds: 1), () {
          //
        });
*/
        return;
      });
    } else {
      logit('no cached lang file');
      await initLang(lang);
      return;
      }

    } else {
      await initLang(lang);
    }
  }




initLang(String lang) async {
  //Future<Countrylist> getCountrylist() async {
  if (gblLanguage != 'en' || gblSettings.wantEnglishTranslation  ) {
    logit('load lang $lang');

    if ( gblSettings.gblServerFiles != null && gblSettings.gblServerFiles.isNotEmpty) {
      try {

        final jsonString = await http.get(Uri.parse('${gblSettings.gblServerFiles}/$lang.json'), headers: {HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.acceptEncodingHeader: 'gzip,deflate,br'}); // , HttpHeaders.acceptCharsetHeader: "utf-8"

        // need to use byte and decode here otherwise special characters corrupted !
        String data = utf8.decode(jsonString.bodyBytes);
        if( data.startsWith('{')) {
          gblLangMap = json.decode(data);
          gblLangFileLoaded = true;
          logit('got lang file $lang');
          // save local file
          if( gblSaveLangsFile) {
            try {
              //var bytes = await consolidateHttpClientResponseBytes(response);
              final path = await _localPath;
              String filePath = '$path/lang.json';
              File file = File(filePath);
              await file.writeAsString(data);
              logit('saved lang file $filePath');

            } catch(e) {
              logit( 'save file error:$e');
            }

          }
        } else {
          logit('lang file  data error ' + data.substring(0,20));
          try {
            String jsn = await rootBundle.loadString(
                'lib/assets/$gblAppTitle/lang/$gblLanguage.json');
            gblLangMap = json.decode(jsn);
          } catch(e) {
            print(e);

          }

        }
      } catch(e) {
        print(e);
      }
    } else {
      logit('lang file error server files =' +gblSettings.gblServerFiles);

      String jsonString;
      jsonString = await rootBundle.loadString(
          'lib/assets/$gblAppTitle/lang/$gblLanguage.json');
      gblLangMap = json.decode(jsonString);
    }
  }
}
Future<bool> langFileExists(String lang) async {
  final path = await _localPath;
  String filePath = '$path/lang.json';
  File file = File(filePath);
  if( file.existsSync()){
    return true;
  }
  return false;
}

Future<void> deleteLang() async {
  final path = await _localPath;
  String filePath = '$path/lang.json';
  File file = File(filePath);
  if( file.existsSync()){
    file.delete();
  }
}



Future<String> readLang(String lang) async {
  try {
    final path = await _localPath;
    String filePath = '$path/lang.json';
    File file = File(filePath);

    // Read the file
    final contents = await file.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return null;
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
    //brightness: gblSystemColors.statusBar,
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
              // remove cached lang file
              deleteLang();
              //Intl.defaultLocale =selectedLang;
              Provider.of<LocaleModel>(context,listen:false).changelocale(Locale(selectedLang));
              gblLanguage=selectedLang;
              gblLangFileLoaded = false;
              initLang(gblLanguage);
              saveLang(gblLanguage);

              Navigator.of(context).pop();
              },
            child: TrText("Submit"
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
      return;
      // test data
      //gblSettings.gblLanguages = 'en,English,fr,French';
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
