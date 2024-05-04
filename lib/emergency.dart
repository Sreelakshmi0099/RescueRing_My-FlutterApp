import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescue_ring/login.dart';

void main() => runApp(const AlertButton());

class AlertButton extends StatefulWidget {
  const AlertButton({super.key});

  @override
  State<AlertButton> createState() => _AlertButtonState();
}

class _AlertButtonState extends State<AlertButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Emergency Alert System',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 210, 29, 29),
          actions: <Widget>[
            PopupMenuButton<int>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (item) => onSelected(context, item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 0, child: Text('Logout')),
              ],
            ),
          ],
        ),
        body: const EmergencyCenterButton(),
      ),
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0: // Logout option
        logout(context);
        break;
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              LoginPage()), // Navigate to Login Page after logout
    );
  }
}

class EmergencyCenterButton extends StatefulWidget {
  const EmergencyCenterButton({super.key});

  @override
  State<EmergencyCenterButton> createState() => _EmergencyCenterButtonState();
}

class _EmergencyCenterButtonState extends State<EmergencyCenterButton> {
  final TextEditingController numberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to submit an alert.')),
      );
      return;
    }

    try {
      DocumentSnapshot patientDocument = await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .get();

      if (!patientDocument.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No patient record found for current user.')),
        );
        return;
      }

      Map<String, dynamic> patientData =
          patientDocument.data() as Map<String, dynamic>;
      await FirebaseFirestore.instance.collection('alerts').add({
        'patient_id': user.uid,
        'patient_name': patientData['name'] ?? 'No Name',
        'patient_contact': patientData['contact'] ?? 'No Contact',
        'patient_age': patientData['age'] ?? 'No Age',
        'patient_bloodgrp': patientData['blood'] ?? 'No Blood Group',
        'patient_allergies': patientData['allergies'] ?? 'No Allergies',
        'patient_medicalstate':
            patientData['medicalstate'] ?? 'No medical state',
        'preffered_hospital':
            patientData['preferred_hospital'] ?? 'No Hospital',
        'preffered_hospitalId':
            patientData['preferred_hospital_id'] ?? 'No Hospital Id',
        'relative_number': patientData['relative_number'] ?? 'No Number',
        'alert_time': FieldValue.serverTimestamp(),
        'alert_status': 0
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Alert sent for ${patientData['name']}, contact: ${patientData['contact']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting alert: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 200.0;

    return Center(
      child: Form(
        key: _formKey,
        child: ElevatedButton(
          onPressed: fetchCurrentUser,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            padding:
                MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              const CircleBorder(),
            ),
            minimumSize: MaterialStateProperty.all<Size>(Size.zero),
            fixedSize: MaterialStateProperty.all<Size>(
                const Size(buttonSize, buttonSize)),
          ),
          child: const Icon(
            Icons.warning,
            size: 60.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
