import 'package:flutter/material.dart';
import 'package:jadwalku/model/users.dart';
import 'package:jadwalku/pages/home.dart';
import 'package:jadwalku/pages/profile.dart';
import 'package:jadwalku/provider/userProvider.dart';
import 'package:jadwalku/widget/progress_indicator.dart';
import 'package:provider/provider.dart';

class PreHome extends StatefulWidget {
  const PreHome({Key key}) : super(key: key);

  @override
  _PreHomeState createState() => _PreHomeState();
}

class _PreHomeState extends State<PreHome> {
  final List<Widget> _page = [
    Home(),
    ProfilePage(2,'',''),
  ];
   int _currentPage = 0;

   @override


   void selectPage (int index) {
     setState(() {
       _currentPage = index;
     });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: _page.elementAt(_currentPage),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentPage,
            onTap: selectPage,
            selectedItemColor: Colors.green.shade800,
            unselectedItemColor: Colors.black38,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'My Page',
              ),
            ],
          ),
        );

  }
}
