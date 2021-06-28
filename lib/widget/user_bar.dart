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
                  Flexible(
                    flex: 5,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [Text(personal.displayName.length > 15 ? personal.displayName.substring(0, personal.displayName.lastIndexOf(' '))
                        : personal.displayName, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),),
                    Transform.translate(
                        offset: Offset(0, -1),
                        child: Text(personal.email, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w400),)),]
                ),
                  ),
                 SizedBox(width: 10,),
                 CircleAvatar(backgroundImage: NetworkImage(personal.photoUrl), radius: 18,),

               ],
              )

          );
          }
        return CircularProgressIndicator();

      }
    );
  }
}
