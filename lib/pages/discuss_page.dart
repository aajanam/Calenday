import 'package:admob_flutter/admob_flutter.dart';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jadwalku/model/discussion.dart';
import 'package:jadwalku/model/events.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/provider/discussion_provider.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/services/admob.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class DiscussPage extends StatefulWidget {
  DiscussPage({
    this.event,
    this.discussion,
    this.eventId
  });

  final Events event;
  final Discussion discussion;
  final String eventId;


  @override
  _DiscussPageState createState() => _DiscussPageState();


}

class _DiscussPageState extends State<DiscussPage> {

  String messageText = '';
  final ads = AdMobService();
  TextEditingController _messageController = TextEditingController();


 @override
  void initState() {
   if(widget.eventId != null){
     checkDoc();
   }

   final discussionProvider = Provider.of<DiscussionProvider>(context, listen: false);
   if(widget.discussion != null){
     discussionProvider.loadAll(widget.discussion);
   }

   discussionProvider.loadAll(null);
    // TODO: implement initState
    super.initState();
  }

  checkDoc () async {
    final discussionProvider = Provider.of<DiscussionProvider>(context, listen: false);
    DocumentSnapshot  ds = await FirebaseFirestore.instance.collection('messages/').doc(widget.eventId).get();
    if(ds.exists){
      discussionProvider.loadAll(widget.discussion);
    }
  }

