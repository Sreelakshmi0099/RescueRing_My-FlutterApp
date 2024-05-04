import 'package:flutter/material.dart';
import 'package:rescue_ring/My%20Bookings/PatientFutureBookings.dart';
import 'package:rescue_ring/My%20Bookings/PatientPreviousBookings.dart';
import 'package:rescue_ring/My%20Bookings/PatientTodaysBookings.dart';

// import 'package:rescue_ring/currentbooking.dart';
// Aimport 'package:rescue_ring/prevbooking.dart';

// ignore: camel_case_types
class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(backgroundColor: Color.fromARGB(255, 213, 36, 36)),
          body: const Column(
            children: [
              TabBar(
                indicatorColor: Colors.redAccent,
                labelColor: Colors.red, // Active tab color
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(
                    text: ("Bookings For The Day"),
                    // icon: Icon(
                    //   Icons.local_hospital_sharp,
                    //   color: Colors.deepPurple[300],
                    // ),
                  ),
                  Tab(
                    // icon: Icon(
                    //   Icons.local_hospital,
                    //   color: Colors.deepPurple[300],
                    // ),
                    text: ("Upcoming Bookings"),
                  ),
                  Tab(
                    text: ("Previous Bookings"),
                  ),
                ],
              ),
              Expanded(
                  child: TabBarView(
                children: [
                  // First Tab
                  PatientTodaysBooking(),
                  // Second Tab
                  PatientFutureBookings(),

                  //
                  PatientPreviousBookings(),
                ],
              ))
            ],
          ),
        ));
  }
}
