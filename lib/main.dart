// ignore: depend_on_referenced_packages
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rescue_ring/My%20Bookings/PatientTodaysBookings.dart';
import 'package:rescue_ring/editprofile.dart';
import 'package:rescue_ring/firebase_options.dart';
import 'package:rescue_ring/forgotpswd.dart';
import 'package:rescue_ring/hosselection.dart';
import 'package:rescue_ring/login.dart';
import 'package:rescue_ring/med.dart';
import 'package:rescue_ring/sign.dart';
import 'package:rescue_ring/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.safetyNet,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
