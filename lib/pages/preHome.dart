import 'package:flutter/material.dart';
import 'package:jadwalku/pages/home.dart';
import 'package:jadwalku/pages/profile.dart';

class PreHome extends StatefulWidget {
  const PreHome({Key key}) : super(key: key);

  @override
  _PreHomeState createState() => _PreHomeState();
}

class _PreHomeState extends State<PreHome> {
  final List<Widget> _page = [
    ProfilePage(2,'',''),
    Home(),
  ];
   int _currentPage = 0;

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
        selectedItemColor: Colors.teal,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
