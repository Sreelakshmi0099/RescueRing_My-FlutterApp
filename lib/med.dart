import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class MedicalCertificatePage extends StatefulWidget {
  const MedicalCertificatePage({super.key});

  @override
  State<MedicalCertificatePage> createState() => _MedicalCertificatePageState();
}

class _MedicalCertificatePageState extends State<MedicalCertificatePage> {
  final TextEditingController _agecontroller = TextEditingController();
  final TextEditingController _bloodgrpcontroller = TextEditingController();
  final TextEditingController _allergiescontroller = TextEditingController();
  final TextEditingController _medicalstatecontroller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleRefresh() async {
    // This function can interact with your backend to fetch updated data
    await Future.delayed(Duration(seconds: 2)); // Simulated network delay
    setState(() {
      // The state that might need to be updated once data is fetched
    });
  }

  Future<void> _submitMedDetails() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      final patientId = user?.uid;

      if (patientId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('patients')
              .where('patient_id', isEqualTo: patientId)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              final docId = querySnapshot.docs.first.id;
              FirebaseFirestore.instance
                  .collection('patients')
                  .doc(docId)
                  .update({
                'age': _agecontroller.text,
                'blood': _bloodgrpcontroller.text,
                'allergies': _allergiescontroller.text,
                'medicalstate': _medicalstatecontroller.text,
              });
              Fluttertoast.showToast(
                msg: "Helath Data updated successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
            }
          });
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          print('Error updating document: $e');
        }
      } else {
        Fluttertoast.showToast(
          msg: "User ID is null",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        print('User ID is null');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Color.fromARGB(255, 210, 29, 29),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                // Added SingleChildScrollView for better scrolling behavior
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'Health Data',
                      style: TextStyle(
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _agecontroller,
                      decoration: const InputDecoration(
                        labelText: "Enter Age",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bloodgrpcontroller,
                      decoration: const InputDecoration(
                        labelText: "Enter Blood Group",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _allergiescontroller,
                      decoration: const InputDecoration(
                        labelText: "Enter Allergies",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _medicalstatecontroller,
                      decoration: const InputDecoration(
                        labelText: "Medical Condition",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitMedDetails, // Correct function to call
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
