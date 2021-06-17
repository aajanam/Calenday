

class RegUser {

  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String specialty;
  final String workPlace1;
  final String workPlace2;
  final String workPlace3;
  final String deviceToken;
  final List nameSearch;
  final List colleagues;
  final List groups;

  RegUser({
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.specialty,
    this.workPlace1,
    this.workPlace2,
    this.workPlace3,
    this.deviceToken,
    this.nameSearch,
    this.colleagues,
    this.groups

  });

  factory RegUser.fromJson(Map<String, dynamic> json){
    return RegUser(
        uid: json['uid'],
        displayName: json['displayName'],
        email: json['email'],
        photoUrl: json['photoUrl'],
        specialty: json['specialty'],
        workPlace1: json['workPlace1'],
        workPlace2: json['workPlace2'],
        workPlace3: json['workPlace3'],
        deviceToken: json['deviceToken'],
        nameSearch: json['nameSearch'],
        colleagues: json['colleagues'],
        groups: json['groups'],

    );
  }

  Map<String,dynamic> toMap(){
    return {
      'uid': uid,
      'displayName':displayName,
      'email':email,
      'photoUrl': photoUrl,
      'specialty': specialty,
      'workPlace1': workPlace1,
      'workPlace2': workPlace2,
      'workPlace3': workPlace3,
      'deviceToken': deviceToken,
      'nameSearch': nameSearch,
      'colleagues': colleagues,
      'groups': groups,

    };
  }
}

