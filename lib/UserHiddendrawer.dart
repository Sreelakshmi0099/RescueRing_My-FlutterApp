import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:rescue_ring/My%20Bookings/Bookings.dart';
import 'package:rescue_ring/emergency.dart';
import 'package:rescue_ring/feedback.dart';
import 'package:rescue_ring/hosselection.dart';
import 'package:rescue_ring/med.dart';
import 'package:rescue_ring/profile.dart';

class UserHiddenDrawer extends StatefulWidget {
  const UserHiddenDrawer({super.key});

  @override
  State<UserHiddenDrawer> createState() => _UserHiddenDrawerState();
}

class _UserHiddenDrawerState extends State<UserHiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];
  @override
  void initState() {
    super.initState();
    _pages = [
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Alert',
              baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
              selectedStyle: const TextStyle()),
          const AlertButton()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Profile',
              baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
              selectedStyle: const TextStyle()),
          const User_Profile()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Health Data',
              baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
              selectedStyle: const TextStyle()),
          const MedicalCertificatePage()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Bookings',
              baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
              selectedStyle: const TextStyle()),
          const Bookings()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Emergency',
              baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
              selectedStyle: const TextStyle()),
          const Hos_Selection()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Feedback',
              baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
              selectedStyle: const TextStyle()),
          const FeedbackScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      backgroundColorMenu: Colors.redAccent.shade200,
      screens: _pages,
      initPositionSelected: 0,
      slidePercent: 40,
      contentCornerRadius: 30,
      boxShadow: const [],
    );
  }
}
