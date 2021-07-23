class PassengerTypes {
  bool adults ;
  bool youths;
  bool child ;
  bool infant;
  bool senior;
  bool student;
//  bool umnr = false;

  PassengerTypes({this.adults, this.infant, this.youths, this.child, this.senior, this.student});

  PassengerTypes.fromJson(Map<String, dynamic> json) {
      this.adults = ['adults'] != null &&
              json['adults'].toString().toLowerCase() ==
                  'false'
          ? false
          : true;
      this.youths = json['youths'] != null &&
              json['youths'].toString().toLowerCase() ==
                  'true'
          ? true
          : false;

      this.child = json['childern'] != null &&
              json['childern'].toString().toLowerCase() == 'true'
          ? true
          : false;

      this.infant = json['infants'] != null &&
              json['infants'].toString().toLowerCase() ==
                  'true'
          ? true
          : false;

      this.senior = json['seniors'] != null &&
              json['seniors'].toString().toLowerCase() ==
                  'true'
          ? true
          : false;
      this.student = json['students'] != null &&
          json['students'].toString().toLowerCase() ==
              'true'
          ? true
          : false;
/*      this.umnr = json['umnrs'] != null &&
          json['umnrs'].toString().toLowerCase() ==
              'true'
          ? true
          : false;

 */
  }

    Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    
    data['adults'] = this.adults.toString();
    data['youths'] = this.youths.toString();
    data['childern'] = this.child.toString();
    data['infants'] = this.infant.toString();
    data['seniors'] = this.senior.toString();
    data['students'] = this.student.toString();
    //data['umnrs'] = this.umnr.toString();

    return data;
  }
}
