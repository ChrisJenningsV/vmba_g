class PassengerTypes {
  bool adults ;
  bool youths;
  bool child ;
  bool infant;
  bool senior;
  bool student;

  bool wantInfantDOB;
  bool wantChildDOB ;
  bool wantYouthDOB;
  bool wantSeniorDOB;
  bool wantStudentDOB;

  int infantMinAge;
  int childMinAge ;
  int youthMinAge;
  int studentMinAge;
  int seniorMinAge;

  int infantMaxAge;
  int childMaxAge ;
  int youthMaxAge;
  int studentMaxAge;
  int seniorMaxAge;
//  bool umnr = false;

  PassengerTypes({this.adults=true, this.infant=false, this.youths=false, this.child=false, this.senior=false, this.student=false,
    this.wantInfantDOB=true,
    this.wantChildDOB=true,
    this.wantYouthDOB=false,
    this.wantStudentDOB=false,
    this.wantSeniorDOB=false,
    this.infantMinAge=0,
    this.childMinAge=0,
    this.youthMinAge=12,
    this.studentMinAge=0,
    this.seniorMinAge=0,
    this.infantMaxAge=0,
    this.childMaxAge=0,
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

