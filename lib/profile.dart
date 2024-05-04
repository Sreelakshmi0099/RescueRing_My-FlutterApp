import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rescue_ring/editprofile.dart';

// ignore: camel_case_types
class User_Profile extends StatefulWidget {
  const User_Profile({super.key});

  @override
  State<User_Profile> createState() => _User_ProfileState();
}

class _User_ProfileState extends State<User_Profile> {
  String name = 'Loading.....';
  String email = 'Loading.....';
  String contact = 'Loading.....';
  String address = 'Loading.....';
  String photo = '';

  @override
  void initState() {
    super.initState();
    getData();
    print('###################');
  }

  Future<void> getData() async {
    final user = FirebaseAuth.instance.currentUser;
    final patientId = user?.uid;
    print('###################');
    print(user);
    print('###################');
    print(patientId);

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('patients')
        .where('patient_id', isEqualTo: patientId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        name = querySnapshot.docs.first['name'];
        email = querySnapshot.docs.first['email'];
        contact = querySnapshot.docs.first['contact'];
        address = querySnapshot.docs.first['address'];
        // photo = querySnapshot.docs.first['user_photo'];
      });
    } else {
      setState(() {
        name = 'Error Loading Data';
        email = 'Error Loading Data';
        contact = 'Error Loading Data';
        address = 'Error Loading Data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Color.fromARGB(255, 210, 29, 29),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          width: 500,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0)),
          child: ListView(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                'My Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                  // padding: const EdgeInsets.all(6),
                  // decoration: const BoxDecoration(
                  //   color: Color.fromARGB(255, 216, 225, 233),
                  //   borderRadius: BorderRadius.all(Radius.circular(10)),
                  // ),
                  // child: (photo != ""
                  //     ? Image.network(
                  //         photo,
                  //         fit: BoxFit.cover,
                  //         height: 200,
                  //         width: 80,
                  //       )
                  //     : Image.asset('assets/pic.png',
                  //         height: 200, width: 80, fit: BoxFit.cover)),
                  ),
              const SizedBox(
                height: 10,
              ),
              Text('Name: $name'),
              const SizedBox(
                height: 20,
              ),
              Text('Email: $email'),
              const SizedBox(
                height: 20,
              ),
              Text('Contact: $contact'),
              const SizedBox(
                height: 20,
              ),
              Text('Address: $address'),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceEvenly, // Adjust as per your preference
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(),
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.edit), // Icon for editing profile
                        SizedBox(height: 5),
                        Text('Edit Profile'),
                      ],
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const Forgotpassword(),
                  //       ),
                  //     );
                  //   },
                  //   // child: const Column(
                  //   //   children: [
                  //   //     Icon(Icons.lock), // Icon for changing password
                  //   //     SizedBox(height: 5),
                  //   //     Text('Change Password'),
                  //   //   ],
                  //   // ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
