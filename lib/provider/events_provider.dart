import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/services/firestore_service.dart';

import 'package:uuid/uuid.dart';

class EventProvider with ChangeNotifier {
  final firestoreService = FireStore();

  String _eventId;
  String _creatorId;
  DateTime _date;
  String _place;
  String _diagnose;
  String _procedure;
  String _description;
  String _finalNotes;
  int _startHour;
  int _endHour;
  bool _isDone;
  List _bookTime;
  List _participants;
  List _imageUrl;
  Timestamp _created;
  var uuid = Uuid();


  String get eventId => _eventId;
  String get creatorId => _creatorId;
  DateTime get date => _date;
  String get place => _place;
  String get diagnose => _diagnose;
  String get procedure => _procedure;
  String get description => _description;
  String get finalNotes => _finalNotes;
  int get startHour => _startHour;
  int get endHour => _endHour;
  bool get isDone => _isDone;
  List get bookTime => _bookTime;
  List  get participants => _participants;
  List get imageUrl => _imageUrl;
  Timestamp get created => _created;
  Stream<List<Events>> get events => firestoreService.getEvents();
  Stream<List<Events>> get completedEvents => firestoreService.getCompletedEvents();
  Stream  get singleEvent => firestoreService.singleEvents(eventId);



  set changeDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  set changePlace(String place) {
    _place = place;
    notifyListeners();
  }

  set changeEventId(String eventId) {
    _eventId = eventId;
    notifyListeners();
  }

  set changeCreatorId(String creatorId) {
    _creatorId = creatorId;
    notifyListeners();
  }

  set changeDiagnose(String diagnose) {
    _diagnose = diagnose;
    notifyListeners();
  }

  set changeProcedure(String procedure) {
    _procedure = procedure;
    notifyListeners();
  }

  set changeDescription(String description) {
    _description = description;
    notifyListeners();
  }

  set changeFinalNotes(String finalNotes) {
    _finalNotes = finalNotes;
    notifyListeners();
  }

  set changeStartHour(int startHour) {
    _startHour = startHour;
    notifyListeners();
  }

  set changeEndHour(int endHour) {
    _endHour = endHour;
    notifyListeners();
  }

  set changeIsDone(bool isDone) {
    _isDone = isDone;
    notifyListeners();
  }

  set changeBookTime(List bookTime) {
    _bookTime = bookTime;
    notifyListeners();
  }

  set changeParticipants(List participants) {
    _participants = participants;
    notifyListeners();
  }

  set changeImageUrl(List imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

 set changeCreated(Timestamp created) {
    _created = created;
    notifyListeners();
  }

  loadAll(Events event) async {
    if (event != null) {
      _date = DateTime.parse(event.date);
      _place = event.place;
      _diagnose = event.diagnose;
      _description = event.description;
      _finalNotes = event.finalNotes;
      _procedure = event.procedure;
      _endHour = event.endHour;
      _eventId = event.eventId;
      _creatorId = event.creatorId;
      _startHour = event.startHour;
      _isDone = event.isDone;
      _bookTime = event.bookTime;
      _participants = event.participants;
      _imageUrl = event.imageUrl;
      _created = event.created;
    } else {
      _date = DateTime.now();
      _place = null;
      _diagnose = null;
      _description = null;
      _finalNotes = null;
      _procedure = null;
      _endHour = null;
      _eventId = null;
      _creatorId = Auth().currentUser.uid;
      _startHour = null;
      _isDone = false;
      _bookTime = null;
      _participants = null;
      _imageUrl = null;
      _created = Timestamp.now();
    }
  }

  saveEvent() {
    if (_eventId == null) {
      //Add
      var newEvent = Events(
          date: _date.toIso8601String(),
          place: _place,
          diagnose: _diagnose,
          description: _description,
          finalNotes: _finalNotes,
          procedure: _procedure,
          endHour: _endHour,
          startHour: _startHour,
          isDone: false,
          bookTime: _bookTime,
          participants: _participants,
          imageUrl: _imageUrl,
          creatorId: Auth().currentUser.uid,
          created: Timestamp.now(),
          eventId: uuid.v1());
      firestoreService.setEvent(newEvent, eventId);
    } else {
      var updateEvent = Events(
          date: _date.toIso8601String(),
          place: _place,
          diagnose: _diagnose,
          description: _description,
          finalNotes: _finalNotes,
          procedure: _procedure,
          endHour: _endHour,
          startHour: _startHour,
          isDone: _isDone,
          bookTime: _bookTime,
          participants: _participants,
          imageUrl: _imageUrl,
          creatorId: _creatorId,
          created: _created,
          eventId: _eventId);
      firestoreService.setEvent(updateEvent, eventId);
    }
  }
  removeEvent(String eventId) {
    firestoreService.removeEvent(eventId);
  }
}
