import 'package:flutter/material.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/widget/user_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Personal extends StatefulWidget {
  final RegUser person;

  const Personal({Key key, this.person}) : super(key: key);

  @override
  _PersonalState createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {

  final _formKey = GlobalKey<FormState>();
  bool enabled = false;
  String deviceToken;


  @override
  void initState(){
    super.initState();
    final person = Provider.of<UserProvider>(context, listen: false);
    if (widget.person != null) {
      //Edit
      person.loadAll(widget.person);
    } else {
      //Add
      person.loadAll(null);
    }
  }
  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ajobsku@gmail.com',
      queryParameters: {
        'subject': 'Customer Support'
      }
  );

  @override
  Widget build(BuildContext context) {
    final person = Provider.of<UserProvider>(context, listen: false);
    return StreamBuilder<List<RegUser>>(
      stream: person.singleUser,
      builder: (context, snapshot) {
        if(snapshot.hasData /*&& snapshot.data.single.uid == Auth().currentUser.uid*/){
          return Scaffold(
            appBar: AppBar(
              brightness: Brightness.dark,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top:2, right: 20.0),
                  child: UserBar(),
                )
              ],
              titleSpacing: 0,
              elevation: 0,
              backgroundColor: Color.fromRGBO(61, 99, 102, 0.8),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(30),
                child: Container(),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 27),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30,),
                      Text('Specialty:', style: TextStyle(color: Colors.black87),),
                      TextFormField(
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        enabled: enabled == false ? false : true,
                        decoration:InputDecoration(
                          isDense: true,
                          hintText: 'Please provide your specialty info',
                          hintStyle: TextStyle(color: Colors.black38),
                          border:enabled? UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)) : InputBorder.none,
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(color: Colors.black54,fontSize: 14),
                        ),
                        initialValue: widget.person.specialty != null ? widget.person.specialty : '',
                        onSaved: (val){

                          person.specialty = val;
                        },
                      ),
                      SizedBox(height: 30,),
                      Text('Work Places:', style: TextStyle(color: Colors.black87)),
                      TextFormField(
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        enabled: enabled == false ? false : true,
                        decoration:InputDecoration(
                            hintText: 'Please provide your first work place info',
                            hintStyle: TextStyle(color: Colors.black38),
                          border:enabled? UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)) : InputBorder.none,
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(color: Colors.black54,fontSize: 14),
                            icon: Text('1.', style: TextStyle(color: Colors.black87))
                        ),
                        initialValue: widget.person.workPlace1,
                        onSaved: (val){
                         person.workPlace1 = val;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        enabled: enabled == false ? false : true,
                        decoration:InputDecoration(
                            hintText: '(Optional) provide your second work place)',
                            hintStyle: TextStyle(color: Colors.black38),
                            border:enabled? UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)) : InputBorder.none,
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(color: Colors.black54,fontSize: 14),
                          icon: Text('2.', style: TextStyle(color: Colors.black87))
                        ),
                        initialValue: widget.person.workPlace2,
                        onSaved: (val){
                          person.workPlace2 = val;
                        },
                        textInputAction: TextInputAction.next,
                      ),TextFormField(
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        enabled: enabled == false ? false : true,
                        decoration:InputDecoration(
                            hintText: '(Optional) provide your third work place',
                            hintStyle: TextStyle(color: Colors.black38),
                            border:enabled? UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)) : InputBorder.none,
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(color: Colors.black54,fontSize: 14),
                            icon: Text('3.', style: TextStyle(color: Colors.black87))
                        ),
                        initialValue: widget.person.workPlace3,
                        onSaved: (val){
                          person.workPlace3 = val;
                        },
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 30,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(onPressed:  () =>
                              launch(_emailLaunchUri.toString()),
                              icon: Icon(Icons.mail_outline, color: Colors.cyan.shade700, size: 36,), label: Text('Mail to admin', style: TextStyle(color: Colors.cyan.shade600),)),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: enabled == false ? Colors.amber : Colors.teal,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30.0),)),
                              onPressed: enabled == true ? (){
                                _formKey.currentState.save();
                                setState(() {
                                  person.getPlayerId().whenComplete(() => person.deviceToken = deviceToken);

                                });
                                person.setUser();
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  enabled = false;
                                });
                              } : () {
                                setState(() {
                                  enabled = true;
                                });
                              },
                              child: enabled == false ? Text('Edit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),) :
                              Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),)
                        ],
                      ),
                    ],
                  ),
                )
              ),
            ),
          );
        }
        return Container();
      }
    );
  }
}
