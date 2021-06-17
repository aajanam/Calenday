import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jadwalku/model/discussion.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/services/api_path.dart';
import 'package:jadwalku/services/auth.dart';




class FireStore{
  FirebaseFirestore _db = FirebaseFirestore.instance;


  Stream<List<Events>> getEvents() {
    return _db
        .collection(APIPath.events())
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Events.fromJson(doc.data()))
        .toList());
  }

  Stream<List<Events>> getCompletedEvents() {
    return _db
        .collection(APIPath.events())
        .orderBy('created', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Events.fromJson(doc.data()))
        .toList());
  }

  Future<void> setEvent(Events event, String eventId){
    var options = SetOptions(merge:true);
    return _db
        .collection(APIPath.events())
        .doc(event.eventId)
        .set(event.toMap(), options);
  }

  Future<void> removeEvent(String eventId){
    return _db
        .collection(APIPath.events())
        .doc(eventId)
        .delete();
  }

  Stream<List<RegUser>> getUser() {
    return  _db
        .collection(APIPath.users())
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RegUser.fromJson(doc.data()))
        .toList());
  }

  Future<List<RegUser>> userFuture() async {

    var querySnap = await _db
        .collection(APIPath.users())
        .get();

    return querySnap.docs
        .map((snap) => RegUser.fromJson(snap.data()))
        .toList();
  }

  Stream<List<RegUser>> singleUser (uid) {
    var uid = Auth().currentUser.uid;
    return  _db
        .collection(APIPath.users())
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RegUser.fromJson(doc.data()))
        .toList());
  }
  Stream<List<Events>> singleEvents(eventId) {
    return  _db
        .collection(APIPath.events())
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Events.fromJson(doc.data()))
        .toList());
  }

  Future<void> setUser(RegUser user, String uid){
    var options = SetOptions(merge:true);
    return _db
        .collection(APIPath.users())
        .doc(user.uid)
        .set(user.toMap(), options);
  }

  Stream<QuerySnapshot> getQuery (query)  {
    return
      FirebaseFirestore.instance.collection('users')
          .where('nameSearch', arrayContains: query)
          .snapshots();
  }

  Stream<List<Discussion>> getDiscussion() {
    return _db
        .collection(APIPath.messages())
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Discussion.fromJson(doc.data()))
        .toList());
  }

  Future<void> postMessage(Discussion discussion, String messageId){
    var options = SetOptions(merge:true);
    return _db
        .collection(APIPath.messages())
        .doc(discussion.messageId)
        .set(discussion.toMap(), options);
  }
  Future<void> removeMessage(String messageId){
    return _db
        .collection(APIPath.messages())
        .doc(messageId)
        .delete();
  }
}