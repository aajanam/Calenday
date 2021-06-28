import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/pages/colleague.dart';
import 'package:jadwalku/pages/profile.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class Participants extends StatefulWidget {
  final RegUser regUser;
  final Events event;
  final List participants;
  final String procedure;
  final String place;
  final String date;
  final bool isDone;

  Participants({this.regUser, this.event, this.participants, this.procedure, this.place, this.date, this.isDone});

  @override
  _ParticipantsState createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {

  final _shareController = TextEditingController();
  String name = '';
  List groups = ['All'];
  String groupItem;
  List colleagues = [];
  String highlight = 'All';
  bool isInGroup;
  List initialPlayIds = [];
  List playIds =[];
  List colleagueIDList = [];
  List userWhoHaveMyId = [];

  Future sendMessage(playerId, messageTitle, messageBody, collapseID) async {
    await OneSignal.shared.postNotification(OSCreateNotification(
        playerIds: [playerId],
        content: messageBody,
        heading: messageTitle,
        collapseId:collapseID,
        sendAfter: DateTime.now().add(Duration(seconds: 30)).toUtc(),
      androidSmallIcon: 'ic_launcher',
      androidLargeIcon: 'ic_launcher_round'
    ));
  }



  @override
  void initState() {
    final person = Provider.of<UserProvider>(context, listen: false);
    final event = Provider.of<EventProvider>(context, listen: false);
    if (widget.regUser != null) {
      person.loadAll(widget.regUser);
      colleagues = widget.regUser.colleagues;
    } else {
      person.loadAll(null);
    }
    if(widget.event != null){
      event.loadAll(widget.event);
    }else{
      event.loadAll(null);
    }

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final event = Provider.of<EventProvider>(context);
    final person = Provider.of<UserProvider>(context);
    print(widget.date);
    return StreamBuilder<List<RegUser>>(
        stream: person.users,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            for(var user in snapshot.data){
              if(user.colleagues != null && user.colleagues.length > 0){
                for (var coll in user.colleagues){
                  if(coll['collId'] == Auth().currentUser.uid){
                    userWhoHaveMyId.add(user.uid);
                  }
                }
              }
            }

            colleagueIDList = person.colleagues.asMap().values.map((e) => e['collId']).toList();

            for(var i in widget.participants){
              var playId = snapshot.data.where((element) => element.uid == i['id']).single.deviceToken;
              if (i['id'] != Auth().currentUser.uid && playId != null) {
                initialPlayIds.add(playId);
                initialPlayIds = initialPlayIds.toSet().toList();
              }
            }
            var collInGroup = person.colleagues.map((e) => e['group'].contains(highlight) &&
                !widget.participants.map((p) => p['id']).contains(e['collId'])).where((element) => element == true).length;

            return  Scaffold(
              appBar: AppBar(
                brightness: Brightness.dark,
                backgroundColor: Color.fromRGBO(77, 116, 99, 0.9),
                actions: [
                  person.colleagues.length > 0 /*|| person.colleagues != null*/ ? TextButton.icon(

                    icon: Icon(Icons.book_outlined, size: 28, color: Colors.white,),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                            Colleague()));
                      },
                      label: Text('Colleagues', style: TextStyle(color: Colors.white),)) : Container(),
                  SizedBox(width: 25,)
                ],
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: (){
                    if (widget.event != null) {
                      for(var i in playIds){

                          sendMessage(
                            i,
                            '${person.displayName} invites you',
                            '${formatDate(DateTime.parse(widget.date), ['dd', ' ', 'M', ' ', 'yyyy'])} : ${widget.procedure} at ${widget.place}',
                          '${widget.date}');

                      }
                    }

                    Navigator.of(context).pop();
                  },
                ),
                elevation: 0,
                title: Text('Participants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                titleSpacing: 0,
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal:20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    widget.regUser.uid == Auth().currentUser.uid && widget.isDone == false ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom:0.0, top: 10,),
                            child: TextFormField(
                              enabled: widget.isDone == false ? true : false,

                              controller: _shareController,
                              textInputAction: TextInputAction.done,
                              //focusNode: searchNode,
                              decoration: InputDecoration(
                                suffixIcon:  name == '' && collInGroup  > 0 && widget.isDone == false ? Padding(
                                  padding:  EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                  child: GestureDetector(
                                      onTap: (){
                                        for(var item in person.colleagues.where((element) => userWhoHaveMyId.contains(element['collId']))){
                                          if (item['group'].contains(highlight) &&  !widget.participants.map((e) => e['id']).contains(item['collId'])){
                                            setState(() {
                                              var val = {'id': snapshot.data.where((element) => element.uid == item['collId']).single.uid,
                                                'notifyStat': false,
                                                'hour': null};
                                              widget.participants.add(val);
                                              event.changeParticipants = widget.participants;
                                            });
                                            if (snapshot.data.where((element) => element.uid == item['collId']).first.deviceToken != null) {
                                              playIds.add(snapshot.data.where((element) => element.uid == item['collId']).first.deviceToken);
                                            }
                                            playIds = playIds.toSet().toList();
                                            if(widget.event != null){
                                              event.saveEvent();
                                              print(playIds);
                                            }
                                          }
                                        }
                                      },
                                      child:
                                  Chip(label: Text('Invite All'), padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10),
                                  backgroundColor: Colors.teal,)),
                                ) : Container(width: 0,),
                               // isDense: true,
                                contentPadding: EdgeInsets.only(left: 20, top: 3, bottom: 3 ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(20)
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueGrey.shade200,), borderRadius: BorderRadius.circular(20)
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                ),
                                hintText: 'Search Colleagues ',
                                hintStyle: TextStyle(fontSize: 14)
                              ),
                              onChanged: (query) {
                                getParticipants(query);

                                setState(() {
                                  name = query;
                                });
                              },
                            ),
                          ) ,
                          SizedBox(height: 2,),

                          Container(
                            height: 60,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: [
                                Center(child: Text('Sort by: ', style: TextStyle(fontSize: 14),)),

                                for(var i in person.groups)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: GestureDetector(
                                      child: Chip(
                                          labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                          backgroundColor: highlight == i ? Colors.lightBlue.shade100: Colors.grey.shade300,
                                          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                          label: Text(i)),
                                      onTap: (){
                                        setState(() {
                                          highlight = i;
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ) ,
                          Container( height: 1, color: Colors.grey.shade400, margin: EdgeInsets.only(bottom: 5),),
                          Text('Swipe to left to remove', style: TextStyle(color: Colors.black54, fontSize: 13),)
                        ],
                      ),
                    )
                    : Container(),

                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(top: 10,bottom: 10),
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 8),
                            child: Text(widget.participants.length > 1 && event.procedure != null && event.diagnose != null ?
                            'Participants in ${event.procedure} - ${event.diagnose}:' : 'Invite participants:',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          for(var e = 1; e < widget.participants.length; e++)
                            Dismissible(
                              direction: DismissDirection.endToStart,
                              background: Container(color: Colors.pink.shade100, child: Center(child: Text('Remove from participant list', style: TextStyle(color:Colors.pink.shade600, fontStyle: FontStyle.italic), textAlign: TextAlign.center,)),),
                              key: Key(widget.participants[e].toString()),
                              onDismissed: (direction)async {

                                playIds.remove(snapshot.data.where((element) => element.uid == widget.participants[e]['id']).first.deviceToken);

                                setState(() {
                                  widget.participants.remove(widget.participants[e]);
                                  event.changeParticipants = widget.participants;

                                });
                                if(widget.event != null){
                                  event.saveEvent();
                                }
                              },
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                leading: CircleAvatar(backgroundImage: NetworkImage(snapshot.data.where((element) => element.uid == widget.participants[e]['id']).single.photoUrl),),
                                title: Text(snapshot.data.where((element) => element.uid == widget.participants[e]['id']).single.displayName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                                subtitle: Transform.translate(
                                  offset: Offset(0, -5),
                                  child: Text(snapshot.data.where((element) => element.uid == widget.participants[e]['id']).single.specialty != null ?
                                  snapshot.data.where((element) => element.uid == widget.participants[e]['id']).single.specialty : '', style: TextStyle(fontSize: 13)),
                                ),
                                trailing: widget.event != null && widget?.event?.creatorId == Auth().currentUser.uid && widget.isDone == false || widget.event == null
                                    ? Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: Icon(Icons.check, color: Colors.teal,),
                                    ) : null,
                              ),
                            ) ,
                          if(widget?.event?.creatorId == Auth().currentUser.uid && person.colleagues.length == 0 || person.colleagues == null)
                            Container(
                              child: Column(
                                children: [
                                  Center(
                                    child: Text('You don\'t have any colleague yet', textAlign: TextAlign.center,style: TextStyle(fontSize: 15, color: Colors.black54),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                            primary: Colors.lightBlue.shade700,
                                            textStyle: TextStyle(fontWeight: FontWeight.w600)),
                                        onPressed: (){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                      ProfilePage(3, person.displayName,'')));
                                    },
                                        child: Text('Add Colleagues >>')),
                                  ),
                                ],
                              ),
                            ),


                          if(widget.event == null && name == ''|| widget?.event?.creatorId == Auth().currentUser.uid && widget.isDone == false && name == '')
                            for(var item in person.colleagues.where((element) => userWhoHaveMyId.contains(element['collId'])))
                              item['group'].contains(highlight) && !widget.participants.map((e) => e['id']).contains(item['collId']) ? ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      snapshot.data.where((element) => element.uid == item['collId']).single.photoUrl),
                                ),
                                title: Text(snapshot.data.where((element) => element.uid == item['collId']).single.displayName, style: TextStyle(fontSize: 14),),
                                subtitle: Transform.translate(
                                    offset: Offset(0, -5), child: Text(snapshot.data.where((element) => element.uid == item['collId']).single.specialty, style: TextStyle(fontSize: 13),)),
                                trailing: GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        var val = {'id': snapshot.data.where((element) => element.uid == item['collId']).single.uid,
                                          'notifyStat': false,
                                          'hour': null};
                                        widget.participants.add(val);
                                        event.changeParticipants = widget.participants;
                                      });
                                      if (snapshot.data.where((element) => element.uid == item['collId']).first.deviceToken != null) {
                                        playIds.add(snapshot.data.where((element) => element.uid == item['collId']).first.deviceToken);
                                      }
                                      playIds = playIds.toSet().toList();

                                      if(widget.event != null){
                                        event.saveEvent();
                                        print(playIds);
                                      }
                                    },
                                    child:
                                    Chip(label: Text('Invite'), padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10),
                                      backgroundColor: Colors.teal.shade400,)),
                              ) : Container(),

                          if(widget.event == null && name != '' || widget?.event?.creatorId == Auth().currentUser.uid && widget.isDone == false && name != '')
                          for (var item in person.colleagues)
                              item['group'].contains(highlight) && !widget.participants.map((e) => e['id']).contains(item['collId']) && snapshot.data.where((element) => element.uid == item['collId']).first.nameSearch.contains(name) ?
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      snapshot.data.where((element) => element.uid == item['collId']).single.photoUrl),
                                ),
                                title: Text(snapshot.data.where((element) => element.uid == item['collId']).single.displayName),
                                subtitle: Transform.translate(
                                    offset: Offset(0, -5), child: Text(snapshot.data.where((element) => element.uid == item['collId']).single.specialty)),
                                trailing: GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        var val = {'id': snapshot.data.where((element) => element.uid == item['collId']).single.uid,
                                          'notifyStat': false,
                                          'hour': null};
                                        widget.participants.add(val);
                                        event.changeParticipants = widget.participants;
                                      });
                                      if (snapshot.data.where((element) => element.uid == item['collId']).first.deviceToken != null) {
                                        playIds.add(snapshot.data.where((element) => element.uid == item['collId']).first.deviceToken);
                                      }
                                      playIds = playIds.toSet().toList();

                                      if(widget.event != null){
                                        event.saveEvent();
                                      }
                                    },
                                    child:
                                    Chip(label: Text('Invite'), padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10),
                                      backgroundColor: Colors.teal.shade400,)),
                              ) : Container()]
          )),
                  ],
                ),
              ),
            );
          }
          return Indicator();
        }
    );
  }
  getParticipants(String name) {
    List<String> nameSearchList = [];
    String temp = "";
    for (int i = 0; i < name.length; i++) {
      temp = temp + name[i];
      nameSearchList.insert(0, temp);
    }
    return nameSearchList;
  }
}
