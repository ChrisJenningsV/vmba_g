class PassengerTypes {
  bool adults = true;
  bool youths = true;
  bool child = true;
  bool infant = true;
  bool senior = true;

  PassengerTypes(
      {bool adult, bool infant, bool youth, bool child, bool senior});

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
  }

    Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    
    data['adults'] = this.adults.toString();
    data['youths'] = this.adults.toString();
    data['childern'] = this.adults.toString();
    data['infants'] = this.adults.toString();
    data['seniors'] = this.adults.toString();

    return data;
  }
}
