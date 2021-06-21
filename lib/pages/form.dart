import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:jadwalku/helper/custom_image.dart';
import 'package:jadwalku/helper/notification_helper.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/pages/discuss_page.dart';
import 'package:jadwalku/pages/participants.dart';
import 'package:jadwalku/pages/photo_galery.dart';
import 'package:jadwalku/provider/discussion_provider.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:jadwalku/widget/show_alert_dialogue.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;
import 'package:rich_text_controller/rich_text_controller.dart';
//import 'package:rich_text_controller/rich_text_controller.dart';


class EventForm extends StatefulWidget {
  final Events event;
  final DateTime date;
  final int hour;
  final String eventId;
  final int count;


  EventForm({this.event, this.date, this.hour, this.eventId, this.count});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {

  int startHour = 0;
  int endHour = 0;
  final _formKey = GlobalKey<FormState>();
  List participants;
  String name = '';
  int option;
  bool isDone;




  List<Asset> images = <Asset>[];
  String _error = 'No Error Detected';
  List deletedImages = [];
  bool _isUploading = false;
  bool notify;
  DateTime now = DateTime.now();

  List<File> _files = [];
  List playIds = [];

  TextEditingController dateController = TextEditingController();
  TextEditingController _placeController = TextEditingController();
  TextEditingController _procedureController = TextEditingController();
  RichTextController _noteController;
  Map<RegExp, TextStyle> patternUser = {
    RegExp(r"\B@[a-zA-Z0-9]+\b"):
    TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)
  };


  List<int> bookTimeOTAll = [];
  List<int> bookTimeOT = [];
  List<int> availableTimeAll = [];
  List<int> endTime = [];
  DateTime selDate;




  @override
  void initState() {
    getInitList();

    final event = Provider.of<EventProvider>(context, listen: false);
    Provider.of<NotificationService>(context, listen: false).initialize();

    if (widget.event != null) {
      isDone = widget.event.isDone;

      selDate = DateTime(DateTime.parse(widget.event.date).year,DateTime.parse( widget.event.date).month, DateTime.parse(widget.event.date).day);
      dateController.text = formatDate(DateTime.parse(widget.event.date),['dd',' ','M',' ', 'yyyy']);
      _placeController.text = widget.event.place;
      _procedureController.text = widget.event.procedure;
      participants = widget.event.participants;
      notify = participants.where((element) => element['id']== Auth().currentUser.uid).first['notifyStat'];
      startHour = widget.event.startHour;
      endHour = widget.event.endHour;

      //Edit
      event.loadAll(widget.event);
    }

    else {
      if (widget.hour != null) {
        startHour = widget.hour;
        getEndTime(widget.hour.toString());
        endHour = endTime[0];
      }
      isDone = false;
      selDate = DateTime(widget.date.year, widget.date.month, widget.date.day);
      dateController.text = formatDate(selDate,['dd',' ','M',' ', 'yyyy']);
      notify = false;

      participants = [
        {'id': Auth().currentUser.uid,
        'notifyStat': true,
        'hour': option}
      ];

      //Add
      event.loadAll(null);
    }
    _noteController = RichTextController(
      text: event.finalNotes,
      patternMap: patternUser,

    );
    super.initState();
  }

  @override
  void dispose() {
   dateController.dispose();
   _placeController.dispose();
   _procedureController.dispose();
   _noteController.dispose();
    super.dispose();
  }

  void getInitList() {
    availableTimeAll = [for(var i=0; i<24; i+=1) i];
  }
  
  Future sendMessage(playerId, messageTitle, messageBody, collapseId, time ) async {
    await OneSignal.shared.postNotification(OSCreateNotification(
        playerIds: [playerId],
        content: messageBody,
        heading: messageTitle,
        sendAfter: DateTime.now().add(Duration(seconds: 30)).toUtc(),
        collapseId: collapseId,
        additionalData: {'time': time},
        androidSmallIcon: 'ic_launcher',
        androidLargeIcon: 'ic_launcher_round'
    ));
  }

