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




class ProfilePage extends StatelessWidget {
  final int selectedPage;
  final String iD;
  final String status;
  ProfilePage(this.selectedPage, this.iD, this.status);


  @override
  Widget build(BuildContext context) {
    final event = Provider.of<EventProvider>(context);
    final auth = Provider.of<AuthBase>(context, listen: false);
    final personal = Provider.of<UserProvider>(context);
    return DefaultTabController(
        length: 2,
        initialIndex: selectedPage,
        child: WillPopScope(
          onWillPop: () async => true,
          child: StreamBuilder<List<RegUser>>(
            stream: personal.users,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data.where((element) => element.uid == auth.currentUser.uid);
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(icon: Icon(Icons.arrow_back),
                    onPressed: ()=> Navigator.pop(context),),
                  brightness: Brightness.dark,
                  iconTheme: IconThemeData(color: Colors.white),
                  titleSpacing: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Color.fromRGBO(77, 118, 154, 0.9),
                  elevation: 0,
                  title: Text('My Events List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                  ),

                  bottom:PreferredSize(
                    preferredSize: Size.fromHeight(80),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(77, 118, 154, 0.9),
                                Color.fromRGBO(77, 118, 154, 0.9)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter
                          )
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          StreamBuilder<List<Events>>(
                            stream: event.events,
                            builder: (context, snapshot) {
                              if(!snapshot.hasData){return Indicator();}
                              var totalUnfinished = snapshot.data.where((element) => element.participants.any((e) => e['id'] == Auth().currentUser.uid &&
                                  element.isDone == false))
                                  .length;
                              var totalCompleted = snapshot.data.where((element) => element.participants.any((e) => e['id'] == Auth().currentUser.uid &&
                                  element.isDone == true))
                                  .length;
                              return Container(
                                decoration:
                                BoxDecoration(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                                    color: Colors.white),
                                child: TabBar(
                                  indicatorColor: Color.fromRGBO(77, 118, 154, 1),
                                    labelPadding: EdgeInsets.symmetric(horizontal: 5),
                                    labelColor: Color.fromRGBO(77, 118, 154, 1),
                                    indicatorWeight: 2,
                                    unselectedLabelColor: Colors.grey,
                                    labelStyle: TextStyle(fontSize: 14),
                                    tabs: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Tab(text: "Unfinished"),
                                          SizedBox(width: 8,),
                                          Container(
                                              constraints: BoxConstraints(
                                                minWidth: 12,
                                                minHeight: 12,),
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(

                                                shape: BoxShape.circle,
                                                color: Color.fromRGBO(77, 118, 154, 1),
                                              ),
                                              child: Text('$totalUnfinished', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),))
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Tab(text: "Completed"),
                                          SizedBox(width: 8,),
                                          Container(
                                              constraints: BoxConstraints(
                                                minWidth: 12,
                                                minHeight: 12,),
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(

                                                shape: BoxShape.circle,
                                                color: Color.fromRGBO(77, 118, 154, 1),
                                              ),
                                              child: Text('$totalCompleted', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),))
                                        ],
                                      ),


                                    ]),
                              );
                            }
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


                      ]
                  ),
                ),
              );}
             return Indicator();
            }
          ),
        )
    );
  }
}