import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/pages/colleague.dart';
import 'package:jadwalku/pages/complete_tab.dart';
import 'package:jadwalku/pages/landing_page.dart';
import 'package:jadwalku/pages/personal.dart';
import 'package:jadwalku/pages/unfinished_tab.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:jadwalku/widget/show_alert_dialogue.dart';
import 'package:jadwalku/widget/user_bar.dart';
import 'package:provider/provider.dart';




class ProfilePage extends StatelessWidget {
  final int selectedPage;
  final String iD;
  final String status;
  ProfilePage(this.selectedPage, this.iD, this.status);

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
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
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> LandingPage()));
    }
  }



  @override
  Widget build(BuildContext context) {
    final event = Provider.of<EventProvider>(context);
    final auth = Provider.of<AuthBase>(context, listen: false);
    final personal = Provider.of<UserProvider>(context);
    return DefaultTabController(
        length: 4,
        initialIndex: selectedPage,
        child: WillPopScope(
          onWillPop: () async => true,
          child: StreamBuilder<List<RegUser>>(
            stream: personal.users,
            builder: (context, snapshot) {
              if (snapshot.hasData) {var data = snapshot.data.where((element) => element.uid == auth.currentUser.uid);
              return StreamBuilder<List<Events>>(
                  stream: event.events,
                builder: (context, snp) {
                  var countUnfinished = snp?.data?.where((element) => element.isDone == false && element.participants.any((e) => e['id'] == Auth().currentUser.uid))?.length ?? 0;
                  var countCompleted = snp?.data?.where((element) => element.isDone == true && element.participants.any((e) => e['id'] == Auth().currentUser.uid))?.length ?? 0;
                  return Scaffold(
                    appBar: AppBar(
                      brightness: Brightness.dark,
                      iconTheme: IconThemeData(color: Colors.white),
                      titleSpacing: 0,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.cyanAccent.shade700,
                      elevation: 0,
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: UserBar(color: Colors.white,),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.logout_outlined), iconSize: 28,
                          onPressed: () => _confirmSignOut(context),),
                        SizedBox(width: 10,)
                      ],
                      bottom:PreferredSize(
                        preferredSize: Size.fromHeight(80),
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.cyanAccent.shade700,
                                    Colors.cyan.shade600
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter
                              )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             /* Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 22,),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_outline,color: Colors.lime.shade200,),
                                          SizedBox(width:15),
                                          Text('Completed', style: TextStyle(color: Colors.white,fontSize: 14)),
                                          SizedBox(width:10),
                                          StreamBuilder<List<Events>>(
                                              stream: event.events,
                                              builder: (context, snapshot) {
                                                var count = snapshot?.data?.where((element) => element.isDone == true && element.participants.any((e) => e['id'] == Auth().currentUser.uid))?.length ?? 0;
                                                return Container(
                                                  width: 90,
                                                    child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 14,),textAlign: TextAlign.start));
                                              }
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Row(

                                        children: [
                                          Icon(Icons.work_outline, color: Colors.amber.shade300,),
                                          SizedBox(width:15),
                                          Text('Unfinished',style: TextStyle(color: Colors.white, fontSize: 14)),
                                          SizedBox(width:10),
                                          StreamBuilder<List<Events>>(
                                              stream: event.events,
                                              builder: (context, snapshot) {
                                                var count = snapshot?.data?.where((element) => element.isDone == false && element.participants.any((e) => e['id'] == Auth().currentUser.uid))?.length ?? 0;
                                                return Container(
                                                  width: 90,
                                                    child: Text('$count',style: TextStyle(color: Colors.white, fontSize: 14,), textAlign: TextAlign.start,),);
                                              }
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                  // SizedBox(width: 30,),
                                ],
                              ),*/
                              SizedBox(height: 30,),
                              Container(
                                decoration:
                                BoxDecoration(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                                    color: Colors.white),
                                child: TabBar(
                                  indicatorColor: Colors.cyan.shade900,
                                    labelPadding: EdgeInsets.symmetric(horizontal: 5),
                                    labelColor: Colors.cyan.shade900,
                                    indicatorWeight: 3,
                                    unselectedLabelColor: Colors.grey,
                                    labelStyle: TextStyle(fontSize: 12),
                                    tabs: [
                                      Row(
                                        children: [
                                          Tab(text: "Unfinished"),
                                          SizedBox(width: 6,),
                                          Container(
                                              constraints: BoxConstraints(
                                                minWidth: 12,
                                                minHeight: 12,),
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(

                                                shape: BoxShape.circle,
                                                color: Colors.teal.shade800,
                                              ),
                                              child: Text('$countUnfinished', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Tab(text: "Completed"),
                                          SizedBox(width: 6,),
                                          Container(
                                              constraints: BoxConstraints(
                                                minWidth: 12,
                                                minHeight: 12,),
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(

                                                shape: BoxShape.circle,
                                                color: Colors.teal.shade800,
                                              ),
                                              child: Text('$countCompleted', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),))
                                        ],
                                      ),
                                      Tab(text: 'Profile',),
                                      Tab(text: 'Colleagues',)

                                    ]),
                              )
                            ],
                          ),


                        ),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:8.0),
                      child: TabBarView(
                          children: [
                            UnfinishedTab(event: event),
                            CompleteTab(event: event),
                            Personal(person: data.single,),
                            Colleague(regUser: data.single, iD: iD,)

                          ]
                      ),
                    ),
                  );
                }
              );}
             return Indicator();
            }
          ),
        )
    );
  }
}