  @override
  Widget build(BuildContext context) {
   final discussionProvider = Provider.of<DiscussionProvider>(context);
   final person = Provider.of<UserProvider>(context);
   DateTime now = DateTime.now();
   DateTime today = DateTime(now.year, now.month, now.day);
   DateTime yesterday = today.subtract(Duration(days: 1));
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context, {'messageId':null, 'youGotMesssage':false});
        },),
        automaticallyImplyLeading: false,
        elevation: 0,
        brightness: Brightness.dark,
        title: Text('Discussion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
        titleSpacing: 0,
      ),

      //backgroundColor: Colors.teal.shade100.withOpacity(0.9),
      body: Container(
        color:Colors. lightBlue.shade100.withOpacity(0.1),
        child: Column(

          children: [
            SizedBox(height: 5,),
            Container(
              color:Colors. lightBlue.shade100.withOpacity(0.1),
              child: Center(
                child: AdmobBanner(
                    adUnitId: ads.getBannerAdId(),
                    adSize: AdmobBannerSize.BANNER),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color:Colors. teal.shade100.withOpacity(0.1),
                border: Border.all(width: 1, color: Colors.teal),
                borderRadius: BorderRadius.circular(10)
              ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical:8.0, horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Topic:', style: TextStyle(fontSize: 14,),),
                  SizedBox(width: 10,),
                  Expanded(child: Text('${widget.event.procedure}  -  ${widget.event.diagnose}',
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600 ),overflow: TextOverflow.ellipsis, maxLines: 2,),
                  )],
              ),
            ),),

            Expanded(
                child: StreamBuilder<List<Discussion>>(
                  stream: discussionProvider.messageList,
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      var messageData = snapshot.data;
                      for(var i in messageData.where((element) => element.messageId == widget.event.eventId)){
                       return StreamBuilder<List<RegUser>>(
                         stream: person.users,
                         builder: (context, snap) {
                           return ListView.builder(
                             reverse: true,
                             padding: MediaQuery.of(context).viewInsets,
                               itemCount: i?.message?.length ?? 0,
                               itemBuilder: (context, index){
                               index = (index + 1  - i.message.length).abs();
                                 var personData = snap.data;
                                 if(!snap.hasData){
                                   return Indicator();
                                 }
                                 DateTime chatDate = i.message[index]['timestamp'].toDate();
                                 DateTime chatDay = DateTime(chatDate.year, chatDate.month, chatDate.day);

                                 return Column(
                                   children: [
                                    /* index == 0 ||*/ !(index > 0 && DateTime((i.message[index-1]['timestamp'].toDate()).year, (i.message[index-1]['timestamp'].toDate()).month, (i.message[index-1]['timestamp'].toDate()).day).isAtSameMomentAs(chatDay))?
                                     Bubble(
                                       margin: BubbleEdges.only(bottom: 20, left: 10, right: 10, top: 10),

                                       padding: BubbleEdges.symmetric(vertical: 0),
                                       alignment: Alignment.center,
                                       color: Colors.lightBlue.shade100,
                                       child: chatDay == today? Text('Today', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)):
                                       chatDay == yesterday ? Text('Yesterday', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)) :
                                       Text(formatDate(chatDate, [d,' ',M,' ',yy]), textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
                                       ) : Container(),

                                     Bubble(
                                       margin: BubbleEdges.only(bottom: 15, left: 10, right: 10, top: 2),
                                       alignment: i.message[index]['sentBy'] == Auth().currentUser.uid ? Alignment.topRight : Alignment.topLeft,
                                       color: i.message[index]['sentBy'] == Auth().currentUser.uid ? Color.fromARGB(255, 225, 255, 220)/*.withOpacity(0.2)*/ : Colors.white,
                                       nip: i.message[index]['sentBy'] == Auth().currentUser.uid ? BubbleNip.rightTop : BubbleNip.leftTop,
                                       nipWidth: 5,
                                       nipOffset: 0,
                                       nipHeight: 10,
                                       elevation: 3,
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         //mainAxisSize: MainAxisSize.min,
                                         children: [
                                           Container(
                                             child: Row(
                                               mainAxisSize: MainAxisSize.min,
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                                 Text(personData.where((element) => element.uid == i.message[index]['sentBy']).first.displayName.substring(0,personData.where((element) => element.uid == i.message[index]['sentBy']).first.displayName?.lastIndexOf(' ')),style: TextStyle(fontSize: 10.0, color: Colors.black87)),
                                                 SizedBox(width:5),
                                                 Text(formatDate(DateTime.parse(i.message[index]['timestamp'].toDate().toIso8601String()),[HH,':',nn])
                                                     ,style: TextStyle(fontSize: 10.0, color: Colors.black87)),
                                               ],
                                             ),
                                           ),
                                           Text(i.message[index]['message'],style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                                         ],
                                       ),
                                     )
                                   ],

                                 );
                               }
                               );
                         }
                       );
                      }

                      return Container();
                    }
                    return Container();
                  },
                )),
            StreamBuilder<List<Discussion>>(
              stream: discussionProvider.messageList,
              builder: (context, snapshot) {
                return StreamBuilder<List<RegUser>>(
                  stream: person.users,
                  builder: (context, snap) {
                    return TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      controller: _messageController,
                      //autofocus: true,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        hintText: 'Write message',
                        isDense: true,
                        suffixIcon: IconButton(icon: Icon(Icons.send_outlined), onPressed: (){
                          var list = [];
                          var value = {
                            'sentBy': Auth().currentUser.uid,
                            'timestamp': Timestamp.now().toDate(),
                            'message': messageText,
                          };
                          if (snapshot.data.where((element) => element.messageId == widget.event.eventId).isNotEmpty){
                            var i = snapshot.data.where((element) => element.messageId == widget.event.eventId).first;
                              setState(() {
                                list = i.message;
                                list.add(value);
                                discussionProvider.changeMessage = list;
                                discussionProvider.changeMessageId = widget.event.eventId;
                              });
                              discussionProvider.saveMessage();
                          }else{
                            setState(() {
                              list.add(value);
                              discussionProvider.changeMessage = list;
                              discussionProvider.changeMessageId = widget.event.eventId;
                            });
                            discussionProvider.saveMessage();
                          }
                          _messageController.clear();
                         for (var p in widget.event.participants.where((element) => element['id'] != Auth().currentUser.uid)){
                           var playId = snap.data.where((element) => element.uid == p['id']).first.deviceToken;
                           //playIds.add(playId);
                           sendMessage(playId, '${Auth().currentUser.displayName} comments on:', '${widget.event.procedure} - ${widget.event.diagnose}', '${widget.event.date}',
                               '${widget.event.eventId}','${widget.event.startHour}');
                         }

                        },),

                        contentPadding: EdgeInsets.only(left: 20, top: 3, bottom: 3 ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyan), borderRadius: BorderRadius.circular(20)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey.shade200,), borderRadius: BorderRadius.circular(20)
                        ),),
                      onChanged: (val){
                       setState(() {
                         setState(() {
                           messageText = val;
                         });
                       });
                      },
                    );
                  }
                );
              }
            ),
          ],

        ),
      ),
    );
  }
  Future sendMessage(playerId, messageTitle, messageBody, collapseId, _chId, time) async {
    await OneSignal.shared.postNotification(OSCreateNotification(
      additionalData: {'time': time,'id': _chId},
        playerIds: [playerId],
        content: messageBody,
        heading: messageTitle,
        collapseId: collapseId,
        sendAfter: DateTime.now().toUtc(),
        androidSmallIcon: 'ic_launcher',
        androidLargeIcon: 'ic_chat',
    ));
  }
}