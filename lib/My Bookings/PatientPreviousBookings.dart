import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Doctor {
  final String doctorName;
  final String hospitalName;
  final String department;

  Doctor({
    required this.doctorName,
    required this.hospitalName,
    required this.department,
  });
}

class PatientPreviousBookings extends StatefulWidget {
  const PatientPreviousBookings({super.key});

  @override
  State<PatientPreviousBookings> createState() =>
      _PatientPreviousBookingsState();
}

class _PatientPreviousBookingsState extends State<PatientPreviousBookings> {
  final String? patientId = FirebaseAuth.instance.currentUser?.uid;
  Future<void> _handleRefresh() async {
    // This function can interact with your backend to fetch updated data
    await Future.delayed(Duration(seconds: 2)); // Simulated network delay
    setState(() {
      // The state that might need to be updated once data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(
          height: 80.0,
          child: Center(
            child: Text(
              'Previous Booking',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Booking')
            .where('patient_id', isEqualTo: patientId)
            .where('booking_date',
                isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
            .where('booking_status', isEqualTo: 1)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<DocumentSnapshot> bookings = snapshot.data!.docs;
            print(bookings);
            return LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              showChildOpacityTransition: false,
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking =
                      bookings[index].data() as Map<String, dynamic>;
                  final String doctorName = booking['doctor_name'] ?? 'N/A';
                  final String hospitalName = booking['hospital_name'] ?? 'N/A';
                  final String department = booking['department_name'] ?? 'N/A';
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        doctorName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '$hospitalName, $department',
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
