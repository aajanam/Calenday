import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/pages/colleague.dart';
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

  Participants(
      {this.regUser,
      this.event,
      this.participants,
      this.procedure,
      this.place,
      this.date,
      this.isDone});

  @override
  _ParticipantsState createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  String name = '';
  List groups = ['All'];
  String groupItem;
  List colleagues = [];
  String highlight = 'All';
  bool isInGroup;
  List initialPlayIds = [];
  List playIds = [];
  List colleagueIDList = [];
  List userWhoHaveMyId = [];

  Future sendMessage(playerId, messageTitle, messageBody, date, time) async {
    await OneSignal.shared.postNotification(OSCreateNotification(
        playerIds: [playerId],
        content: messageBody,
        heading: messageTitle,
        sendAfter: DateTime.now().add(Duration(seconds: 30)).toUtc(),
        additionalData: {'time': time, 'date':date},
        androidSmallIcon: 'ic_launcher',
        androidLargeIcon: 'ic_launcher_round'));
  }

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.text = name;

    final person = Provider.of<UserProvider>(context, listen: false);
    final event = Provider.of<EventProvider>(context, listen: false);
    if (widget.regUser != null) {
      person.loadAll(widget.regUser);
      colleagues = widget.regUser.colleagues;
    } else {
      person.loadAll(null);
    }
    if (widget.event != null) {
      event.loadAll(widget.event);
    } else {
      event.loadAll(null);
    }

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = Provider.of<EventProvider>(context);
    final person = Provider.of<UserProvider>(context);
    print(widget.date);
    return StreamBuilder<List<RegUser>>(
        stream: person.users,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            for (var user in snapshot.data) {
              if (user.colleagues != null && user.colleagues.length > 0) {
                for (var coll in user.colleagues) {
                  if (coll['collId'] == Auth().currentUser.uid) {
                    userWhoHaveMyId.add(user.uid);
                  }
                }
              }
            }

            colleagueIDList = person.colleagues
                .asMap()
                .values
                .map((e) => e['collId'])
                .toList();

            for (var i in widget.participants) {
              var playId = snapshot.data
                  .where((element) => element.uid == i['id'])
                  .single
                  .deviceToken;
              if (i['id'] != Auth().currentUser.uid && playId != null) {
                initialPlayIds.add(playId);
                initialPlayIds = initialPlayIds.toSet().toList();
              }
            }
            var collInGroup = person.colleagues
                .map((e) =>
                    e['group'].contains(highlight) &&
                    !widget.participants
                        .map((p) => p['id'])
                        .contains(e['collId']))
                .where((element) => element == true)
                .length;
            int remaining =
                (widget?.participants?.length ?? 0) - person.colleagues.length;
            bool show = widget.participants.length > 1 &&
                event.procedure != null &&
                event.diagnose != null;

            print(remaining);

            return Scaffold(
              appBar: AppBar(
                brightness: Brightness.dark,
                backgroundColor: Color.fromRGBO(48, 48, 48, 1),
                actions: [
                  person.colleagues.length > 0 /*|| person.colleagues != null*/ ? TextButton
                          .icon(
                              icon: Icon(
                                Icons.book_outlined,
                                size: 28,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Colleague(
                                          regUser: snapshot.data.singleWhere(
                                              (element) =>
                                                  element.uid ==
                                                  Auth().currentUser.uid),
                                        )));
                              },
                              label: Text(
                                'Colleagues',
                                style: TextStyle(color: Colors.white),
                              ))
                      : Container(),
                  SizedBox(
                    width: 25,
                  )
                ],
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    if (widget.event != null) {
                      for (var i in playIds) {
                        sendMessage(
                            i,
                            '${person.displayName} invites you',
                            '${formatDate(DateTime.parse(widget.date), [
                                  'dd',
                                  ' ',
                                  'M',
                                  ' ',
                                  'yyyy'
                                ])} : ${widget.procedure} at ${widget.place}',
                            '${widget.date}',
                            '${widget.event.startHour}');
                      }
                    }

                    Navigator.of(context).pop();
                  },
                ),
                elevation: 0,
                title: Text('Participants',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                titleSpacing: 0,
              ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.regUser.uid == Auth().currentUser.uid &&
                            widget.isDone == false
                        ? Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 0.0,
                                    top: 10,
                                  ),
                                  child: TextFormField(
                                    cursorColor: Colors.white,
                                    enabled:
                                        widget.isDone == false ? true : false,

                                    controller: _searchController,
                                    textInputAction: TextInputAction.done,
                                    //focusNode: searchNode,
                                    decoration: InputDecoration(
                                        suffixIcon: name == '' &&
                                                collInGroup > 0 &&
                                                widget.isDone == false
                                            ? Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 8),
                                                child: GestureDetector(
                                                    onTap: () {
                                                      for (var item in person
                                                          .colleagues
                                                          .where((element) =>
                                                              userWhoHaveMyId
                                                                  .contains(element[
                                                                      'collId']))) {
                                                        if (item['group']
                                                                .contains(
                                                                    highlight) &&
                                                            !widget.participants
                                                                .map((e) =>
                                                                    e['id'])
                                                                .contains(item[
                                                                    'collId'])) {
                                                          setState(() {
                                                            var val = {
                                                              'id': snapshot
                                                                  .data
                                                                  .where((element) =>
                                                                      element
                                                                          .uid ==
                                                                      item[
                                                                          'collId'])
                                                                  .single
                                                                  .uid,
                                                              'notifyStat':
                                                                  false,
                                                              'hour': null
                                                            };
                                                            widget.participants
                                                                .add(val);
                                                            event.changeParticipants =
                                                                widget
                                                                    .participants;
                                                          });
                                                          if (snapshot.data
                                                                  .where((element) =>
                                                                      element
                                                                          .uid ==
                                                                      item[
                                                                          'collId'])
                                                                  .first
                                                                  .deviceToken !=
                                                              null) {
                                                            playIds.add(snapshot
                                                                .data
                                                                .where((element) =>
                                                                    element
                                                                        .uid ==
                                                                    item[
                                                                        'collId'])
                                                                .first
                                                                .deviceToken);
                                                          }
                                                          playIds = playIds
                                                              .toSet()
                                                              .toList();
                                                          if (widget.event !=
                                                              null) {
                                                            event.saveEvent();
                                                            print(playIds);
                                                          }
                                                        }
                                                      }
                                                    },
                                                    child: Chip(
                                                      side: BorderSide(
                                                          color: Colors.blue),
                                                      label: Text('Invite All'),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0,
                                                              horizontal: 8),
                                                      labelStyle: TextStyle(
                                                          color: Colors
                                                              .lightBlueAccent
                                                              .shade100,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 10),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    )),
                                              )
                                            : Container(
                                                width: 0,
                                              ),
                                        // isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 20, top: 3, bottom: 3),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  100, 100, 100, 1),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        prefixIcon: Icon(
                                          Icons.search,
                                        ),
                                        hintText: 'Search Colleagues ',
                                        hintStyle: TextStyle(fontSize: 14)),
                                    onChanged: (query) {
                                      getParticipants(query);

                                      setState(() {
                                        name = query;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Container(
                                  height: 80,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    children: [
                                      Center(
                                          child: Text(
                                        'Sort by: ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromRGBO(
                                                163, 163, 163, 1)),
                                      )),
                                      for (var i in person.groups)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: GestureDetector(
                                            child: Chip(
                                                labelStyle: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                backgroundColor: highlight == i
                                                    ? Colors.deepPurple
                                                    : Color.fromRGBO(
                                                        100, 100, 100, 1),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 8),
                                                label: Text(i)),
                                            onTap: () {
                                              setState(() {
                                                highlight = i;
                                              });
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 3,
                                  color: Color.fromRGBO(38, 38, 38, 1),
                                  margin: EdgeInsets.only(bottom: 5),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Expanded(
                        child: ListView(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            shrinkWrap: true,
                            children: [
                          show
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 3),
                                  child: Text(
                                    'Participants in ${event.procedure} - ${event.diagnose} :',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              : Container(),
                          show
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Swipe to left to remove',
                                    style: TextStyle(
                                        color: Color.fromRGBO(163, 163, 163, 1),
                                        fontSize: 13),
                                  ),
                                )
                              : Container(),
                          //if (name.isEmpty)
                          for (var e = 1; e < widget.participants.length; e++)
                            Dismissible(
                              direction: (widget.event != null &&
                                          widget.event.creatorId ==
                                              Auth().currentUser.uid) ||
                                      widget.event == null
                                  ? DismissDirection.endToStart
                                  : DismissDirection.none,
                              background: Container(
                                decoration: BoxDecoration(
                                    color: Colors.pinkAccent.withOpacity(0.1),
                                    border: Border(
                                      right: BorderSide(
                                          color: Colors.black, width: 2),
                                      top: BorderSide(
                                          color: Colors.black, width: 1.5),
                                      bottom: BorderSide(
                                          color: Colors.black, width: 0.2),
                                      left: BorderSide(
                                          color: Colors.black, width: 0.2),
                                    )),
                                child: Center(
                                    child: Text(
                                  'Remove from participant list',
                                  style: TextStyle(
                                      color: Colors.pink.shade100,
                                      fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.center,
                                )),
                              ),
                              key: Key(widget.participants[e].toString()),
                              onDismissed: (direction) async {
                                playIds.remove(snapshot.data
                                    .where((element) =>
                                        element.uid ==
                                        widget.participants[e]['id'])
                                    .first
                                    .deviceToken);

                                setState(() {
                                  widget.participants
                                      .remove(widget.participants[e]);
                                  event.changeParticipants =
                                      widget.participants;
                                });
                                if (widget.event != null) {
                                  event.saveEvent();
                                }
                              },
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot.data
                                      .where((element) =>
                                          element.uid ==
                                          widget.participants[e]['id'])
                                      .single
                                      .photoUrl),
                                ),
                                title: Text(
                                  snapshot.data
                                      .where((element) =>
                                          element.uid ==
                                          widget.participants[e]['id'])
                                      .single
                                      .displayName,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Transform.translate(
                                  offset: Offset(0, -2),
                                  child: Text(
                                      snapshot.data
                                                  .where((element) =>
                                                      element.uid ==
                                                      widget.participants[e]
                                                          ['id'])
                                                  .single
                                                  .specialty !=
                                              null
                                          ? snapshot.data
                                              .where((element) =>
                                                  element.uid ==
                                                  widget.participants[e]['id'])
                                              .single
                                              .specialty
                                          : '',
                                      style: TextStyle(fontSize: 13)),
                                ),
                                trailing: widget.event != null &&
                                            widget?.event?.creatorId ==
                                                Auth().currentUser.uid &&
                                            widget.isDone == false ||
                                        widget.event == null
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.teal,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          !show || remaining < 1
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 8),
                                  child: Text('Invite Participants :',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                )
                              : Container(),
                          if (widget?.event?.creatorId ==
                                      Auth().currentUser.uid &&
                                  person.colleagues.length == 0 ||
                              person.colleagues == null)
                            Container(
                              child: Column(
                                children: [
                                  Center(
                                    child: Text(
                                      'You don\'t have any colleague yet',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            primary: Colors.lightBlue.shade700,
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Colleague(
                                                        regUser: snapshot.data
                                                            .where((element) =>
                                                                element.uid ==
                                                                Auth()
                                                                    .currentUser
                                                                    .uid)
                                                            .first,
                                                      )));
                                        },
                                        child: Text('Add Colleagues >>')),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.event == null && name == '' ||
                              widget?.event?.creatorId ==
                                      Auth().currentUser.uid &&
                                  widget.isDone == false &&
                                  name == '')
                            for (var item in person.colleagues.where(
                                (element) => userWhoHaveMyId
                                    .contains(element['collId'])))
                              item['group'].contains(highlight) &&
                                      !widget.participants
                                          .map((e) => e['id'])
                                          .contains(item['collId'])
                                  ? ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot
                                            .data
                                            .where((element) =>
                                                element.uid == item['collId'])
                                            .single
                                            .photoUrl),
                                      ),
                                      title: Text(
                                        snapshot.data
                                            .where((element) =>
                                                element.uid == item['collId'])
                                            .single
                                            .displayName,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Transform.translate(
                                          offset: Offset(0, -2),
                                          child: Text(
                                            snapshot.data
                                                .where((element) =>
                                                    element.uid ==
                                                    item['collId'])
                                                .single
                                                .specialty,
                                            style: TextStyle(fontSize: 13),
                                          )),
                                      trailing: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              var val = {
                                                'id': snapshot.data
                                                    .where((element) =>
                                                        element.uid ==
                                                        item['collId'])
                                                    .single
                                                    .uid,
                                                'notifyStat': false,
                                                'hour': null
                                              };
                                              widget.participants.add(val);
                                              event.changeParticipants =
                                                  widget.participants;
                                            });
                                            if (snapshot.data
                                                    .where((element) =>
                                                        element.uid ==
                                                        item['collId'])
                                                    .first
                                                    .deviceToken !=
                                                null) {
                                              playIds.add(snapshot.data
                                                  .where((element) =>
                                                      element.uid ==
                                                      item['collId'])
                                                  .first
                                                  .deviceToken);
                                            }
                                            playIds = playIds.toSet().toList();

                                            if (widget.event != null) {
                                              event.saveEvent();
                                            }
                                          },
                                          child: Chip(
                                            side:
                                                BorderSide(color: Colors.blue),
                                            label: Text('Invite'),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 8),
                                            labelStyle: TextStyle(
                                                color: Colors
                                                    .lightBlueAccent.shade100,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                            backgroundColor: Colors.transparent,
                                          )),
                                    )
                                  : Container(),
                          if (widget.event == null && name != '' ||
                              widget?.event?.creatorId ==
                                      Auth().currentUser.uid &&
                                  widget.isDone == false &&
                                  name != '')
                            for (var item in person.colleagues)
                              item['group'].contains(highlight) &&
                                      !widget.participants
                                          .map((e) => e['id'])
                                          .contains(item['collId']) &&
                                      snapshot.data
                                          .where((element) =>
                                              element.uid == item['collId'])
                                          .first
                                          .nameSearch
                                          .contains(name.toLowerCase())
                                  ? ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot
                                            .data
                                            .where((element) =>
                                                element.uid == item['collId'])
                                            .single
                                            .photoUrl),
                                      ),
                                      title: Text(
                                          snapshot.data
                                              .where((element) =>
                                                  element.uid == item['collId'])
                                              .single
                                              .displayName,
                                          style: TextStyle(fontSize: 14)),
                                      subtitle: Transform.translate(
                                          offset: Offset(0, -2),
                                          child: Text(
                                              snapshot.data
                                                  .where((element) =>
                                                      element.uid ==
                                                      item['collId'])
                                                  .single
                                                  .specialty,
                                              style: TextStyle(fontSize: 13))),
                                      trailing: GestureDetector(
                                          onTap: () {
                                            _searchController.clear();
                                            setState(() {
                                              var val = {
                                                'id': snapshot.data
                                                    .where((element) =>
                                                        element.uid ==
                                                        item['collId'])
                                                    .single
                                                    .uid,
                                                'notifyStat': false,
                                                'hour': null
                                              };
                                              widget.participants.add(val);
                                              event.changeParticipants =
                                                  widget.participants;
                                            });
                                            name = '';
                                            if (snapshot.data
                                                    .where((element) =>
                                                        element.uid ==
                                                        item['collId'])
                                                    .first
                                                    .deviceToken !=
                                                null) {
                                              playIds.add(snapshot.data
                                                  .where((element) =>
                                                      element.uid ==
                                                      item['collId'])
                                                  .first
                                                  .deviceToken);
                                            }
                                            playIds = playIds.toSet().toList();

                                            if (widget.event != null) {
                                              event.saveEvent();
                                            }
                                          },
                                          child: Chip(
                                            side:
                                                BorderSide(color: Colors.blue),
                                            label: Text('Invite'),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 8),
                                            labelStyle: TextStyle(
                                                color: Colors
                                                    .lightBlueAccent.shade100,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10),
                                            backgroundColor: Colors.transparent,
                                          )),
                                    )
                                  : Container()
                        ])),
                  ],
                ),
              ),
            );
          }
          return Indicator();
        });
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
