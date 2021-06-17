import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/services/firestore_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UserProvider with ChangeNotifier {


  final firestoreService = FireStore();

  String _uid;
  String _displayName;
  String _email;
  String _photoUrl;
  String _specialty;
  String _workPlace1;
  String _workPlace2;
  String _workPlace3;
  String _deviceToken;
  List _nameSearch;
  List _colleagues;
  List _groups;


  //Getters

  String get uid => _uid;

  String get displayName => _displayName;

  String get email => _email;

  String get photoUrl => _photoUrl;

  String get specialty => _specialty;

  String get workPlace1 => _workPlace1;
  String get workPlace2 => _workPlace2;
  String get workPlace3 => _workPlace3;

  List get nameSearch => _nameSearch;
  List get colleagues => _colleagues;
  List get groups => _groups;

  String get deviceToken => _deviceToken;

  Stream  get singleUser => firestoreService.singleUser(uid);

  Stream<List<RegUser>> get users => firestoreService.getUser();

  Future<List<RegUser>> get futureUser => firestoreService.userFuture();


  //Setters
  set uid(String value) {
    _uid = value;
    notifyListeners();
  }

  set displayName(String value) {
    _displayName = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set photoUrl(String value) {
    _photoUrl = value;
    notifyListeners();
  }

  set specialty(String value) {
    _specialty = value;
    notifyListeners();
  }

  set workPlace1(String value) {
    _workPlace1 = value;
    notifyListeners();
  }

  set workPlace2(String value) {
    _workPlace2 = value;
    notifyListeners();
  }

  set workPlace3(String value) {
    _workPlace3 = value;
    notifyListeners();
  }

  set nameSearch(List value) {
    _nameSearch = value;
    notifyListeners();
  }

  set colleagues(List value) {
    _colleagues = value;
    notifyListeners();
  }

  set groups(List value) {
    _groups = value;
    notifyListeners();
  }

  set deviceToken(String value) {
    _deviceToken = value;
    notifyListeners();
  }


  //Functions
  loadAll(RegUser user) async {
    if (user != null) {
      _uid = user.uid;
      _displayName = user.displayName;
      _email = user.email;
      _photoUrl = user.photoUrl;
      _specialty = user.specialty;
      _workPlace1 = user.workPlace1;
      _workPlace2 = user.workPlace2;
      _workPlace3 = user.workPlace3;
      _nameSearch = user.nameSearch;
      _colleagues = user.colleagues;
      _groups = user.groups;
      _deviceToken = user.deviceToken;
    } else {
      _uid = uid;
      _displayName = displayName;
      _email = email;
      _photoUrl = photoUrl;
      _specialty = specialty;
      _workPlace1 = workPlace1;
      _workPlace2 = workPlace2;
      _workPlace3 = workPlace3;
      _nameSearch = nameSearch;
      _colleagues = colleagues;
      _groups = groups;
      _deviceToken = deviceToken;
    }
  }

  loadQuery(String list) async {
    _uid = uid;
    _displayName = displayName;
    _email = email;
    _photoUrl = photoUrl;
    _specialty = specialty;
    _workPlace1 = workPlace1;
    _workPlace2 = workPlace2;
    _workPlace3 = workPlace3;
    _nameSearch = nameSearch;
    _colleagues = colleagues;
    _groups = groups;
    _deviceToken = deviceToken;
  }

  setUser() {
    if (_uid == null) {
      getPlayerId();
      //Add
      var newUser = RegUser(
          uid : Auth().currentUser.uid,
          displayName : Auth().currentUser.displayName,
          email : Auth().currentUser.email,
          photoUrl : Auth().currentUser.photoURL,
          specialty : _specialty,
          workPlace1 :_workPlace1,
          workPlace2 :_workPlace2,
          workPlace3 :_workPlace3,
          nameSearch : setSearchParam(Auth().currentUser.displayName.toLowerCase()),
          colleagues : [

          ],
          groups : ['All'],
          deviceToken : _deviceToken);
      firestoreService.setUser(newUser, uid);
    } else {
      getPlayerId();
      var editUser = RegUser(
          uid : _uid,
          displayName : _displayName,
          email : _email,
          photoUrl : _photoUrl,
          specialty : _specialty,
          workPlace1 :_workPlace1,
          workPlace2 :_workPlace2,
          workPlace3 :_workPlace3,
          nameSearch : _nameSearch,
          colleagues : _colleagues,
          groups : _groups,
          deviceToken : _deviceToken);
      firestoreService.setUser(editUser, uid);

    }
  }
  setSearchParam(String name) {
    List<String> nameSearchList = [];
    String temp = "";
    for (int i = 0; i < name.length; i++) {
      temp = temp + name[i];
      nameSearchList.add(temp);
    }
    return nameSearchList;
  }

  Future getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) => deviceToken = token);
    return deviceToken;
  }
  Future getPlayerId() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    deviceToken = status.subscriptionStatus.userId;
    return deviceToken;
  }
}
