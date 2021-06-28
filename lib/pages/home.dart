import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:jadwalku/model/discussion.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/pages/discuss_page.dart';
import 'package:jadwalku/pages/form.dart';
import 'package:jadwalku/pages/profile.dart';
import 'package:jadwalku/provider/discussion_provider.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/admob.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/legend_bar.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';


class Home extends StatefulWidget {
  final String title;
  final DateTime selDate;
  const Home({Key key, this.title, this.selDate}) : super(key: key);


  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RegUser user;

  int count = 0;
  int time = 6;
  String messageId;
  bool youGotMessage = false;
  String collName;
  String _status;



  List<int> bookTimeOT = [];



  String oTRoom ;
  DateTime _selectedDay /*= DateTime.now()*/;
  CalendarController _calendarController = CalendarController();
  WeekViewController _weekViewController = WeekViewController();
  DayViewController _dayViewController = DayViewController();

  Map<DateTime, List<Events>> _groupedEvents;
  String deviceToken;


  final ads = AdMobService();

  @override
  void initState()  {


    checkDoc();

    _selectedDay = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day, );
    super.initState();



  }
  @override
  void dispose() {
    _calendarController.dispose();
    _weekViewController.dispose();
    _dayViewController.dispose();
    super.dispose();
  }

  checkDoc () async {
    DocumentSnapshot  ds = await FirebaseFirestore.instance.collection('users/').doc(Auth().currentUser.uid).get();
    if(!ds.exists){
      UserProvider().setUser();
    }
  }

  _groupEvents(List<Events> events) {
    _groupedEvents = {};
    events.forEach((event) {
      DateTime date =
      DateTime.utc(DateTime.parse(event.date).year, DateTime.parse(event.date).month, DateTime.parse(event.date).day, 12);
      if (_groupedEvents[date] == null) _groupedEvents[date] = [];
      _groupedEvents[date].add(event);
    });
  }


  @override
  Widget build(BuildContext context) {
    if(widget.selDate != null){
      _selectedDay = widget.selDate;}
    final event = Provider.of<EventProvider>(context);
    final discussion = Provider.of<DiscussionProvider>(context);
    final person = Provider.of<UserProvider>(context);
    var now = DateTime.now();


    return StreamBuilder<List<Events>>(
      stream: event.events,
      builder: (context, snapshot) {
        if(!snapshot.hasData){return Indicator();}

        final events = snapshot.data.where((element) => element.participants.any((element) => element['id'] == Auth().currentUser.uid)).toList();
        _groupEvents(events);

        return Scaffold(
              appBar: AppBar(
                brightness: Brightness.dark,
                titleSpacing: 0,
                leading: IconButton(icon: Icon(Icons.arrow_back),
                onPressed: ()=> Navigator.pop(context),),
                backgroundColor: Color.fromRGBO(77, 116, 99, 0.9),
                actions: [
                Padding(
                  padding: const EdgeInsets.only(top:2.0),
                  child: LegendBar(),
                ),
                  //SizedBox(width: 5,),
                  SizedBox(width: 25,)
                ],
                automaticallyImplyLeading: false,
                elevation: 0,
                title: Text('My Calendar',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

              ),
              floatingActionButton: (youGotMessage == true && messageId != null) ?
              StreamBuilder<List<Discussion>>(
                stream: discussion.messageList,
                builder: (context, snap) {
                  if (snap.hasData) {
                    return
                    FloatingActionButton(
                        child: Icon(Icons.chat),
                        backgroundColor: Colors.deepOrange,
                        onPressed: () async {
                      await Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>
                          DiscussPage(discussion: snap.data.firstWhere((element) => messageId == element.messageId),
                            event:  snapshot.data.where((element) => element.eventId == messageId).first,))).then((value){
                              setState(() {
                                messageId = value['messageId'];
                                youGotMessage = value['youGotMessage'];
                              });
                      });

                    });
                  }
                  return Indicator();
                }
              )
              :Container(),
              body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableCalendar(
                        rowHeight: 55,
                        calendarStyle: CalendarStyle(
                          cellMargin: EdgeInsets.zero,
                          weekdayStyle: TextStyle(fontSize: 15),
                          weekendStyle: TextStyle(fontSize: 15, color: Colors.red),
                          holidayStyle: TextStyle(fontSize: 15, color: Colors.red)
                        ),
                        events: _groupedEvents,

                        headerStyle: HeaderStyle(
                          titleTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black87,),
                          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black87,),
                            formatButtonShowsNext: false,
                          formatButtonTextStyle: TextStyle(color: Colors.black87, fontSize: 13),
                          formatButtonDecoration: BoxDecoration( color: Colors.white10,borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black87)),
                          formatButtonPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            headerPadding: EdgeInsets.zero),
                        calendarController: _calendarController,
                      initialCalendarFormat: CalendarFormat.twoWeeks,
                        weekendDays: [DateTime.sunday],
                        onDaySelected: (DateTime day,_,__){

                          var list = snapshot.data.where((element) => DateTime.parse(element.date).isAtSameMomentAs( DateTime(day.year, day.month, day.day)) && element.participants.any((element) => element['id'] == Auth().currentUser.uid)).map((e) => e.startHour).toList();
                          list.sort();
                          bookTimeOT.clear();
                          setState(() {
                            _calendarController.setSelectedDay(day);
                            _selectedDay =  DateTime(day.year, day.month, day.day);
                            if(list.isNotEmpty){
                              time = list[0];
                            }else{
                              time = 6;}
                            //time = 6;
                          });
                        },

                        initialSelectedDay: DateTime.now(),
                        builders: CalendarBuilders(
                          selectedDayBuilder: (context, date, events) => Container(
                              margin: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.teal.shade400,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(color: Colors.white,),
                              )),
                          todayDayBuilder: (context, date, events) => Container(
                              margin: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.teal.shade100.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                              border: Border.all()),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
                              )),
                          markersBuilder: (_, date, _groupedEvents , __) {
                            return [
                              Positioned(
                                top: -1,
                                right: 0,
                                child: Container(
                                    constraints: BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,),
                                    padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                     // borderRadius: BorderRadius.circular(7),
                                  color: Colors.deepOrangeAccent),

                                    child: Text('${_groupedEvents.length}', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)),
                              )
                            ] ;
                          },
                        ),
                      ),
                      SizedBox(height: 2,),
                      Container(
                        child: Center(
                          child: AdmobBanner(
                              adUnitId: ads.getBannerAdId(),
                              adSize: AdmobBannerSize.BANNER),
                        ),
                      ),
                      SizedBox(height: 5,),
                      //AD was Here

                      Expanded(
                        child: Stack(
                          children: [
                            buildDayView( snapshot, context,
                              now, Colors.teal.shade200.withOpacity(0.4), Colors.teal.shade200.withOpacity(0.6), Colors.black54, 60),
                            collName != null ? Positioned(
                              bottom: 20,
                              right: 20,


                              child: StreamBuilder<List<RegUser>>(
                                stream: person.users,
                                builder: (context, snp) {
                                  if(snp.hasData){
                                    var sender = snp.data.where((element) => element.uid == collName).first;

                                    return Container(
                                        width: 250,
                                        child:Column(
                                            children:[Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                              child: person.colleagues.map((e) => e['collId']).toList().contains(collName) ?
                                              Text('${sender.displayName} added you as colleague', style: TextStyle(color: Colors.white), overflow: TextOverflow.clip,maxLines: 2,):
                                              Text('Request from ${sender.displayName} to be your colleague' , style: TextStyle(color: Colors.white), overflow: TextOverflow.clip,maxLines: 2,),
                                            ),
                                              TextButton(
                                                child: Text('OK', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w600)),
                                                onPressed: ()async{


                                                  await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                                                      ProfilePage(3, collName, _status))).then((value){
                                                    setState(() {
                                                      collName = null;
                                                    });
                                                  });
                                                  }
                                              )
                                            ]
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.indigo.shade300.withOpacity(0.8))
                                    );
                                  }
                                 return Indicator();

                                }
                              ),

                              ) : Container(),]
                        ),
                      ),
                      //SizedBox(height: 10,),

                    ],
              ),
            );
          }


    );
  }


  WeekView buildDayView(AsyncSnapshot<List<Events>> snapshot,
      BuildContext context, DateTime now, Color color1, Color color2, Color textColor,double columnWidth) {
    DateTime date = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var todayEvent = snapshot.data.where((element) => DateTime.parse(element.date).isAtSameMomentAs(DateTime(now.year, now.month, now.day)) && element.participants.any((element) => element['id'] == Auth().currentUser.uid)).map((e) => e.startHour).toList();
    todayEvent.sort();
    getBookedTime(snapshot, date);
        return
      WeekView.builder(dateCreator: (index) => _selectedDay.add(Duration(days: index)),

        scrollToCurrentTime: false,
        dayViewStyleBuilder: (day) => DayViewStyle(
            backgroundColor: day == _selectedDay ? Colors.tealAccent.shade100.withOpacity(0.1) : Colors.grey.shade100,
            currentTimeCircleRadius: 5,
            currentTimeCirclePosition: CurrentTimeCirclePosition.left,
            currentTimeCircleColor: Colors.pink),
        style: WeekViewStyle(
          dayViewWidth: MediaQuery.of(context).size.width*0.68,
          dayViewSeparatorWidth: 0.8, ),
        initialTime: _selectedDay.isAtSameMomentAs(now)  && todayEvent.isNotEmpty ? HourMinute(hour: todayEvent[0]).atDate(now) : HourMinute(hour: time - 1).atDate(_selectedDay),
        onDayBarTappedDown: (day) {
        bookTimeOT.clear();

          var list = snapshot.data.where((element) => DateTime.parse(element.date).isAtSameMomentAs(day) && element.participants.any((element) => element['id'] == Auth().currentUser.uid)).map((e) => e.startHour).toList();
          list.sort();
          setState(() {

            _calendarController.setSelectedDay(day);
            _selectedDay = day;
            if(list.isNotEmpty){
              time = list[0];
            }else{
              time = 6;}
          });
        },

        dayBarStyleBuilder: (tgl) => DayBarStyle(
          decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade400.withOpacity(0.8), width: 0.5), horizontal: BorderSide.none),color:  Colors.grey.shade200.withOpacity(0.9),),
          textStyle: TextStyle(fontWeight: tgl == _selectedDay ? FontWeight.w600 : null, color: tgl == _selectedDay ? Colors.teal.shade800 : null, fontSize: tgl == today ? 15: 12),

            textAlignment: tgl != _selectedDay? Alignment.centerLeft : Alignment.center,
            dateFormatter: tgl != today ? (day, month,year) {return formatDate(tgl, ['dd','  ', 'M','  ', 'yyyy']);}
            :  (day, month,year) => 'TODAY'
        ),
        inScrollableWidget: true,
        hoursColumnTimeBuilder: (style, hour) {
        if(!date.add(Duration(hours: hour.hour)).isBefore(DateTime.now()) && !bookTimeOT.contains(hour.hour)) {
          return Padding(
            padding: const EdgeInsets.only(top:10.0, bottom: 0),
            child: Material(
              child: InkWell(
                splashColor: Colors.blueGrey.shade200,
                onTap: () async {

                  await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EventForm(date: _selectedDay, hour: hour.hour,)))
                      .then((selectedTime) {
                    bookTimeOT.clear();

                    if (selectedTime != null) {
                      setState(() {
                        DateTime day = selectedTime['date'];
                        _calendarController.setSelectedDay( DateTime(day.year, day.month, day.day));
                        _selectedDay =  DateTime(day.year, day.month, day.day);
                        time = selectedTime['time'][0];
                        getBookedTime(snapshot,  DateTime(day.year, day.month, day.day));
                      });
                    }});
                },
                child: Container(
                    decoration:
                    BoxDecoration(
                        border: Border.all(color: Colors.teal, width: 0.5),
                        color: Colors.lightBlue.shade100.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:5.0),
                          child: Text(hour.hour >= 10 ? '${hour.hour}:00': '0${hour.hour}:00',
                            style: TextStyle(color: Colors.teal),),
                        ),
                        //SizedBox(height: 4,),
                        Padding(
                          padding: const EdgeInsets.only(bottom:4.0),
                          child: Icon(Icons.add_sharp, color: Colors.teal, size: 20,),
                        ),
                      ],
                    )),
              ),
            ),
          );
        }
        return
          Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text(hour.hour >= 10 ? '${hour.hour}:00': '0${hour.hour}:00', style: TextStyle(color: Colors.black87.withOpacity(0.4)),),
            );
        },


        userZoomable: false,
        dateCount: 3,
        events:
        snapshot.hasData ? snapshot.data.where((element) => element.participants.any((element) => element['id'] == Auth().currentUser.uid)).map((e) =>
        new FlutterWeekViewEvent(
            onTap:() async {
              bookTimeOT.clear();
              getBookedTime(snapshot, date);
               await Navigator.push(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true, builder: (context) => EventForm(event: e, date: _selectedDay)),
              ).then((selectedTime) {
                 bookTimeOT.clear();

                if (selectedTime != null) {
                  setState(() {
                  DateTime day = selectedTime['date'];
                  _calendarController.setSelectedDay( DateTime(day.year, day.month, day.day));
                  _selectedDay =  DateTime(day.year, day.month, day.day);
                  time = selectedTime['time'][0];
                  getBookedTime(snapshot,  DateTime(day.year, day.month, day.day));
                  });
                }
              });
               setState(() {

               });
              // getBookedTime(snapshot, date);
            } ,
            textStyle: TextStyle(color: e.isDone == true ? Colors.black54 : Colors.black),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color:e.isDone == true ? Colors.brown.shade300.withOpacity(0.4) :  e.creatorId != Auth().currentUser.uid ? Colors.amberAccent.shade100.withOpacity(0.6) : e.hashCode.isEven  ? color1 : color2 ,),
            margin: EdgeInsets.only(top: 3, left: 3, right: 3, bottom: 5),
            title: e.procedure,
            description: '${e.diagnose}\n${e.place}',
            start: DateTime.parse(e.date).add(
                Duration(
                    hours: e.startHour)),
            end: DateTime.parse(e.date).add(
                Duration(
                    hours: e.endHour))
        )
        ).toList() : [],
      );


  }

  void getBookedTime(AsyncSnapshot<List<Events>> snapshot, DateTime date) {
    var events = snapshot.data.where((element) => element.participants.any((element) => element['id'] == Auth().currentUser.uid)).map((e) => e);
    var eventsOfDay = events.where((element) => DateTime.parse(element.date).isAtSameMomentAs(date)).toList();
    bookTimeOT.clear();
    for (var i in eventsOfDay.map((e) => e)){
      for(var x in i.bookTime){
        bookTimeOT.add(x);
      }
      bookTimeOT = bookTimeOT.toSet().toList();
    }
  }
  Future sendMessage(playerId, messageTitle, messageBody, id, status) async {
    DateTime now = DateTime.now();
    await OneSignal.shared.postNotification(OSCreateNotification(
        playerIds: [playerId],
        collapseId: DateTime(now.year, now.month, now.day).toString(),
        content: messageBody,
        heading: messageTitle,
        sendAfter: DateTime.now().add(Duration(seconds: 10)).toUtc(),
        additionalData: {'name':  id, 'status': status},
        androidSmallIcon: 'ic_launcher',
        androidLargeIcon: 'ic_launcher_round'
    ));
  }

}
