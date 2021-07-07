import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jadwalku/model/discussion.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/pages/colleague.dart';
import 'package:jadwalku/pages/discuss_page.dart';
import 'package:jadwalku/pages/landing_page.dart';
import 'package:jadwalku/pages/personal.dart';
import 'package:jadwalku/pages/profile.dart';
import 'package:jadwalku/provider/discussion_provider.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:jadwalku/widget/show_alert_dialogue.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';
import 'home.dart';

class NavHome extends StatefulWidget {
  final String payload;
  const NavHome({this.payload, Key key}) : super(key: key);

  @override
  _NavHomeState createState() => _NavHomeState();
}

class _NavHomeState extends State<NavHome> with RouteAware {
  String messageTitle = '';
  String messageContent = '';
  //int count = 0;
  //int time = 6;
  String messageId;
  bool youGotMessage = false;
  String collName;
  String _status;
  String date;

  @override
  void initState() {
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
      setState(() {
        messageTitle = notification.payload.title;
        messageContent = notification.payload.body;
        if (notification.payload.additionalData['id'] != null) {
          messageId = notification.payload.additionalData['id'];
          youGotMessage = true;
        }
        if (notification.payload.additionalData['name'] != null) {
          collName = notification.payload.additionalData['name'];
        }
        if (notification.payload.additionalData['name'] != null &&
            notification.payload.additionalData['status'] != null) {
          collName = notification.payload.additionalData['name'];
          _status = notification.payload.additionalData['status'];
        }
        if (notification.payload.collapseId != null) {
          date = notification.payload.collapseId;
        }
      });
      notification.displayType = OSNotificationDisplayType.notification;
    });

    OneSignal.shared.setNotificationOpenedHandler(
        (OSNotificationOpenedResult result) async {
      result.notification.displayType = OSNotificationDisplayType.notification;

      // will be called whenever a notification is opened/button pressed.
      setState(() {
        date = result.notification.payload.collapseId;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final personal = Provider.of<UserProvider>(context);
    final auth = Provider.of<AuthBase>(context, listen: false);
    final discussion = Provider.of<DiscussionProvider>(context);
    final event = Provider.of<EventProvider>(context);
    print(widget.payload);

    return StreamBuilder<List<RegUser>>(
        stream: personal.users,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Indicator();
          }
          var person = Auth().currentUser;
          var data = snapshot?.data
              ?.where((element) => element.uid == auth.currentUser.uid);
          return StreamBuilder<List<Events>>(
              stream: event.events,
              builder: (context, snapshot) {
                return Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Color.fromRGBO(48, 48, 48, 1),
                    elevation: 0,
                    actions: [
                      IconButton(
                        onPressed: () => _confirmSignOut(context),
                        icon: Icon(Icons.logout),
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  floatingActionButton: (youGotMessage == true &&
                          messageId != null)
                      ? StreamBuilder<List<Discussion>>(
                          stream: discussion.messageList,
                          builder: (context, snap) {
                            if (snap.hasData) {
                              return FloatingActionButton.extended(
                                  label: Text('You got message'),
                                  icon: Icon(Icons.chat),
                                  backgroundColor: Colors.deepOrange,
                                  onPressed: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DiscussPage(
                                                  discussion: snap.data
                                                      .firstWhere((element) =>
                                                          messageId ==
                                                          element.messageId),
                                                  event: snapshot.data
                                                      .where((element) =>
                                                          element.eventId ==
                                                          messageId)
                                                      .first,
                                                ))).then((value) {
                                      setState(() {
                                        messageId = value['messageId'];
                                        youGotMessage = value['youGotMessage'];
                                      });
                                    });
                                  });
                            }
                            return Indicator();
                          })
                      : Container(),
                  body: Column(
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedTextKit(
                              animatedTexts: [
                                TyperAnimatedText(
                                  person.displayName.length > 15
                                      ? 'Hello ${person.displayName.substring(0, person.displayName.lastIndexOf(" "))}'
                                      : 'Hello ${person.displayName}',
                                  textStyle: const TextStyle(
                                    fontSize: 19.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  speed: const Duration(milliseconds: 100),
                                ),
                              ],
                              totalRepeatCount: 1,
                              pause: const Duration(milliseconds: 100),
                              displayFullTextOnTap: true,
                              stopPauseOnTap: true,
                            ),
                            DelayedDisplay(
                              delay: Duration(milliseconds: 2000) ,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                padding: EdgeInsets.only(bottom: 10, left: 5, top:5),
                                decoration: BoxDecoration(
                                  border: (data.single.specialty == null ||
                                      data.single.specialty.length < 3) || collName != null || widget.payload != null ?
                                  Border.all(color: Color.fromRGBO(94, 94, 94, 1)) : null,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Column(
                                  children: [
                                    data.single.specialty == null ||
                                        data.single.specialty.length < 3
                                        ?
                                    ListTile(
                                      visualDensity: VisualDensity(vertical: -4) ,
                                      minVerticalPadding: 0.0,
                                      leading: Icon(CupertinoIcons.profile_circled, size: 20, color: Colors.yellow.shade100,),
                                      title: Text('Please complete your profile ',
                                        style: TextStyle( fontSize: 11,
                                          color: Colors.yellow.shade100,
                                        ),),
                                    ): Container(),
                                    widget.payload != null ?
                                    ListTile(
                                      visualDensity: VisualDensity(vertical: -4) ,
                                      minVerticalPadding: 0.0,
                                      leading: Icon(CupertinoIcons.calendar_badge_plus, size: 20, color: Colors.yellow.shade100,),
                                      title: Text('$messageTitle - $messageContent',
                                        style: TextStyle( fontSize: 11,
                                          color: Colors.yellow.shade100,                                        ),),
                                    ): Container(),
                                    collName!= null ?
                                    ListTile(
                                      visualDensity: VisualDensity(vertical: -4) ,
                                      minVerticalPadding: 0.0,
                                      leading: Icon(CupertinoIcons.group, size: 20, color: Colors.yellow.shade100,),
                                      title: Text('You have colleague request from  $messageContent, add him/her too to your colleague list as well ',
                                        style: TextStyle( fontSize: 11,
                                          color: Colors.yellow.shade100,                                        ),),
                                    ): Container(),
                                  ],
                                ),
                              ),
                            )/*: Container()*/

                          ],
                        ),
                        height: 270,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Stack(children: [
                            GridView.count(
                                crossAxisCount: 2,
                                childAspectRatio: (1 / 1),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                //padding: EdgeInsets.all(10.0),
                                children: [
                                  Material(
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => Personal(
                                                      person: data.single,
                                                    )));
                                      },
                                      splashColor: Colors.black,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              color: Color.fromRGBO(
                                                  61, 99, 102, 0.9)),
                                          padding:
                                              EdgeInsets.only(bottom: 20.0),
                                          child: GridTile(
                                            footer: Text(
                                              'My Profile',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            child: Icon(
                                                CupertinoIcons.profile_circled,
                                                size: 40.0,
                                                color: Colors.white),
                                          ),
                                          margin: EdgeInsets.all(1.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => Colleague(
                                                      regUser: data.single,
                                                    )));
                                        setState(() {
                                          collName = null;
                                          date = null;
                                        });
                                      },
                                      splashColor: Colors.black,
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20)),
                                                  color: Color.fromRGBO(
                                                      92, 150, 156, 0.9)),
                                              padding:
                                                  EdgeInsets.only(bottom: 20.0),
                                              child: GridTile(
                                                footer: Text(
                                                  'My Colleagues',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                child: Icon(
                                                    CupertinoIcons.group,
                                                    size: 40.0,
                                                    color: Colors.white),
                                              ),
                                              margin: EdgeInsets.all(1.0),
                                            ),
                                          ),
                                          Positioned(
                                              right: 0,
                                              top: 0,
                                              child: collName != null
                                                  ? Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        minWidth: 12,
                                                        minHeight: 12,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.pinkAccent
                                                            .shade400,
                                                      ),
                                                      child: Icon(
                                                        CupertinoIcons.bell,
                                                        color: Colors.white,
                                                      ))
                                                  : Container()),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Material(
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) => Home()));
                                        setState(() {
                                          date = null;
                                        });
                                      },
                                      splashColor: Colors.black,
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                color: Color.fromRGBO(
                                                    77, 116, 99, 0.9),
                                              ),
                                              padding:
                                                  EdgeInsets.only(bottom: 20.0),
                                              child: GridTile(
                                                footer: Text(
                                                  'My Calendar',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                child: Icon(
                                                    CupertinoIcons.calendar,
                                                    size: 40.0,
                                                    color: Colors.white),
                                              ),
                                              margin: EdgeInsets.all(1.0),
                                            ),
                                          ),
                                          Positioned(
                                              right: 0,
                                              top: 0,
                                              child: date != null &&
                                                      collName == null
                                                  ? Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        minWidth: 12,
                                                        minHeight: 12,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors
                                                            .deepOrangeAccent,
                                                      ),
                                                      child: Icon(
                                                        Icons.notifications,
                                                        color: Colors.white,
                                                      ))
                                                  : Container()),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Material(
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage(0, '', '')));
                                      },
                                      splashColor: Colors.black,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              color: Color.fromRGBO(
                                                  77, 118, 154, 0.9)),
                                          padding:
                                              EdgeInsets.only(bottom: 20.0),
                                          child: GridTile(
                                            footer: Text(
                                              'My Events List',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            child: Icon(
                                                CupertinoIcons
                                                    .list_bullet_below_rectangle,
                                                size: 40.0,
                                                color: Colors.white),
                                          ),
                                          margin: EdgeInsets.all(1.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LandingPage()));
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
