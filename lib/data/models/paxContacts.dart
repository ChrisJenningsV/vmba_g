


class PaxContacts {
  List<PaxContact>? contacts;

  PaxContacts();

  PaxContacts.fromJson(Map<String, dynamic> json) {
    if (json['contacts'] != null) {
      contacts = [];
      //new List<City>();
      if (json['contacts'] is List) {
        json['contacts'].forEach((v) {
          if (v != null) {
            //logit(v.toString());
            contacts!.add(new PaxContact.fromJson(v));
          }
        });
      } else {
        contacts!.add(new PaxContact.fromJson(json['contacts']));
      }
    }
  }
}

class PaxContact {
  String firstname = '';
  String lastname = '';
  String title = '';
  int paxNo=0;

  PaxContact.fromJson(Map<String, dynamic> json) {
    if (json['firstname'] != null) firstname = json['firstname'];

    List<String> titles = ['MR','MS','MISS','MRS', 'MSTR','DR', 'REV', 'PROF', 'CAPT', 'BARON', 'SIR',
      'COUNT', 'DAME', 'BARONESS', 'THERTHON', 'RABBI', 'LORD', 'VISCOUNT'];

    titles.forEach((titleVal) {
      if(firstname.endsWith(titleVal)) {
        title = titleVal;
        firstname = firstname.substring(0, firstname.length - titleVal.length);
      }
    });


    if (json['lastname'] != null) lastname = json['lastname'];
  }
}