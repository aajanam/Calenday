import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:badges/badges.dart';
import 'package:bubble/bubble.dart';
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
  String messageId;
  bool youGotMessage = false;
  String collName;
  //String _status;
  String date;
  String reqName;
  String time;

  @override
  void initState() {
    /*  OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      event.complete(event.notification);
    }); */
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    OneSignal.shared.setNotificationReceivedHandler((notification) {
      setState(() {});
      notification.displayType = OSNotificationDisplayType.notification;
    });

    OneSignal.shared.setNotificationOpenedHandler(
        (OSNotificationOpenedResult result) async {
      result.notification.displayType = OSNotificationDisplayType.notification;

      // will be called whenever a notification is opened/button pressed.
      setState(() {
        date = result.notification.payload.additionalData['date'];

        time = result.notification.payload.additionalData['time'];

        messageTitle = result.notification.payload.title;

        messageContent = result.notification.payload.body;

        collName = result.notification.payload.additionalData['name'];

        messageId = result.notification.payload.additionalData['id'];

        if (messageId != null) {
          youGotMessage = true;
        }
      });
    });

    super.initState();
  }

  

  /* void initNotifOne(OSNotification notification) {
    messageTitle = notification.title;
    messageContent = notification.body;
    if (notification.additionalData['id'] != null) {
      messageId = notification.additionalData['id'];
      youGotMessage = true;
    }
    if (notification.additionalData['name'] != null) {
      collName = notification.additionalData['name'];
    }
    if (notification.additionalData['time'] != null) {
      time = notification.additionalData['time'];
    }
    if (notification.additionalData['name'] != null &&
        notification.additionalData['status'] != null) {
      collName = notification.additionalData['name'];
      // _status = notification.additionalData['status'];
    }
    date = notification.additionalData['date'];
  } */
  @override
  Widget build(BuildContext context) {
    final personal = Provider.of<UserProvider>(context);
    final auth = Provider.of<AuthBase>(context, listen: false);
    final discussion = Provider.of<DiscussionProvider>(context);
    final event = Provider.of<EventProvider>(context);
    print(date);
    
    return StreamBuilder<List<RegUser>>(
        stream: personal.users,
        builder: (context, snp) {
          if (!snp.hasData) {
            return Indicator();
          }

          var person = Auth().currentUser;
          var data = snp?.data
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
                              return FloatingActionButton(
                                  child: Icon(
                                    Icons.chat,
                                    color: Color.fromRGBO(48, 48, 48, 1),
                                    size: 32,
                                  ),
                                  backgroundColor:
                                      Color.fromRGBO(240, 230, 140, 1),
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
                              delay: Duration(milliseconds: 2000),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                padding: EdgeInsets.only(
                                    bottom: 10, left: 5, top: 5),
                                decoration: BoxDecoration(
                                    border: (data.single.specialty == null ||
                                                data.single.specialty.length <
                                                    3) ||
                                            collName != null ||
                                            widget.payload != null
                                        ? Border.all(
                                            color:
                                                Color.fromRGBO(94, 94, 94, 1))
                                        : null,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    data.single.specialty == null ||
                                            data.single.specialty.length < 3
                                        ? ListTile(
                                            visualDensity:
                                                VisualDensity(vertical: -4),
                                            minVerticalPadding: 0.0,
                                            leading: Icon(
                                              CupertinoIcons.profile_circled,
                                              size: 20,
                                              color: Colors.yellow.shade100,
                                            ),
                                            title: Text(
                                              'Please complete your profile ',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.yellow.shade100,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    showEventNotif()
                                        ? ListTile(
                                            visualDensity:
                                                VisualDensity(vertical: -4),
                                            minVerticalPadding: 0.0,
                                            leading: Icon(
                                              CupertinoIcons
                                                  .calendar_badge_plus,
                                              size: 20,
                                              color: Colors.yellow.shade100,
                                            ),
                                            title: Text(
                                              '$messageTitle - $messageContent',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.yellow.shade100,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    collName != null
                                        ? ListTile(
                                            visualDensity:
                                                VisualDensity(vertical: -4),
                                            minVerticalPadding: 0.0,
                                            leading: Icon(
                                              CupertinoIcons.group,
                                              size: 20,
                                              color: Colors.yellow.shade100,
                                            ),
                                            title: Text(
                                              'You have colleague request from  $messageContent, add him/her too to your colleague list as well ',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.yellow.shade100,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ) /*: Container()*/
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
                                        if (collName != null) {
                                          setState(() {
                                            reqName = snp.data
                                                .firstWhere((element) =>
                                                    element.uid == collName)
                                                .displayName;
                                          });
                                        }
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => Colleague(
                                                      regUser: data.single,
                                                      reqName: reqName,
                                                    )));
                                        setState(() {
                                          collName = null;
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
                                                  ? Badge(
                                                      badgeContent: Icon(
                                                        CupertinoIcons.bell,
                                                        color: Color.fromRGBO(
                                                            60, 60, 60, 1),
                                                      ),
                                                      badgeColor:
                                                          Color.fromRGBO(240,
                                                              230, 140, 0.9),
                                                    )
                                                  : Container()),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Material(
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      onTap: () async {
                                        await Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          if (date != null && time != null) {
                                            return Home(
                                              selDate: DateTime.parse(date),
                                              iniTime: int.parse(time),
                                            );
                                          }
                                          return Home();
                                        }));

                                        setState(() {
                                          messageTitle = null;
                                          date = null;
                                          time = null;
                                        });

                                        //messageTitle = null;
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
                                              child: showEventNotif()
                                                  ? Badge(
                                                      badgeContent: Icon(
                                                        CupertinoIcons.bell,
                                                        color: Color.fromRGBO(
                                                            60, 60, 60, 1),
                                                      ),
                                                      badgeColor:
                                                          Color.fromRGBO(240,
                                                              230, 140, 0.9))
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
                      (youGotMessage == true &&
                          messageId != null) ? Bubble(
                        margin: BubbleEdges.only(bottom: 18, right: 70),
                        padding: BubbleEdges.all(10),
                        borderColor: Colors.yellow.shade100,
                        nipOffset: 10,
                        alignment: Alignment.centerRight,
                        nipWidth: 40,
                        nipHeight: 10,
                        nip: BubbleNip.rightTop,
                        color: Colors.transparent,
                        child: Text('You got message!',
                            style: TextStyle(
                                color: Color.fromRGBO(198, 198, 198, 1)),
                            textAlign: TextAlign.right),
                      ) : Container()
                    ],
                  ),
                );
              });
        });
  }

  bool showEventNotif() {
    return messageTitle != null &&
        (messageTitle.contains('invites') ||
            messageTitle.contains('rescheduled') ||
            messageTitle.contains('canceled'));
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
