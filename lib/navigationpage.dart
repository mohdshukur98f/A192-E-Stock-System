// import 'package:estocksystem/welcomepage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:estocksystem/homepage.dart';
import 'package:estocksystem/cartpage.dart';
import 'package:estocksystem/historypage.dart';
import 'package:estocksystem/profilepage.dart';
import 'package:estocksystem/user.dart';

class NavigationPage extends StatefulWidget {
  final User user;

  const NavigationPage({Key key, this.user}) : super(key: key);

  @override
  _NavigationPage createState() => _NavigationPage();
}

class _NavigationPage extends State<NavigationPage> {
  int _currentIndex = 0;
  List<Widget> tabchildren;
  String maintitle = "Home";

  @override
  void initState() {
    super.initState();
    tabchildren = [
      HomePage(user: widget.user),
      HistoryPage(user: widget.user),
      CartPage(user: widget.user),
      ProfilePage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabchildren[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'History'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'My Cart'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        maintitle = "Home";
      }
      if (_currentIndex == 1) {
        maintitle = "History";
      }
      if (_currentIndex == 2) {
        maintitle = "My Cart";
      }
      if (_currentIndex == 4) {
        maintitle = "Account";
      }
    });
  }
}
