// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleRefresh() async {
    // This function can interact with your backend to fetch updated data
    await Future.delayed(Duration(seconds: 2)); // Simulated network delay
    setState(() {
      // The state that might need to be updated once data is fetched
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final patientId = user?.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('patients')
        .where('patient_id', isEqualTo: patientId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _nameController.text = querySnapshot.docs.first['name'];
        _emailController.text = querySnapshot.docs.first['email'];
        _contactController.text = querySnapshot.docs.first['contact'];
        _addressController.text = querySnapshot.docs.first['address'];
      });
    } else {
      setState(() {
        _nameController.text = 'Error Loading Data';
        _emailController.text = 'Error Loading Data';
        _contactController.text = 'Error Loading Data';
        _addressController.text = 'Error Loading Data';
      });
    }
  }

  Future<void> editprofile() async {
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
                'name': _nameController.text,
                'email': _emailController.text,
                'contact': _contactController.text,
                'address': _addressController.text,
              });
              Fluttertoast.showToast(
                msg: "Profile updated successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
              _nameController.clear();
              _emailController.clear();
              _contactController.clear();
              _addressController.clear();
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
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Text(
                      'User editprofile',
                      style: TextStyle(
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Enter Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Enter Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: "Enter Contact",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: "Enter Address",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          editprofile();
                        },
                        child: const Text('Save'))
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
