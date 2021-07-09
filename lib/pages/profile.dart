import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/pages/complete_tab.dart';
import 'package:jadwalku/pages/unfinished_tab.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:jadwalku/services/admob.dart';
import 'package:admob_flutter/admob_flutter.dart';

class ProfilePage extends StatefulWidget {
  final selectedPage;
  final String iD;
  final String status;
  ProfilePage(this.selectedPage, this.iD, this.status);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int currentPage;

  final ads = AdMobService();

  @override
  void initState() {
    currentPage = widget.selectedPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = Provider.of<EventProvider>(context);
    final auth = Provider.of<AuthBase>(context, listen: false);
    final personal = Provider.of<UserProvider>(context);
    return DefaultTabController(
        length: 2,
        initialIndex: widget.selectedPage,
        child: WillPopScope(
          onWillPop: () async => true,
          child: StreamBuilder<List<RegUser>>(
              stream: personal.users,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data
                      .where((element) => element.uid == auth.currentUser.uid);
                  return Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      brightness: Brightness.dark,
                      iconTheme: IconThemeData(color: Colors.white),
                      titleSpacing: 0,
                      automaticallyImplyLeading: false,
                      backgroundColor: Color.fromRGBO(48, 48, 48, 1),
                      elevation: 0,
                      title: Text('My Events List',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(120),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(48, 48, 48, 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: AdmobBanner(
                                    adUnitId: ads.getBannerAdId(),
                                    adSize: AdmobBannerSize.BANNER),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              StreamBuilder<List<Events>>(
                                  stream: event.events,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Indicator();
                                    }
                                    var totalUnfinished = snapshot.data
                                        .where((element) => element.participants
                                            .any((e) =>
                                                e['id'] ==
                                                    Auth().currentUser.uid &&
                                                element.isDone == false))
                                        .length;
                                    var totalCompleted = snapshot.data
                                        .where((element) => element.participants
                                            .any((e) =>
                                                e['id'] ==
                                                    Auth().currentUser.uid &&
                                                element.isDone == true))
                                        .length;
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15)),
                                        color: Color.fromRGBO(76, 76, 76, 1),
                                      ),
                                      child: TabBar(
                                          onTap: (tab) {
                                            setState(() {
                                              currentPage = tab;
                                            });
                                          },
                                          indicator: BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    color: Colors.black),
                                                left: BorderSide(
                                                    color: Colors.black),
                                                bottom: BorderSide(
                                                    width: 2,
                                                    color: Colors.cyanAccent)),
                                          ),
                                          labelPadding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          labelColor: Colors.white,
                                          unselectedLabelColor:
                                              Color.fromRGBO(160, 160, 160, 1),
                                          labelStyle: TextStyle(fontSize: 14),
                                          tabs: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Tab(text: "Unfinished"),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Badge(
                                                  badgeContent: Text(
                                                    '$totalUnfinished',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Color.fromRGBO(
                                                            48, 48, 48, 1),
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  badgeColor: currentPage == 0
                                                      ? Colors.white
                                                      : Color.fromRGBO(
                                                          160, 160, 160, 1),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Tab(text: "Completed"),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Badge(
                                                  badgeContent: Text(
                                                    '$totalCompleted',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Color.fromRGBO(
                                                            48, 48, 48, 1),
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  badgeColor: currentPage == 1
                                                      ? Colors.white
                                                      : Color.fromRGBO(
                                                          160, 160, 160, 1),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    );
                                  })
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TabBarView(children: [
                        UnfinishedTab(event: event),
                        CompleteTab(event: event),
                      ]),
                    ),
                  );
                }
                return Indicator();
              }),
        ));
  }
}
