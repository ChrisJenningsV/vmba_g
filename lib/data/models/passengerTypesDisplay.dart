
class PassengerTypes {
  bool adults =false;
  bool youths =false;
  bool child  =false;
  bool infant =false;
  bool senior =false;
  bool student =false;

  bool wantAdultDOB =false;
  bool wantInfantDOB =false;
  bool wantChildDOB  =false;
  bool wantYouthDOB =false;
  bool wantSeniorDOB =false;
  bool wantStudentDOB =false;

  int adultMinAge=16;
  int infantMinAge=0;
  int childMinAge =0;
  int youthMinAge=0;
  int studentMinAge=0;
  int seniorMinAge=0;

  int infantMaxAge=2;
  int childMaxAge =0;
  int youthMaxAge=0;
  int studentMaxAge=0;
  int seniorMaxAge=0;
//  bool umnr = false;

  PassengerTypes({this.adults=true, this.infant=false, this.youths=false, this.child=false, this.senior=false, this.student=false,
    this.wantAdultDOB=false,
    this.wantInfantDOB=true,
    this.wantChildDOB=true,
    this.wantYouthDOB=false,
    this.wantStudentDOB=false,
    this.wantSeniorDOB=false,
    this.adultMinAge=16,
    this.infantMinAge=0,
    this.childMinAge=0,
    this.youthMinAge=12,
    this.studentMinAge=0,
    this.seniorMinAge=0,
    this.infantMaxAge=2,
    this.childMaxAge=12,
    this.youthMaxAge=15,
    this.studentMaxAge=0,
    this.seniorMaxAge=0,
  });

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

