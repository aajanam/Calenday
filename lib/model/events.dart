
import 'package:cloud_firestore/cloud_firestore.dart';

class Events{
  final String eventId;
  final String creatorId;
  final String date;
  final String place;
  final String diagnose;
  final String procedure;
  final String description;
  final String finalNotes;
  final int startHour;
  final int endHour;
  final bool isDone;
  final List bookTime;
  final List participants;
  final List imageUrl;
  final Timestamp created;

  Events({
    this.date,
    this.place,
    this.diagnose,
    this.endHour,
    this.eventId,
    this.creatorId,
    this.description,
    this.finalNotes,
    this.procedure,
    this.isDone,
    this.startHour,
    this.bookTime,
    this.participants,
    this.imageUrl,
    this.created,
});


  factory Events.fromJson(Map<String, dynamic> json){
    return Events(
      date: json['date'],
      place: json['place'],
      diagnose: json['diagnose'],
      endHour: json['endHour'],
      eventId: json['eventId'],
      creatorId: json['creatorId'],
      description: json['description'],
      finalNotes: json['finalNotes'],
      isDone: json['isDone'],
      procedure: json['procedure'],
      startHour: json['startHour'],
      bookTime: json['bookTime'],
      participants: json['participants'],
      imageUrl: json['imageUrl'],
      created: json['created'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'date': date,
      'place': place,
      'diagnose': diagnose,
      'endHour': endHour,
      'eventId': eventId,
      'creatorId': creatorId,
      'description': description,
      'finalNotes': finalNotes,
      'isDone': isDone,
      'procedure': procedure,
      'startHour': startHour,
      'bookTime': bookTime,
      'participants': participants,
      'imageUrl': imageUrl,
      'created': created,
    };
  }
}