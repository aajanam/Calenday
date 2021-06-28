import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/pages/form.dart';
import 'package:jadwalku/provider/events_provider.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';


class CompleteTab extends StatelessWidget {
  const CompleteTab({
    Key key,
    @required this.event,
  }) : super(key: key);

  final EventProvider event;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<List<Events>>(
        stream: event.completedEvents,
        builder: (context, snapshot) {
          if(!snapshot.hasData){return Indicator();}

          return Column(

            children: [
              Expanded(
                child: Scrollbar(
                  thickness: 5,
                  child: ListView.builder(
                    //physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                      itemCount: snapshot?.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        var myJadwal = snapshot.data[index].participants.map((e) => e['id']).contains(Auth().currentUser.uid);
                        var date =DateTime.parse(snapshot.data[index].date);
                        var isWaiting = !snapshot.data[index].isDone;
                        return !isWaiting && myJadwal ?
                        GestureDetector(
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
                            margin: EdgeInsets.symmetric(vertical: 3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all( Radius.circular(8))),
                            child:
                            ClipPath(clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8))
                                )),
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(left: BorderSide(width: 13, color: Colors.brown.shade300))),
                                child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(width: 25,),
                                            Expanded(
                                              flex: 8,
                                              child: Text( 'Done on:  ' + formatDate(DateTime.parse(snapshot.data[index].created.toDate().toIso8601String()),[d,' ',M,' ',yyyy,' - ',HH,':',nn]), style:
                                              TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54))),
                                          ],
                                        ),
                                      ),
                                      GFListTile(
                                        enabled: isWaiting ? true : false,
                                        padding: EdgeInsets.only(left: 15, bottom: 1),
                                        margin: EdgeInsets.zero,

                                        //padding: EdgeInsets.zero,
                                        title: Text(snapshot.data[index].procedure, style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600, color: Colors.black54),overflow: TextOverflow.ellipsis),
                                        subtitle: Transform.translate(
                                            offset: Offset(0,-5),
                                            child: Text(snapshot.data[index].diagnose, style: TextStyle(fontSize: 13, color: Colors.black54),overflow: TextOverflow.ellipsis)),
                                        description: Transform.translate(
                                            offset: Offset(0,-8),
                                            child: Text(snapshot.data[index].place, style: TextStyle(fontSize: 12, color: Colors.black54),overflow: TextOverflow.ellipsis)),
                                        icon: IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventForm(event: snapshot.data[index], date: date,)));

                                          },
                                          icon: Icon(
                                            Icons.keyboard_arrow_right,
                                            color: Colors.indigo.shade400,
                                          ),
                                        ),
                                      ),
                                    ]
                                ),
                              ),
                            ),
                          ),
                        ): Container();
                      }),
                ),
              ),
            ],
          );
        });
  }
}
