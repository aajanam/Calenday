import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:getwidget/getwidget.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/pages/form.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';



class UnfinishedTab extends StatelessWidget {
  UnfinishedTab({
    Key key,
    @required this.event,
  }) : super(key: key);

  final EventProvider event;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<Events>>(
        stream: event.events,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var total = snapshot.data.where((element) => element.participants.any((e) => e['id'] == Auth().currentUser.uid &&
                element.isDone == false))
                .length;
            var pink = snapshot.data.where((element) => element.participants.any((e) => e['id'] == Auth().currentUser.uid &&
                element.isDone == false &&
                element.creatorId == Auth().currentUser.uid))
                .length;
            return Column(
              children: [
                Container(
                  //color: Colors.blue.shade400,
                  height: 45,
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text('Total :', style: TextStyle(fontSize: 12, color: Colors.black54),),
                          SizedBox(width: 6,),
                          Container(
                              constraints: BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,),
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(

                                shape: BoxShape.circle,
                                color: Colors.teal.shade700,
                              ),
                              child: Text('$total', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),))
                        ],
                      ),
                      SizedBox(width: 8,),
                      Row(
                        children: [
                          Text('Yours :', style: TextStyle(fontSize: 12, color: Colors.black54),),
                          SizedBox(width: 6,),
                          Container(
                              constraints: BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,),
                              padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(

                              shape: BoxShape.circle,
                              color: Colors.teal.shade300,
                            ),
                              child: Text('$pink', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),))
                        ],
                      ),
                      SizedBox(width: 8,),
                      Row(
                        children: [
                          Text('Shared :', style: TextStyle(fontSize: 12, color: Colors.black54),),
                          SizedBox(width: 6,),
                          Container(
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,),
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(

                              shape: BoxShape.circle,
                              color: Colors.amber,
                            ),
                            child: Text('${total - pink}', style: TextStyle(
                                fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold,),),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thickness: 5,
                    child: ListView.builder(
                      //physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot?.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          var myJadwal = snapshot.data[index].participants.map((e) => e['id']).contains(Auth().currentUser.uid);
                          var isWaiting = !snapshot.data[index].isDone;
                          var planDate = DateTime.parse(
                              snapshot.data[index].date);
                          var date = DateTime.parse(snapshot.data[index].date);
                          var appDate = DateTime(
                              date.year, date.month, date.day);
                          var now = DateTime.now();
                          var today = DateTime(now.year, now.month, now.day);
                          var tomorrow = DateTime(
                              now.year, now.month, now.day + 1);
                          if (myJadwal && isWaiting) {
                            /*if (appDate == today && index != 0){
                            notificationPlugin.showNotification(index, 'Today', '${snapshot.data[index].subTitle} at ${snapshot.data[index].place}');}*/

                            return GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EventForm(
                                              event: snapshot
                                                  .data[index],
                                              date: date,)));
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8))),
                                child: ClipPath(
                                  clipper: ShapeBorderClipper(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8))
                                      )
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border(left: BorderSide(width: 13, color:
                                        snapshot.data[index].creatorId == Auth().currentUser.uid ? Colors.teal.shade300 : Colors.amberAccent)),),
                                    child: Column(
                                        children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .start,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          children: [
                                            SizedBox(
                                              width: 25,
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child:
                                              appDate == today && snapshot.data[index].startHour < 10 ? Text('Today - 0${snapshot.data[index].startHour}:00', style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.bold))
                                                  : appDate == today && snapshot.data[index].startHour >10 ? Text('Today - ${snapshot.data[index].startHour}:00', style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.bold))
                                              : appDate == tomorrow &&  snapshot.data[index].startHour < 10 ? Text('Tomorrow - 0${snapshot.data[index].startHour}:00', style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.bold))
                                              : appDate == tomorrow && snapshot.data[index].startHour > 10 ? Text('Tomorrow - ${snapshot.data[index].startHour}:00', style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.bold)) :
                                              Text(snapshot.data[index].startHour < 10 ?
                                                formatDate(DateTime.parse(snapshot.data[index].date), [d, ' ', M, ' ', yyyy, ' - 0${snapshot.data[index].startHour}:00']) :
                                                formatDate(DateTime.parse(snapshot.data[index].date), [d, ' ', M, ' ', yyyy, ' - ${snapshot.data[index].startHour}:00']),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                    (planDate.isAfter(
                                                        DateTime.now()) &&
                                                        isWaiting)
                                                        ? Colors.green.shade700
                                                        : (planDate.isBefore(
                                                        DateTime.now()) &&
                                                        isWaiting)
                                                        ? Colors.blueGrey
                                                        : Colors.grey.shade400),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GFListTile(
                                        padding: EdgeInsets.only(
                                            left: 15, bottom: 1),
                                        margin: EdgeInsets.zero,
                                        enabled: isWaiting ? true : false,

                                        title: Text(
                                          snapshot.data[index].procedure,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Transform.translate(
                                          offset: Offset(0,-5),
                                          child: Text(
                                            snapshot.data[index].diagnose,
                                            style: TextStyle(
                                              fontSize: 13,
                                            ),overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                        description: Transform.translate(
                                          offset: Offset(0,-8),
                                          child: Text(
                                            snapshot.data[index].place,
                                            style: TextStyle(
                                              fontSize: 12,
                                            ), overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                        icon: IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EventForm(
                                                          event: snapshot
                                                              .data[index],
                                                          date: date,)));
                                          },
                                          icon: Icon(
                                            Icons.keyboard_arrow_right,
                                            color: Colors.indigo.shade400,
                                          ),
                                        ),
                                      ),

                                    ]),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ),
                ),
              ],
            );
          }
            return Indicator();
        });
  }

}