  @override
  Widget build(BuildContext context) {
    final event = Provider.of<EventProvider>(context);
    final person = Provider.of<UserProvider>(context);
    DateTime today = DateTime(now.year, now.month, now.day);
    bool isError = false;
    bool isButtonPressed = false;

    return Stack(
      children: [
        StreamBuilder<List<RegUser>>(
          stream: person.users,
          builder: (context, snap) {
            if( snap.hasData)  {

              var owner =  snap.data.firstWhereOrNull((element) => element.uid == event.creatorId);
              return Scaffold(
                bottomNavigationBar: Consumer<NotificationService>(
                  builder: (context, model, _) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 35),
                      child:  Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if(widget.event != null && widget.event.creatorId == Auth().currentUser.uid)
                                  Row(
                                    children: [if(widget.event != null && widget.event.creatorId == Auth().currentUser.uid)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            primary: Colors.pink,
                                            textStyle: TextStyle(fontWeight: FontWeight.w600)),
                                        child: Text('Delete'),
                                        onPressed: () {
                                          _confirmDelete(context, model, snap, owner);
                                        }),
                                    ],
                                  ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        primary: Colors.teal,
                                        textStyle: TextStyle(fontWeight: FontWeight.w600)),
                                    child: Text('Save'),
                                    onPressed: (endHour > startHour)
                                        ? () async {
                                      isButtonPressed = true;
                                      if (_formKey.currentState.validate()) {
                                        if(selDate.add(Duration(hours: startHour)).isBefore(DateTime.now()) && isDone == false){
                                          showAlertDialog(context, title: "Unable to save unfinished event", content:
                                          'The time has passed. '
                                              'Please change the date or start hour before saving" ', defaultActionText: 'OK');
                                          return;
                                        }
                                        setState(() {
                                          _isUploading = true;
                                        });
                                        savingBookTime(event);
                                        _formKey.currentState.save();
                                        event.changeStartHour = startHour;
                                        event.changeEndHour = endHour;
                                        event.changeParticipants = participants.toList();
                                        if(deletedImages.length > 0){
                                          for(var i in deletedImages){
                                            deleteImage(i);
                                          }
                                        }
                                        if (widget.event != null && images.length > 0) {
                                          if(widget.event.imageUrl == null){
                                            event.changeImageUrl = await saveImage();
                                          } else
                                          {
                                            event.imageUrl.addAll(await saveImage());
                                            event.changeImageUrl = widget.event.imageUrl;
                                          }
                                        } else if(widget.event == null && images.length > 0){
                                          event.changeImageUrl = await saveImage();
                                        }


                                        if(widget.event == null && selDate.add(Duration(hours: startHour)).isAfter(DateTime.now().add(Duration(hours: 2))) &&
                                            selDate.add(Duration(hours: startHour)).isBefore(DateTime.now().add(Duration(hours: 36)))){
                                          setState(() {
                                            option = 2;
                                            event.participants.where((element) => element['id']== Auth().currentUser.uid).first['hour'] = 2;
                                          });
                                          await event.saveEvent();
                                          sendNotif(model, event, 'Today');
                                          sendMessageToParticipants(event, snap, owner, 'invites you');
                                          await showAlertDialog(context, title: 'Reminder Set Up ',
                                              content: 'Reminder has been set automatically to 2 hours before. Tap on event to change reminder.',
                                              defaultActionText: 'OK');



                                        } else if(widget.event == null && selDate.add(Duration(hours: startHour)).isAfter(DateTime.now().add(Duration(hours: 36)))){
                                          setState(() {
                                            option = 24;
                                            event.participants.where((element) => element['id']== Auth().currentUser.uid).first['hour'] = 24;
                                          });
                                          await event.saveEvent();
                                          sendNotif(model, event, 'Tomorrow');
                                          sendMessageToParticipants(event, snap, owner, 'invites you');
                                          await showAlertDialog(context, title: 'Reminder Set Up ',
                                              content: 'Reminder has been set automatically to 1 day before. Tap on event to change reminder.',
                                              defaultActionText: 'OK');

                                        }
                                        else if (widget.event == null && selDate.add(Duration(hours: startHour)).isBefore(DateTime.now().add(Duration(hours: 2)))) {
                                          await event.saveEvent();
                                          sendMessageToParticipants(event, snap, owner, 'invites you');

                                        }
                                        else if (widget.event != null && (DateTime.parse(widget.event.date) != selDate || startHour != widget.event.startHour) && widget.event.participants.length > 1 ){
                                          await event.saveEvent();
                                          sendMessageToParticipants(event, snap, owner, 'rescheduled an event');
                                        }
                                        else{
                                          await event.saveEvent();
                                        }

                                        if (selDate != null && startHour != null) {
                                          Navigator.pop(context,{'date': selDate, 'time': bookTimeOT});
                                        }
                                        else{
                                          Navigator.pop(context);

                                        }
                                      }

                                    } : null),
                                SizedBox(width: 32,) /*: Container()*/,

                              ],
                            ),
                          widget.event != null ? Text(isDone == false ? 'Created on: ${formatDate(DateTime.
                              parse(event.created.toDate()
                              .toIso8601String()),[d,' ',M,' ',yyyy,' - ',HH,':',nn])}' :
                          'Done on: ${formatDate(DateTime.
                          parse(event.created.toDate()
                              .toIso8601String()),[d,' ',M,' ',yyyy,' - ',HH,':',nn])}', style: TextStyle(fontSize: 9),): Container(),
                        ],
                      ),
                      );
                  },
                ),
                appBar: AppBar(
                  brightness: Brightness.dark,
                  backgroundColor: Colors.cyan.shade600,
                  titleSpacing: 0,
                  title: widget.event != null && event.creatorId == Auth().currentUser.uid
                      ? Text('Edit Event', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),) : widget.event != null && event.creatorId != Auth().currentUser.uid
                      ? Row(
                    children: [
                      CircleAvatar(backgroundImage: owner?.photoUrl !=null ? NetworkImage(owner?.photoUrl) : AssetImage('person.png'), radius: 18,),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(owner.displayName.length  > 15 ? owner?.displayName?.substring(0,owner?.displayName?.lastIndexOf(' '))
                                : owner?.displayName, style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
                            Transform.translate(
                                offset: Offset(2,-3),
                                child: Text(owner?.specialty != null ? owner?.specialty : '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),)),
                          ],
                        ),
                      ),
                    ],
                  ) :
                  Text('New Event', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),),
                  elevation: 0,
                  actions: [
                    if(widget.event != null && participants.length > 1) IconButton(icon: Icon(Icons.chat),  iconSize: 28,
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> DiscussPage(event:widget.event)));
                        }),
                    SizedBox(width: 8,),

                   Stack(
                        children: [
                          participants.length > 1 ? Positioned(
                              right: 0,
                              top: 3,
                              child: Container(
                                  constraints: BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,),
                                  padding: EdgeInsets.all(4),
                                  decoration: new BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text('${participants.length-1}', style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11, fontWeight:FontWeight.w600
                                  ), textAlign: TextAlign.center,))
                          ): Container(),
                          Center(
                            child:  Container(
                                width:  50,
                                child: IconButton(icon: Icon(Icons.group_add,),
                                                  color: Colors.white,iconSize: 28,
                                onPressed:  widget != null && _placeController.text.length > 2 && _procedureController.text.length > 2  ?(){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                  Participants(regUser: owner, event: widget.event, participants: participants, procedure: _procedureController.text, place: _placeController.text, date:dateController.text, isDone: isDone,)));
                                }: null,),)
                          ),
                        ]
                    ),
                    SizedBox(width: 8,),
                    widget.event != null && selDate.add(Duration(hours: startHour)).isAfter(DateTime.now().add(Duration(hours: 2)))
                        ? Consumer<NotificationService>(
                      builder: (context, model, _) => PopupMenuButton(
                        tooltip: 'Remind me',
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.zero,
                          icon:  Icon(notify == false ? Icons.notifications_off_outlined : Icons.notifications_on, color: notify == false ?Colors.white60: Colors.white), iconSize: 28,
                          itemBuilder: (content) => [
                            PopupMenuItem(
                              value: 0,
                              child: Text('Cancel Reminder', style: TextStyle(color: Colors.black54, fontSize: 15),),
                            ),
                            (selDate.add(Duration(hours: event.startHour)).isAfter(DateTime.now().add(Duration(hours: 24)))) ? PopupMenuItem(
                              value: 24,
                              child: Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                                  color: event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 24 ? Colors.cyan.shade600: Colors.transparent,
                                ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Text('1 day before',
                                    style: TextStyle(color:event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 24 ? Colors.white : Colors.black54,  fontSize: 15 ),
                                    textAlign:  event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 24 ? TextAlign.center : TextAlign.start,)),
                            ) : null,
                            (selDate.add(Duration(hours: event.startHour)).isAfter(DateTime.now().add(Duration(hours: 6)))) ?PopupMenuItem(
                              value: 6,
                              child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                                    color: event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 6 ? Colors.cyan.shade600 : Colors.transparent,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Text('6 hours before',
                                    style: TextStyle(color:event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 6 ? Colors.white : Colors.black54 , fontSize: 15),
                                    textAlign:  event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 6 ? TextAlign.center : TextAlign.start,
                                  )),
                            ) : null,
                            PopupMenuItem(
                              value: 2,
                              child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
                                    color: event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 2 ? Colors.cyan.shade600 : Colors.transparent,
                                  ),
                                width: MediaQuery.of(context).size.width,
                                  child: Text('2 hours before',
                                    style: TextStyle(color:event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 2 ? Colors.white : Colors.black54, fontSize: 15 ),
                                    textAlign:  event.participants.where((element) => element['id'] == Auth().currentUser.uid).firstOrNull['hour'] == 2 ? TextAlign.center : TextAlign.start,)),
                            ),
                          ],
                        onSelected: (int menu){

                          if (menu == 24){
                            setState(() {
                              option = 24;
                              notify = true;
                              widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['notifyStat'] = notify;
                              widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['hour'] = option;
                            });
                            event.saveEvent();
                            sendNotif(model, event, 'Tomorrow');
                          }
                          else if(menu == 6){
                            setState(() {
                              option = 6;
                              notify = true;
                              widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['notifyStat'] = notify;
                              widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['hour'] = option;
                            });
                            event.saveEvent();
                            sendNotif(model, event, 'Today');
                          }
                          else if(menu == 2){
                            setState(() {
                              option = 2;
                              notify = true;
                              widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['notifyStat'] = notify;
                              widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['hour'] = option;
                            });
                            event.saveEvent();
                            sendNotif(model, event, 'Today');
                          }
                          else if(menu == 0){
                            setState(() {
                              option = null;
                              notify = false;
                              widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['notifyStat'] = notify;
                              widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['hour'] = option;
                            });
                            event.saveEvent();
                            model.cancelNotification(event.eventId.hashCode);
                          }

                      }
                      )
                    ) : Container(),
                    SizedBox(width: 25,),
                  ],
                ),
                body: StreamBuilder<List<Events>>(
                    stream: event.events,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        Indicator();
                      }

                      getTimeList(snapshot, bookTimeOTAll, availableTimeAll, selDate, today);

                      return Padding(
                        padding: const EdgeInsets.only(top: 15, right:5.0),
                        child: Scrollbar(
                          thickness: 5,
                          isAlwaysShown: true,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 30),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Consumer<NotificationService>(
                                              builder: (context, model, _) =>TextFormField(
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                                enabled: widget.event != null && event.creatorId == Auth().currentUser.uid || widget.event == null ? true : false,
                                              onTap: widget.event == null || (widget.event != null && isDone == true )? () {} :
                                                  () async {
                                                    widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).single['notifyStat'] = false;
                                                    getInitList();
                                                DateTime picked = await showDatePicker(
                                                  builder: (BuildContext context, Widget child) {
                                                    return Theme(
                                                      data: ThemeData.dark().copyWith(
                                                        colorScheme: ColorScheme.fromSwatch(
                                                          primarySwatch: Colors.teal,
                                                         primaryColorDark: Colors.cyan,
                                                          //accentColor: Colors.teal,

                                                        ),
                                                        dialogBackgroundColor:Colors.white,

                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                                    context: context,
                                                    initialDate: DateTime.parse(widget.event.date),
                                                    firstDate: selDate.isAfter(today) ? today : selDate,
                                                    lastDate: DateTime(2050));
                                                if (picked != null) {
                                                  if (!picked.isBefore(today)) {
                                                    setState(() {
                                                      selDate = picked;
                                                      dateController.text = formatDate(
                                                          picked, ['dd', ' ', 'M', ' ', 'yyyy']);
                                                      option = null;
                                                      notify = false;
                                                      widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['notifyStat'] = notify;
                                                      widget.event.participants.where((element) => element['id']== Auth().currentUser.uid).first['hour'] = option;

                                                    });
                                                    model.cancelNotification(event.eventId.hashCode);

                                                  } else {
                                                    showAlertDialog(context, title: 'Invalid date',
                                                        content: 'Please choose today\'s date or after',
                                                        defaultActionText: 'OK');}
                                                }
                                              },
                                              decoration: InputDecoration(
                                                labelStyle: TextStyle(color: Colors.black54, fontSize: 14,),
                                                suffixIcon:  Padding(
                                                  padding: const EdgeInsets.only(top: 12.0),
                                                  child: Icon(Icons.arrow_drop_down, color: widget.event != null  && widget.event.creatorId == Auth().currentUser.uid && isDone == false ? Colors.black : Colors.transparent,),),
                                                labelText: 'Date',
                                                icon: Icon(Icons.date_range_outlined,
                                                    color: widget.event != null ? Colors
                                                        .cyan.shade700 : Colors.black38),
                                                border: InputBorder.none,
                                              ),
                                              expands: false,
                                              readOnly: true,
                                              controller: dateController,
                                              onChanged: (value) {
                                                getTimeList(snapshot, bookTimeOTAll,
                                                    availableTimeAll,
                                                    DateTime.parse(value), today);

                                              },
                                          )),
                                        ),
                                        if (widget.event != null) Padding(
                                          padding: EdgeInsets.only(top: 20.0),
                                          child: Row(
                                            children: [
                                              Text('Is Done ?', style: TextStyle(color:Colors.black54),),
                                              AbsorbPointer(
                                                absorbing: isDone == true ? true : false,
                                                child: Switch(
                                                    activeColor: Colors.pinkAccent,
                                                    value: event.isDone,
                                                    onChanged: (value){
                                                      confirmDone(context, event, value);
                                                    }),
                                              )
                                            ],
                                          ),
                                        ) else SizedBox(height: 20,),
                                        //SizedBox(width: 12,)
                                      ],
                                    ),
                                    SizedBox(width: 17,),
                                    SizedBox(height: 10,), // Space between date row & time row
                                    buildTimeSelectorRow(event),
                                    TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      keyboardType: TextInputType.multiline,
                                      //maxLines: null,
                                      enabled: widget.event != null && event.creatorId == Auth().currentUser.uid && isDone == false || widget.event == null ? true : false,
                                      controller: _placeController,
                                      decoration:
                                      InputDecoration(
                                        hintText: 'Write or select a place',
                                        hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                                        alignLabelWithHint: true,
                                          suffixIcon: StreamBuilder<List<RegUser>>(
                                              stream: person.singleUser,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data.single.workPlace1 != null &&
                                                    snapshot.data.single.workPlace2 != null &&
                                                    snapshot.data.single.workPlace3 != null){
                                                  return PopupMenuButton(
                                                    color: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: widget.event != null && widget.event.creatorId == Auth().currentUser.uid && isDone == false || widget.event == null ? Colors.teal.shade700 : Colors.transparent,
                                                      size: 26,
                                                    ),
                                                    itemBuilder: (content) => [
                                                      PopupMenuItem(
                                                        value: 1,
                                                        child: Text(snapshot.data.single.workPlace1 != null ? snapshot.data.single.workPlace1 : '', style: TextStyle(fontSize: 15),),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 2,
                                                        child: Text(snapshot.data.single.workPlace2 != null ? snapshot.data.single.workPlace2 : '', style: TextStyle(fontSize: 15)),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 3,
                                                        child: Text(snapshot.data.single.workPlace3 != null ? snapshot.data.single.workPlace3 : '', style: TextStyle(fontSize: 15)),
                                                      ),
                                                    ],
                                                    onSelected: (int menu){
                                                      if(menu == 1){
                                                        setState(() {
                                                          _placeController.text = snapshot.data.single.workPlace1;
                                                        });
                                                      }
                                                      else if(menu == 2){
                                                        setState(() {
                                                          _placeController.text = snapshot.data.single.workPlace2;
                                                        });
                                                      }
                                                      else if(menu == 3){
                                                        setState(() {
                                                          _placeController.text = snapshot.data.single.workPlace3;
                                                        });
                                                      }
                                                    },);
                                                }
                                                return Container();
                                              }
                                          ),
                                          labelStyle: TextStyle(color: Colors.black54,fontSize: 14),
                                          icon: Icon(Icons.place_outlined,
                                              color: Colors.cyan.shade700),
                                          labelText: 'Place'),
                                      validator: (val) {
                                        if (!isButtonPressed) {
                                          return null;
                                        }
                                        isError = true;
                                        if(val == null || val.isEmpty) {
                                          return "Place is required";
                                        }
                                        isError = false;
                                        return null;
                                      },
                                      onChanged: (val){
                                        isButtonPressed = false;
                                        if(isError){
                                          _formKey.currentState.validate();
                                        }
                                        setState(() {
                                          event.changePlace = val;
                                        });
                                      },
                                      onSaved: (val) {

                                        return event.changePlace = val;

                                      },
                                      textInputAction: TextInputAction.next,
                                    ),
                                    TextFormField(
                                      maxLines: null,
                                      textCapitalization: TextCapitalization.words,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      textAlignVertical: TextAlignVertical.bottom,
                                      controller: _procedureController,
                                      enabled: widget.event != null && event.creatorId == Auth().currentUser.uid || widget.event == null ? true : false,
                                      decoration:
                                      InputDecoration(
                                        alignLabelWithHint: true,
                                          labelStyle: TextStyle(color: Colors.black54, fontSize: 14),
                                          icon: Icon(Icons.medical_services_outlined,
                                              color: Colors.cyan.shade700),
                                          labelText: 'Activity / Procedure'),
                                     // initialValue: event.procedure,
                                      validator: (val) {
                                        if (!isButtonPressed) {
                                          return null;
                                        }
                                        isError = true;
                                        if(val == null || val.isEmpty) {
                                          return "Activity / procedure is required";
                                        }
                                        isError = false;
                                        return null;
                                      },

                                      onChanged: (val){
                                        isButtonPressed = false;
                                        if(isError){
                                          _formKey.currentState.validate();
                                        }
                                        setState(() {
                                          event.changeProcedure = val;
                                        });
                                      },
                                      textInputAction: TextInputAction.next,
                                      onSaved: (val) =>
                                      event.changeProcedure = val,

                                    ),
                                    TextFormField(
                                      maxLines: null,
                                      textCapitalization: TextCapitalization.words,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      enabled: widget.event != null && event.creatorId == Auth().currentUser.uid || widget.event == null ? true : false,
                                      decoration:
                                      InputDecoration(
                                          alignLabelWithHint: true,
                                          labelStyle: TextStyle(color: Colors.black54,fontSize: 14),
                                          icon: Icon(Icons.analytics_outlined,
                                        color: Colors.cyan.shade700,),
                                          labelText: 'Subject / Title / Diagnose / etc'),
                                      initialValue: event.diagnose,
                                      validator: (val) {
                                        if (!isButtonPressed) {
                                          return null;
                                        }
                                        isError = true;
                                        if(val == null || val.isEmpty) {
                                          return "Subject or title or diagnose is required";
                                        }
                                        isError = false;
                                        return null;
                                      },
                                      onChanged: (val){
                                        isButtonPressed = false;
                                        if(isError){
                                          _formKey.currentState.validate();
                                        }
                                        setState(() {
                                          event.changeDiagnose = val;
                                        });
                                      },
                                      textInputAction: TextInputAction.next,
                                      onSaved: (val) =>
                                      event.changeDiagnose = val,
                                    ),
                                    TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      keyboardType: TextInputType.multiline,
                                      enabled: widget.event != null && event.creatorId == Auth().currentUser.uid || widget.event == null ? true : false,
                                      decoration:
                                      InputDecoration(
                                          alignLabelWithHint: true,
                                          labelStyle: TextStyle(color: Colors.black54,fontSize: 14),
                                          icon: Icon(Icons.notes_outlined,
                                          color: Colors.cyan.shade700),
                                          labelText: 'Description'),
                                      maxLines: null,
                                      initialValue: event.description,
                                      onChanged: (val) =>
                                      event.changeDescription = val,
                                      onSaved: (val) =>
                                      event.changeDescription = val,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    widget.event != null && isDone == true ?
                                    TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      keyboardType: TextInputType.multiline,
                                      controller: _noteController,
                                      style: TextStyle(color: Colors.black, fontSize: 15),
                                      decoration:
                                      InputDecoration(
                                          alignLabelWithHint: true,
                                          labelStyle: TextStyle(color: Colors.black54,fontSize: 14),
                                          icon: Icon(Icons.list_alt_outlined,
                                          color: Colors.cyan.shade700),
                                          labelText: 'Final Notes'),
                                      maxLines: null,
                                      //initialValue: _noteController.text,
                                      onChanged: (val) {
                                        var editor = Auth().currentUser.displayName.substring(0, Auth().currentUser.displayName.lastIndexOf(' ')).toLowerCase().trim();
                                        if(_noteController.text.contains('@$editor'))
                                          {val = '$val';}
                                        else {
                                                val = '@$editor;  $val';
                                              }
                                              return event.changeFinalNotes = val;
                                      }, //experimental
                                      textInputAction: TextInputAction.next,
                                    ): Container(),
                                    SizedBox(height: 20,),
                                    if(widget.event == null && images.length < 6 || widget.event != null && widget.event.imageUrl !=null && images.length  < 6 - widget.event.imageUrl.length || widget.event != null && widget.event.imageUrl == null)Padding(
                                      padding:  EdgeInsets.only(left:2),
                                      child: widget.event != null && event.creatorId == Auth().currentUser.uid || widget.event == null
                                          ? TextButton.icon(
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, ),
                                        label: Text('Add Picture', style: TextStyle(color: Colors.cyan.shade700),),
                                        icon: Icon(Icons.camera_alt_outlined, size: 26, color: Colors.cyan.shade700,),
                                        onPressed: loadAssets,
                                      ) : Container(),
                                    ),
                                    images.length > 0 || widget.event !=null && widget.event.imageUrl !=null && widget.event.imageUrl.length > 0 ? Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: Text(widget.event == null || widget.event != null && widget.event.creatorId == Auth().currentUser.uid ? 'Tap to view, Double Tap to remove it' : 'Tap to view', style: TextStyle(
                                          color: Colors.black54, fontSize: 12),),
                                    ) : Container(),
                                    SizedBox(height: 10,),
                                    images.length > 0 ?SizedBox(height: images.length > 3 ? 225 : 112,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 2.0),
                                        child: buildNewGridView(),
                                      ),
                                    ) : Container(),
                                    SizedBox(height: 5,),
                                    widget.event !=null && widget.event.imageUrl !=null && widget.event.imageUrl.length > 0 ? Padding(
                                      padding: const EdgeInsets.only(left:2.0, top: 0),
                                      child: SizedBox(height: event.imageUrl.length > 3 ? 225 : 122,
                                        child: buildFirebaseGridView(event.imageUrl),
                                      ),
                                    ): Container(),
                                    SizedBox(height: 30,),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                ),
              );
            }
            return Indicator();
          }
        ),
        _isUploading  ? Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.black26,
          child: Indicator(),
        ) : Container(),
      ]
    );
  }

  Future<void> confirmDone(context, EventProvider event, bool value) async {
    final didRequestDone = await showAlertDialog(
      context,
      title: 'Confirm Before Done',
      content: "After you switch to 'isDone', you can't switch it back "
          "and some data are unable to edit. You can still edit final notes and add/remove picture"
          " Are you sure?",
      cancelActionText: 'No',
      defaultActionText: 'Yes',
    );
    if (didRequestDone == true) {
      setState(() {
        event.changeIsDone = value;
        isDone = value;
        if(value == true){
          event.changeCreated = Timestamp.now();
        }
      });
      _formKey.currentState.save();
      event.saveEvent();
    }
  }

  void sendMessageToParticipants(EventProvider event, AsyncSnapshot<List<RegUser>> snapshot, RegUser owner, String action) {
     for (var i in event.participants.where((element) => element['id'] != Auth().currentUser.uid)){
      playIds.add(snapshot.data.where((element) => element.uid == i['id']).first.deviceToken);
    }
     for (var playId in playIds){
    if (playId != null) {
      sendMessage(playId, '${owner.displayName} $action', '${dateController.text}: ${_procedureController.text} at ${_placeController.text}', selDate.toString(), '$startHour');
        }
     }
  }

  void sendNotif(NotificationService model, EventProvider event, String when) async {
    if (event.startHour >= 10) {
      await model.zonedScheduleNotification(
          event.eventId.hashCode,
          '$when - ${formatDate(DateTime.parse(selDate.toString()), ['dd', ' ', 'M', ' ', 'yyyy', ' at ${event.startHour}:00' ])}' ,
          '${event.procedure} - ${event.diagnose}',
          selDate.toString(),
          startHour,
          option);
    }else
    {
      await model.zonedScheduleNotification(
          event.eventId.hashCode,
          '$when - ${formatDate(DateTime.parse(selDate.toString()), ['dd', ' ', 'M', ' ', 'yyyy', ' at 0${event.startHour}:00'])}',
          '${event.procedure} - ${event.diagnose}',
          selDate.toString(),
          startHour,
          option);
    }
  }

  void savingBookTime(EventProvider event) {
     event.changeDate = selDate;
    for (var i = 0;
    i <
        endHour -
            startHour;
    i++) {
      bookTimeOT.add(
          startHour + i);
    }
    event.changeBookTime =
        bookTimeOT;
  }


  void getTimeList(AsyncSnapshot<List<Events>> snap, List<int> booked, List<int> availableTime, DateTime date, DateTime today) {

    var timeNow = TimeOfDay.fromDateTime(DateTime.now()).hour;
    if (snap.hasData){
      var mySched = snap.data.where((element) => element.participants.map((e) => e['id']).contains(Auth().currentUser.uid));
      var daySched = mySched.where((element) => DateTime.parse(element.date) == date);
      if(date == today ) {
        for (var i = 0; i <= timeNow; i++){
          availableTime.remove(i);
        }
      }

      for (var item in daySched){
        booked.clear();
        booked.addAll(item.bookTime.map((e) => e));
        if(widget.event != null && widget.event.eventId == item.eventId){
          item.bookTime.forEach((element) {
            booked.remove(element);
          });
        }

        for (var time in booked){
          availableTime.remove(time);
        }

      }
      availableTime = availableTime.toSet().toList();
      availableTime.sort();

    }

   Indicator();
  }

  Future<void> _confirmDelete(BuildContext context, NotificationService model, AsyncSnapshot<List<RegUser>> snapshot, RegUser owner) async {
    final event = Provider.of<EventProvider>(context, listen: false);
    final discussion = Provider.of<DiscussionProvider>(context, listen: false);
    final didRequestDelete = await showAlertDialog(
      context,
      title: 'Delete Event',
      content: 'Are you sure want to delete event?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Delete',
    );
    if (didRequestDelete == true) {

      if(widget.event.participants.length > 1){
        sendMessageToParticipants(event, snapshot,  owner, 'canceled an event');
      }

      event.removeEvent(event.eventId);
      discussion.removeMessage(event.eventId);
      if (event.imageUrl !=null) {
        for (var i in event.imageUrl){
          var file = 'gs://jadwalku-2abb5.appspot.com/' +
              Uri.decodeFull(Path.basename(i))
                  .replaceAll(new RegExp(r'(\?alt).*'), '');
          deleteImage(file);
        }
      }

      model.cancelNotification(event.eventId.hashCode);
      Navigator.of(context).pop();
    }
  }
  Widget buildNewGridView() {
    return GridView.count(
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      shrinkWrap: true,
      crossAxisCount: 3,
      children:/* widget.event == null || widget.event.imageUrl.length == 0 ?*/
      List.generate(images.length, (index){
        Asset asset = images[index];
        return GestureDetector(
          onDoubleTap: () {
            setState(() {
              images.removeAt(index);
            });
          },
            onTap: (){

            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhotoGallery(carouselList: _files, idx: index, )));
            },
            child: AssetThumb(
            spinner: CircularProgressIndicator(),
            asset: asset,
            width: 300,
            height: 300,
          )
        );
      })
    );
  }

  Widget buildFirebaseGridView(List urls) {
    return GridView.count(
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      shrinkWrap: true,
      crossAxisCount: 3,
      children:
      List.generate(urls.length , (index) {
        //String url = urls[index];
        return GestureDetector(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhotoGallery(carouselList: urls ,idx: index, event: widget.event,)));
          },
            onDoubleTap: widget.event != null && widget.event.creatorId == Auth().currentUser.uid ? () {
              deletedImages.add('gs://jadwalku-2abb5.appspot.com/' +
                  Uri.decodeFull(Path.basename(urls[index]))
                      .replaceAll(new RegExp(r'(\?alt).*'), ''));
              setState(() {
                urls.remove(urls[index]);
              });
            } : null,
            child:cachedNetworkImage(urls[index]) );
      }),
    );
  }
  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: widget.event != null && widget.event.imageUrl != null ? 6 - widget.event.imageUrl.length : 6,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          statusBarColor: "#00BCD4" ,
          lightStatusBar: true,
          actionBarColor: "#00BCD4",
          actionBarTitle: "Pick images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
          autoCloseOnSelectionLimit: true,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    List<File> files = [];
    for (Asset asset in resultList) {
      final filePath =
      await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
      files.add(File(filePath));
    }

    if (!mounted) return;


    setState(() {
      images = resultList;
      _files = files;
      _error = error;
    });
  }
  Future saveImage() async {
    List<String> imageUrls = [];
    for (var image in images) {
      ByteData byteData = await image.getByteData(
          quality: 75); // requestOriginal is being deprecated
      List<int> imageData = byteData.buffer.asUint8List();
      //Reference ref = FirebaseStorage().ref().child("some_image_bame.jpg"); // To be aligned with the latest firebase API(4.0)
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().toString() + '.jpg');
      UploadTask uploadTask = ref.putData(imageData);

      TaskSnapshot storageSnap = await uploadTask;
      final String downloadUrl = await storageSnap.ref.getDownloadURL();
      imageUrls.add(downloadUrl.toString());
    }
    return imageUrls;
    //return await (await uploadTask.onComplete).ref.getDownloadURL();
  }
  Future<void> deleteImage(String imageFileUrl) async {
    if (imageFileUrl != null) {
      Reference photoRef = FirebaseStorage.instance.refFromURL(imageFileUrl);
      photoRef.delete();
    }
  }

  Row buildTimeSelectorRow(EventProvider event) {
    DateTime now = DateTime.now();
    //DateTime iniDate = DateTime.parse(widget.event.date);
    //DateTime initDate = DateTime(iniDate.year, iniDate.month, iniDate.day);
    DateTime today = DateTime(now.year, now.month, now.day);


    return Row(
      children: [
        Icon(Icons.timer, color: Colors.cyan.shade700,),
        SizedBox(width: 17,),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Start Hour',
                style: TextStyle(
                    height: 0.5,
                    fontSize: 12,
                    color: Colors.black54),
              ),
              SizedBox(
                width: 10,
              ),
              DropdownButton<String>(
               //value: widget.hour == null ? availableTimeAll[0]?.toString() : '7',
                underline: Container(),
                  isExpanded: true,
                  isDense: true,
                  hint: Text(startHour != null && startHour >= 10 ? '$startHour:00'
                      : startHour != null && startHour < 10 ? '0$startHour:00'
                      : '',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),

                  items: event != null && event.creatorId == Auth().currentUser.uid && !selDate.isBefore(today) && isDone == false || event == null ? availableTimeAll
                      .map(
                        (value) =>
                        DropdownMenuItem<
                            String>(
                          child:
                          Text(value >= 10 ?'$value:00' : '0$value:00', style: TextStyle(fontSize: 15),),
                          value: value.toString(),
                        ),
                  )
                      .toList() : null,
                  onChanged: (value) {

                    endTime.clear();
                    getEndTime(value);

                   setState(() {
                     startHour = int.parse(value);
                     if (startHour < 24) {
                       endHour = endTime[0];
                     }
                   });
                  }
              ),
            ],
          ),
        ),

        SizedBox(
          width: 30,
        ),
        Icon(Icons.timer_off, color: endTime.isNotEmpty? Colors.cyan.shade700 : Colors.black38,),
        SizedBox(width: 17,),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'End Hour',
                style: TextStyle(
                    height: 0.5,
                    fontSize: 12,
                    color: Colors.black54),
              ),
              SizedBox(
                width: 10,
              ),
              DropdownButton<String>(
                //value: endTime[0].toString(),
                underline: Container(),
                isExpanded: true,
                isDense: true,
                hint: Text(endHour != null && endHour >= 10 ? '$endHour:00'
                    : endHour != null && endHour < 10 ? '0$endHour:00'
                    : '',
                  style:  endHour > startHour ?
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black) :
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red),),

                items: event != null && event.creatorId == Auth().currentUser.uid  && isDone == false || event == null ?
                endTime
                    .map(
                      (value) =>
                      DropdownMenuItem<
                          String>(
                        child:
                        Text(value > 9 ?'$value:00' : '0$value:00'),
                        value: value.toString(),
                      ),
                )
                    .toList() : null,
                onChanged: (value) {
                  setState(() {
                    endHour = int.parse(value);
                  });

                  //FocusScope.of(context).nextFocus();
                },
              ),
            ],
          ),
        ),
        SizedBox(width: 12,)
      ],
    );
  }

  void getEndTime(String starHour) {
    for (var i = int.parse(starHour);
    i < i + 6;
    i++) {
      if (availableTimeAll
          .contains(i)) {
        endTime.add(i);
      } else
        break;
    }
    if (endTime.last < 24) {
      endTime.add(endTime.last + 1);
    }
    endTime.removeAt(0);
  }
  
}


