import 'package:flutter/material.dart';

class LegendBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: Colors.teal.shade300,),
                  SizedBox(width: 2,),
                  Text('Yours', style: TextStyle(fontSize: 10,color: Colors.black),)
                ],
              ),
              SizedBox(width: 8,),
              Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: Colors.amberAccent,),
                  SizedBox(width: 2,),
                  Text('Shared', style: TextStyle(fontSize: 10,color: Colors.black),)
                ],
              ),
            ],
          ),
          SizedBox(width: 10,),

          Transform.translate(
            offset: Offset(0, -5),
            child: Row(
              children: [
                CircleAvatar(radius: 6, backgroundColor: Colors.brown.shade300,),
                SizedBox(width: 2,),
                Text('Done', style: TextStyle(fontSize: 10,color: Colors.black),),
              ],
            ),
          ),
          //SizedBox(width: 2,),
        ],
      ),
    );
  }
}