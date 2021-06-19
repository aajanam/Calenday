import 'package:flutter/material.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:provider/provider.dart';

class UserBar extends StatelessWidget {
  final Color color;
  UserBar({this.color});

  @override
  Widget build(BuildContext context) {
    final person = Provider.of<UserProvider>(context);
    return StreamBuilder<List<RegUser>>(
      stream: person.singleUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var personal = snapshot.data.single;
          return Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 CircleAvatar(backgroundImage: NetworkImage(personal.photoUrl), radius: 18,),
                 SizedBox(width: 10,),
                  Flexible(
                    flex: 5,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [Text(personal.displayName.length > 15 ? personal.displayName.substring(0, personal.displayName.lastIndexOf(' '))
                        : personal.displayName, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600),),
                    Transform.translate(
                        offset: Offset(0, -3),
                        child: Text(personal.specialty != null ? personal.specialty : '', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w400),)),]
                ),
                  ),

                ],
              )

          );
          }
        return CircularProgressIndicator();

      }
    );
  }
}
