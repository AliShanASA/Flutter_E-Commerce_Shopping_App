// ignore_for_file: unused_local_variable

import 'package:animate_do/animate_do.dart';
import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:fashion_ecommerce_app/utils/constants.dart';
import 'package:flutter/material.dart';

import '../home/admin_home.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final int _index = 0;
  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: FadeIn(
          delay: const Duration(milliseconds: 300),
          child: const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBarBubble(
        color: primaryColor,
        selectedIndex: _index,
        items: [
          BottomBarItem(iconData: Icons.home),
          // BottomBarItem(iconData: Icons.dashboard),
          // BottomBarItem(iconData: Icons.person),
          // BottomBarItem(iconData: Icons.production_quantity_limits),
        ],
        onSelect: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AdminHome()));
          }
          //else if (index == 2) {
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const ManageCustomers()));
          // }
        },
      ),
    );
  }
}
