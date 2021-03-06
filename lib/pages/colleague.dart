import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class Colleague extends StatefulWidget {
  final RegUser regUser;
  final String iD;
  final String reqName;

  Colleague({this.regUser, this.iD, this.reqName});

  @override
  _ColleagueState createState() => _ColleagueState();
}

class _ColleagueState extends State<Colleague> {
  TextEditingController _searchController = TextEditingController();
  String name = '';
  String groupItem;
  List colleagues = [];
  String highlight = 'All';
  bool isInGroup;
  List playIds = [];
  List<dynamic> colleagueIDList;
  List userWhoHaveMyId = [];
  bool isAwait = false;

  @override
  void initState() {
    if (widget.reqName != null) {
      name = widget.reqName;
    }
    _searchController.text = name;
    final person = Provider.of<UserProvider>(context, listen: false);
    if (widget.regUser != null) {
      person.loadAll(widget.regUser);
    } else {
      person.loadAll(null);
    }

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future sendMessage(playerId, messageTitle, messageBody, id) async {
    DateTime now = DateTime.now();
    await OneSignal.shared.postNotification(OSCreateNotification(
        playerIds: [playerId],
        collapseId: DateTime(now.year, now.month, now.day).toString(),
        content: messageBody,
        heading: messageTitle,
        sendAfter: DateTime.now().add(Duration(seconds: 10)).toUtc(),
        additionalData: {'name': id},
        androidSmallIcon: 'ic_launcher',
        androidLargeIcon: 'ic_launcher_round'));
  }

  @override
  Widget build(BuildContext context) {
    final person = Provider.of<UserProvider>(context);
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
            if (isAwait == true) {
              colleagueIDList = person.colleagues
                  .where(
                      (element) => !userWhoHaveMyId.contains(element['collId']))
                  ?.toList();
            } else {
              colleagueIDList = person.colleagues.toList();
            }

            return Scaffold(
              appBar: AppBar(
                brightness: Brightness.dark,
                elevation: 0,
                backgroundColor: Color.fromRGBO(48, 48, 48, 1),
                titleSpacing: 0,
                title: Text('My Colleagues',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0, top: 10),
                      child: TextFormField(
                        controller: _searchController,
                        cursorColor: Colors.white,
                        style: TextStyle(fontSize: 15),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          contentPadding:
                              EdgeInsets.only(left: 20, top: 3, bottom: 3),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(20)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(100, 100, 100, 1),
                              ),
                              borderRadius: BorderRadius.circular(20)),
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                          hintText: 'Search people',
                        ),
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
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: [
                          GestureDetector(
                            child: Chip(
                              backgroundColor: Colors.blue,
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              label: Text('Create group'),
                            ),
                            onTap: () => showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.0))),
                                context: context,
                                builder: (context) => Container(
                                      child: Padding(
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8,
                                                    top: 8.0,
                                                    bottom: 8),
                                                child: TextFormField(
                                                  cursorColor: Colors.white,
                                                  autofocus: true,
                                                  decoration: InputDecoration(
                                                    hintText: 'Create Group',
                                                    labelStyle: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    hintStyle: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    alignLabelWithHint: true,
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 20,
                                                            top: 3,
                                                            bottom: 3),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .blue),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      100,
                                                                      100,
                                                                      100,
                                                                      1),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                  ),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      groupItem = val;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                ),
                                                onPressed: () {
                                                  if (!person.groups
                                                      .contains(groupItem)) {
                                                    person.groups
                                                        .insert(1, groupItem);
                                                  }

                                                  if (widget.regUser != null) {
                                                    person.setUser();
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Create')),
                                            SizedBox(
                                              width: 8,
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 4),
                              child: GestureDetector(
                                child: Chip(
                                  labelStyle: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                  backgroundColor:
                                      highlight == 'All' && isAwait == false
                                          ? Colors.deepPurple
                                          : Color.fromRGBO(160, 160, 160, 1),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  label: Text('All'),
                                ),
                                onTap: () {
                                  setState(() {
                                    isAwait = false;
                                    highlight = 'All';
                                  });
                                },
                              )),
                          Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 4),
                              child: GestureDetector(
                                child: Chip(
                                  labelStyle: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isAwait == true
                                          ? Colors.black
                                          : Colors.white),
                                  backgroundColor: isAwait == true
                                      ? Colors.amberAccent.shade100
                                      : Color.fromRGBO(100, 100, 100, 1),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  label: Text('await'),
                                ),
                                onTap: () {
                                  setState(() {
                                    isAwait = !isAwait;
                                    highlight = 'All';
                                  });
                                },
                              )),
                          for (var i = 1; i < person.groups.length; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: GestureDetector(
                                child: Chip(
                                  labelStyle: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                  backgroundColor: highlight == person.groups[i]
                                      ? Colors.deepPurple
                                      : Color.fromRGBO(100, 100, 100, 1),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  label: Text(person.groups[i]),
                                  onDeleted: () {
                                    setState(() {
                                      person.groups.removeAt(i);
                                    });
                                    if (widget.regUser != null) {
                                      person.setUser();
                                    }
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    isAwait = false;
                                    highlight = person.groups[i];
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      color: Color.fromRGBO(38, 38, 38, 1),
                      height: 3,
                      margin: EdgeInsets.only(bottom: 5),
                    ),
                    person.colleagues
                                .where((element) =>
                                    userWhoHaveMyId.contains(element['collId']))
                                .length >
                            0
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              (name.isEmpty)
                                  ? 'Swipe to left to remove'
                                  : 'Search result : ',
                              style: TextStyle(
                                  color: Color.fromRGBO(160, 160, 160, 1),
                                  fontSize: 13),
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        shrinkWrap: true,
                        children: [
                          for (var i in snapshot.data.where((element) =>
                              !person.colleagues
                                      .map((e) => e['collId'])
                                      .contains(element.uid) &&
                                  element.nameSearch
                                      .contains(name.toLowerCase()) &&
                                  element.uid != Auth().currentUser.uid ||
                              element.uid == widget.iD &&
                                  !person.colleagues
                                      .map((e) => e['collId'])
                                      .contains(widget.iD)))
                            ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(i.photoUrl),
                                ),
                                title: Text(
                                  i.displayName,
                                  style: TextStyle(fontSize: 14),
                                ),
                                subtitle: Transform.translate(
                                    offset: Offset(0, -2),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          i.email,
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        i.specialty != null
                                            ? Transform.translate(
                                                offset: Offset(0, -2),
                                                child: Text(
                                                  i?.specialty ?? '',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ))
                                            : Container(),
                                      ],
                                    )),
                                trailing: GestureDetector(
                                  child: Chip(
                                    side: BorderSide(color: Colors.tealAccent),
                                    label: Text('Add'),
                                    labelStyle: TextStyle(
                                        color: Colors.tealAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                    backgroundColor: Colors.transparent,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6),
                                  ),
                                  onTap: () {
                                    if (widget.reqName == null) {
                                      sendMessage(
                                          i.deviceToken,
                                          'Colleague request',
                                          'from ${person.displayName}',
                                          '${person.uid}');
                                    }

                                    setState(() {
                                      var val = {
                                        'collId': i.uid,
                                        'group': ['All'],
                                      };
                                      person.colleagues.add(val);
                                      name = '';
                                    });

                                    if (widget.regUser != null) {
                                      person.setUser();
                                    }
                                    _searchController.clear();
                                  },
                                )),
                          if (name.isEmpty)
                            for (var item in colleagueIDList)
                              item['group'].contains(highlight)
                                  ? Dismissible(
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.pinkAccent
                                                .withOpacity(0.1),
                                            border: Border(
                                              right: BorderSide(
                                                  color: Colors.black,
                                                  width: 2),
                                              top: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5),
                                              bottom: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.2),
                                              left: BorderSide(
                                                  color: Colors.black,
                                                  width: 0.2),
                                            )),
                                        child: Center(
                                            child: Text(
                                          'Remove from colleague list',
                                          style: TextStyle(
                                              color: Colors.pink.shade100,
                                              fontStyle: FontStyle.italic),
                                          textAlign: TextAlign.center,
                                        )),
                                      ),
                                      key: Key(item.toString()),
                                      confirmDismiss: (d) => showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: Text(
                                                  'Remove Colleague?',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                15.0))),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          person.colleagues
                                                              .remove(item);
                                                        });
                                                        if (widget.regUser !=
                                                            null) {
                                                          person.setUser();
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Remove",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors.pink
                                                                  .shade300)))
                                                ],
                                              )),
                                      child: ListTile(
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              Color.fromRGBO(100, 100, 100, 1),
                                          backgroundImage: userWhoHaveMyId
                                                  .contains(item['collId'])
                                              ? NetworkImage(snapshot.data
                                                  .where((element) =>
                                                      element.uid ==
                                                      item['collId'])
                                                  .first
                                                  .photoUrl)
                                              : null,
                                        ),
                                        title: Text(
                                          snapshot.data
                                              .where((element) =>
                                                  element.uid == item['collId'])
                                              .first
                                              .displayName,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: userWhoHaveMyId
                                                      .contains(item['collId'])
                                                  ? FontWeight.w600
                                                  : null,
                                              fontStyle: userWhoHaveMyId
                                                      .contains(item['collId'])
                                                  ? FontStyle.normal
                                                  : FontStyle.italic),
                                        ),
                                        subtitle: Transform.translate(
                                          offset: Offset(0, -2),
                                          child: Text(
                                            snapshot.data
                                                        .where((element) =>
                                                            element.uid ==
                                                            item['collId'])
                                                        .first
                                                        .specialty !=
                                                    null
                                                ? snapshot.data
                                                    .where((element) =>
                                                        element.uid ==
                                                        item['collId'])
                                                    .first
                                                    .specialty
                                                : '',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontStyle:
                                                    userWhoHaveMyId.contains(
                                                            item['collId'])
                                                        ? FontStyle.normal
                                                        : FontStyle.italic),
                                          ),
                                        ),
                                        trailing:
                                            userWhoHaveMyId
                                                    .contains(item['collId'])
                                                ? IconButton(
                                                    icon: Icon(
                                                        Icons.group_rounded),
                                                    //color: Colors.teal,
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.vertical(
                                                                      top: Radius
                                                                          .circular(
                                                                              10.0))),
                                                          builder:
                                                              (context) =>
                                                                  ListView(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15,
                                                                        vertical:
                                                                            15),
                                                                    shrinkWrap:
                                                                        true,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            bottom:
                                                                                10,
                                                                            left:
                                                                                15),
                                                                        child: Text(
                                                                            'Add to / Remove from Group(s) '),
                                                                      ),
                                                                      for (var i
                                                                          in person
                                                                              .groups)
                                                                        StatefulBuilder(builder:
                                                                            (context,
                                                                                setModalState) {
                                                                          if (item['group']
                                                                              .contains(i)) {
                                                                            setModalState(() {
                                                                              isInGroup = true;
                                                                            });
                                                                          } else {
                                                                            setModalState(() {
                                                                              isInGroup = false;
                                                                            });
                                                                          }
                                                                          return SingleChildScrollView(
                                                                            child: i != 'All'
                                                                                ? Row(
                                                                                    //contentPadding: EdgeInsets.symmetric(horizontal: 30),
                                                                                    children: [
                                                                                        IconButton(
                                                                                            icon: isInGroup == true
                                                                                                ? Icon(
                                                                                                    Icons.check_box,
                                                                                                    color: Colors.blue,
                                                                                                  )
                                                                                                : Icon(
                                                                                                    Icons.check_box_outline_blank,
                                                                                                    color: Colors.grey,
                                                                                                  ),
                                                                                            onPressed: () {
                                                                                              if (!item['group'].contains(i)) {
                                                                                                item['group'].add(i);
                                                                                                person.setUser();
                                                                                                setModalState(() {
                                                                                                  isInGroup = true;
                                                                                                });
                                                                                              } else if (item['group'].contains(i)) {
                                                                                                item['group'].remove(i);
                                                                                                person.setUser();
                                                                                                setModalState(() {
                                                                                                  isInGroup = false;
                                                                                                });
                                                                                              }
                                                                                            }),
                                                                                        Text(
                                                                                          i,
                                                                                          style: TextStyle(fontSize: 14),
                                                                                        ),
                                                                                      ])
                                                                                : Container(),
                                                                          );
                                                                        })
                                                                    ],
                                                                  ));
                                                    })
                                                : Text('await...',
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.yellow,
                                                    )),
                                      ),
                                    )
                                  : Container(),
                        ],
                      ),
                    ),
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
