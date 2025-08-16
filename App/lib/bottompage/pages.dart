import 'package:flutter/material.dart';
import 'package:extrack/home.dart';
import 'package:extrack/item2page.dart';
import 'package:extrack/profile.dart';
import 'package:extrack/item1page.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const Homepage(),
    const Item1page(),
    const Item2page(),
    const Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service_outlined),
            label: 'Home',
              activeIcon: Icon(Icons.home_repair_service),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Item 1',
            activeIcon: Icon(Icons.shopping_cart),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Item 2',
              activeIcon: Icon(Icons.shopping_bag),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            label: 'Profile',
              activeIcon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

