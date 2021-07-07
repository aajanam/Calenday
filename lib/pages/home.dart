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

  String oTRoom;
  DateTime _selectedDay/*= DateTime.now()*/;
  CalendarController _calendarController = CalendarController();
  CalendarFormat _format = CalendarFormat.week;
  WeekViewController _weekViewController = WeekViewController();
  DayViewController _dayViewController = DayViewController();

  Map<DateTime, List<Events>> _groupedEvents;
  String deviceToken;

  final ads = AdMobService();

  @override
  void initState() {
    checkDoc();

    _selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _weekViewController.dispose();
    _dayViewController.dispose();
    super.dispose();
  }

  checkDoc() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection('users/')
        .doc(Auth().currentUser.uid)
        .get();
    if (!ds.exists) {
      UserProvider().setUser();
    }
  }

  _groupEvents(List<Events> events) {
    _groupedEvents = {};
    events.forEach((event) {
      DateTime date = DateTime.utc(DateTime.parse(event.date).year,
          DateTime.parse(event.date).month, DateTime.parse(event.date).day, 12);
      if (_groupedEvents[date] == null) _groupedEvents[date] = [];
      _groupedEvents[date].add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selDate != null) {
      _selectedDay = widget.selDate;
    }
    final event = Provider.of<EventProvider>(context);
    final discussion = Provider.of<DiscussionProvider>(context);
    final person = Provider.of<UserProvider>(context);
    var now = DateTime.now();

    return StreamBuilder<List<Events>>(
        stream: event.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Indicator();
          }

          final events = snapshot.data
              .where((element) => element.participants
                  .any((element) => element['id'] == Auth().currentUser.uid))
              .toList();
          _groupEvents(events);

          return Scaffold(
            appBar: AppBar(
              brightness: Brightness.dark,
              titleSpacing: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: Color.fromRGBO(48, 48, 48, 0.9),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: LegendBar(),
                ),
                //SizedBox(width: 5,),
                SizedBox(
                  width: 25,
                )
              ],
              automaticallyImplyLeading: false,
              elevation: 0,
              title: Text('My Calendar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            floatingActionButton: (youGotMessage == true && messageId != null)
                ? StreamBuilder<List<Discussion>>(
                    stream: discussion.messageList,
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return FloatingActionButton(
                            child: Icon(Icons.chat),
                            backgroundColor: Colors.deepOrange,
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DiscussPage(
                                            discussion: snap.data.firstWhere(
                                                (element) =>
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.pinkAccent),
                    weekdayStyle:
                        TextStyle(color: Color.fromRGBO(227, 227, 227, 1)),
                  ),
                  //rowHeight: 55,
                  calendarStyle: CalendarStyle(
                      cellMargin: EdgeInsets.zero,
                      outsideStyle:
                          TextStyle(color: Color.fromRGBO(128, 128, 128, 1)),
                      weekendStyle: TextStyle(color: Colors.pinkAccent),
                      holidayStyle: TextStyle(color: Colors.pinkAccent)),
                  events: _groupedEvents,
                  headerStyle: HeaderStyle(
                      titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontStyle: FontStyle.italic),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),
                      formatButtonShowsNext: false,
                      formatButtonTextStyle: TextStyle(
                          color: Color.fromRGBO(48, 48, 48, 1), fontSize: 13),
                      formatButtonDecoration: BoxDecoration(
                          color: Color.fromRGBO(227, 227, 227, 1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black87)),
                      formatButtonPadding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      headerPadding: EdgeInsets.zero),
                  calendarController: _calendarController,
                  initialCalendarFormat: _format,
                  weekendDays: [DateTime.sunday],
                  onDaySelected: (DateTime day, _, __) {
                    var list = snapshot.data
                        .where((element) =>
                            DateTime.parse(element.date).isAtSameMomentAs(
                                DateTime(day.year, day.month, day.day)) &&
                            element.participants.any((element) =>
                                element['id'] == Auth().currentUser.uid))
                        .map((e) => e.startHour)
                        .toList();
                    list.sort();
                    bookTimeOT.clear();
                    setState(() {
                      _calendarController.setSelectedDay(day);
                      _selectedDay = DateTime(day.year, day.month, day.day);
                      if (list.isNotEmpty) {
                        time = list[0];
                      } else {
                        time = 6;
                      }
                      _calendarController.setCalendarFormat(_format);
                      //time = 6;
                    });
                  },
                  initialSelectedDay: DateTime.now(),
                  builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(7, 227, 227, 1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.indigo.shade100.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white70)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                              color: Color.fromRGBO(227, 227, 227, 1),
                              fontWeight: FontWeight.w600),
                        )),
                    markersBuilder: (_, date, _groupedEvents, __) {
                      return [
                        Positioned(
                          top: -1,
                          right: 0,
                          child: Container(
                              constraints: BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // borderRadius: BorderRadius.circular(7),
                                  color: Colors.deepOrangeAccent),
                              child: Center(
                                child: Text(
                                  '${_groupedEvents.length}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              )),
                        )
                      ];
                    },
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Container(
                    child: Center(
                      child: AdmobBanner(
                          adUnitId: ads.getBannerAdId(),
                          adSize: AdmobBannerSize.BANNER),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                //AD was Here

                Expanded(
                  child: buildDayView(
                      snapshot,
                      context,
                      now,
                      Color.fromRGBO(200, 210, 228, 0.5),
                      Color.fromRGBO(160, 255, 255, 1),
                      Colors.black,
                      Colors.yellow.shade200,
                      60),
                ),
                //SizedBox(height: 10,),
              ],
            ),
          );
        });
  }

  WeekView buildDayView(
      AsyncSnapshot<List<Events>> snapshot,
      BuildContext context,
      DateTime now,
      Color color1,
      Color color2,
      Color textColor,
      Color color3,
      double columnWidth) {
    DateTime date =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var todayEvent = snapshot.data
        .where((element) =>
            DateTime.parse(element.date)
                .isAtSameMomentAs(DateTime(now.year, now.month, now.day)) &&
            element.participants
                .any((element) => element['id'] == Auth().currentUser.uid))
        .map((e) => e.startHour)
        .toList();
    todayEvent.sort();
    getBookedTime(snapshot, date);
    return WeekView.builder(
      dateCreator: (index) => _selectedDay.add(Duration(days: index)),
      scrollToCurrentTime: false,
      dayViewStyleBuilder: (day) => DayViewStyle(
          backgroundColor: day == _selectedDay
              ? Color.fromRGBO(54, 61, 68, 0.8)
              : Color.fromRGBO(54, 61, 68, 0.4),
          currentTimeCircleRadius: 5,
          currentTimeCirclePosition: CurrentTimeCirclePosition.left,
          currentTimeCircleColor: Colors.pink),
      style: WeekViewStyle(
        dayViewWidth: MediaQuery.of(context).size.width * 0.68,
        dayViewSeparatorWidth: 0.8,
      ),
      initialTime: _selectedDay.isAtSameMomentAs(now) && todayEvent.isNotEmpty
          ? HourMinute(hour: todayEvent[0]).atDate(now)
          : HourMinute(hour: time - 1).atDate(_selectedDay),
      onDayBarTappedDown: (day) {
        bookTimeOT.clear();

        var list = snapshot.data
            .where((element) =>
                DateTime.parse(element.date).isAtSameMomentAs(day) &&
                element.participants
                    .any((element) => element['id'] == Auth().currentUser.uid))
            .map((e) => e.startHour)
            .toList();
        list.sort();
        setState(() {
          _calendarController.setSelectedDay(day);
          _selectedDay = day;
          if (list.isNotEmpty) {
            time = list[0];
          } else {
            time = 6;
          }
        });
      },
      dayBarStyleBuilder: (tgl) => DayBarStyle(
          color: tgl == _selectedDay
              ? Color.fromRGBO(61, 102, 98, 1)
              : Color.fromRGBO(69, 101, 127, 1),
          textStyle:
              TextStyle(fontWeight: tgl == today ? FontWeight.w600 : null),
          textAlignment:
              tgl != _selectedDay ? Alignment.centerLeft : Alignment.center,
          dateFormatter: tgl != today
              ? (day, month, year) {
                  return formatDate(tgl, ['  ', 'dd', '  ', 'M', '  ', 'yyyy']);
                }
              : (day, month, year) => '  TODAY'),
      inScrollableWidget: true,
      hoursColumnStyle: HoursColumnStyle(
        decoration: BoxDecoration(color: Color.fromRGBO(51, 61, 68, 0.8)),
      ),
      hoursColumnTimeBuilder: (style, hour) {
        if (!date.add(Duration(hours: hour.hour)).isBefore(DateTime.now()) &&
            !bookTimeOT.contains(hour.hour)) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 0),
            child: Material(
              child: InkWell(
                splashColor: Colors.blueGrey.shade200,
                onTap: () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => EventForm(
                                date: _selectedDay,
                                hour: hour.hour,
                              )))
                      .then((selectedTime) {
                    bookTimeOT.clear();

                    if (selectedTime != null) {
                      setState(() {
                        DateTime day = selectedTime['date'];
                        _calendarController.setSelectedDay(
                            DateTime(day.year, day.month, day.day));
                        _selectedDay = DateTime(day.year, day.month, day.day);
                        time = selectedTime['time'][0];
                        getBookedTime(
                            snapshot, DateTime(day.year, day.month, day.day));
                      });
                    }
                  });
                },
                child: Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.teal.shade300, width: 0.5),
                        color: Colors.teal.shade300.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            hour.hour >= 10
                                ? '${hour.hour}:00'
                                : '0${hour.hour}:00',
                            style: TextStyle(
                                color: Color.fromRGBO(227, 227, 227, 1)),
                          ),
                        ),
                        //SizedBox(height: 4,),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Icon(
                            Icons.add_sharp,
                            color: Color.fromRGBO(227, 227, 227, 1),
                            size: 20,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            hour.hour >= 10 ? '${hour.hour}:00' : '0${hour.hour}:00',
            style: TextStyle(color: Color.fromRGBO(128, 128, 128, 1)),
          ),
        );
      },
      userZoomable: false,
      dateCount: 3,
      events: snapshot.hasData
          ? snapshot.data
              .where((element) => element.participants
                  .any((element) => element['id'] == Auth().currentUser.uid))
              .map((e) => new FlutterWeekViewEvent(
                  onTap: () async {
                    bookTimeOT.clear();
                    getBookedTime(snapshot, date);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) =>
                              EventForm(event: e, date: _selectedDay)),
                    ).then((selectedTime) {
                      bookTimeOT.clear();

                      if (selectedTime != null) {
                        setState(() {
                          DateTime day = selectedTime['date'];
                          _calendarController.setSelectedDay(
                              DateTime(day.year, day.month, day.day));
                          _selectedDay = DateTime(day.year, day.month, day.day);
                          time = selectedTime['time'][0];
                          getBookedTime(
                              snapshot, DateTime(day.year, day.month, day.day));
                        });
                      }
                    });
                    setState(() {});
                    // getBookedTime(snapshot, date);
                  },
                  textStyle: TextStyle(
                      color: e.isDone == false ? textColor : Colors.white70),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: e.isDone == true
                        ? color1
                        : e.creatorId != Auth().currentUser.uid
                            ? color3
                            : color2,
                  ),
                  margin: EdgeInsets.only(top: 3, left: 3, right: 3, bottom: 5),
                  title: e.procedure,
                  description: '${e.diagnose}\n${e.place}',
                  start:
                      DateTime.parse(e.date).add(Duration(hours: e.startHour)),
                  end: DateTime.parse(e.date).add(Duration(hours: e.endHour))))
              .toList()
          : [],
    );
  }

  void getBookedTime(AsyncSnapshot<List<Events>> snapshot, DateTime date) {
    var events = snapshot.data
        .where((element) => element.participants
            .any((element) => element['id'] == Auth().currentUser.uid))
        .map((e) => e);
    var eventsOfDay = events
        .where((element) => DateTime.parse(element.date).isAtSameMomentAs(date))
        .toList();
    bookTimeOT.clear();
    for (var i in eventsOfDay.map((e) => e)) {
      for (var x in i.bookTime) {
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
        additionalData: {'name': id, 'status': status},
        androidSmallIcon: 'ic_launcher',
        androidLargeIcon: 'ic_launcher_round'));
  }
}
