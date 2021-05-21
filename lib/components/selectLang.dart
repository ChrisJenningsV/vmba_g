import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';

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

dialogContent(BuildContext context) {
  return Container(
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
          margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
          color: Colors.white,
          child: Text(
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
                backgroundColor: gbl_SystemColors.primaryButtonColor ,
                side: BorderSide(color:  gbl_SystemColors.textButtonTextColor, width: 1),
                primary: gbl_SystemColors.primaryButtonTextColor),
            onPressed: () {
              gblLanguage=selectedLang;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
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

    List<String> langs = gblLanguages.split(',');
    var count = langs.length /2;
    for( var i = 0 ; i <= count; i+=2){
      sampleData.add(CustomRowModel(title: langs[i+1], selected: false, code: langs[i]));
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
