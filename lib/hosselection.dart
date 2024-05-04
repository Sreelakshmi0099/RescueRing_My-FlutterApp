import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Hos_Selection());
}

class Hos_Selection extends StatefulWidget {
  const Hos_Selection({Key? key}) : super(key: key);

  @override
  State<Hos_Selection> createState() => _Hos_SelectionState();
}

class _Hos_SelectionState extends State<Hos_Selection> {
  final TextEditingController numberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedHospitalName;
  String? selectedHospitalId;
  String? selectedDistrict;
  String relativeNumber = '';

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 2));
    Fluttertoast.showToast(
      msg: "Data refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
    setState(() {});
  }

  void openAddRelativePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Relative\'s Phone Number'),
          content: TextFormField(
            controller: numberController,
            decoration: const InputDecoration(hintText: "Phone Number"),
            keyboardType: TextInputType.phone,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (numberController.text.isNotEmpty) {
                  setState(() {
                    relativeNumber = numberController.text;
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void selectDistrict(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select District"),
          content: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("Districts").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                List<Map<String, String>> districts = snapshot.data!.docs
                    .map((doc) => {
                          'id': doc.id.toString(),
                          'name': doc['district_name'].toString(),
                        })
                    .toList();
                return SingleChildScrollView(
                  child: ListBody(
                    children: districts
                        .map((district) => RadioListTile<String>(
                              title: Text(district['name'].toString()),
                              value: district['name'].toString(),
                              groupValue: selectedDistrict,
                              onChanged: (value) {
                                setState(() {
                                  selectedDistrict = value;
                                  Navigator.of(context).pop();
                                });
                              },
                            ))
                        .toList(),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void hosselection(BuildContext context) {
    if (selectedDistrict == null) {
      Fluttertoast.showToast(
        msg: "Please select a district first",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Hospital in $selectedDistrict"),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Hospitals")
                .where("district", isEqualTo: selectedDistrict)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                List<DocumentSnapshot> hospitals = snapshot.data!.docs;
                return SingleChildScrollView(
                  child: ListBody(
                    children: hospitals
                        .map((doc) => RadioListTile<String>(
                              title: Text(doc['name']),
                              value:
                                  doc['name'], // Use name for display and value
                              groupValue: selectedHospitalName,
                              onChanged: (value) {
                                setState(() {
                                  selectedHospitalName =
                                      value; // Store the hospital name for display
                                  selectedHospitalId = doc
                                      .id; // Store the hospital ID for backend use
                                  Navigator.of(context).pop();
                                });
                              },
                            ))
                        .toList(),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Future<void> saveEmergencyDetails() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      final patientId = user?.uid;

      if (patientId != null) {
        try {
          DocumentReference docRef =
              FirebaseFirestore.instance.collection('patients').doc(patientId);
          await docRef.update({
            'relative_number': numberController.text,
            'preferred_hospital_name': selectedHospitalName,
            'preferred_hospital_id':
                selectedHospitalId, // Saving the hospital ID here
          });
          Fluttertoast.showToast(
            msg: "Details Updated Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Error updating document: $e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "User ID is null",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Set Emergencies',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  fontStyle: FontStyle.italic)),
          centerTitle: true,
          backgroundColor: Colors.redAccent,
        ),
        body: Center(
          child: Form(
            key: _formKey,
            child: LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10.0,
                      child: ListTile(
                        leading: const Icon(Icons.location_city,
                            color: Colors.black),
                        title: Text(
                          selectedDistrict ?? 'Select your district',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () => selectDistrict(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10.0,
                      child: ListTile(
                        leading: const Icon(Icons.local_hospital,
                            color: Colors.black),
                        title: Text(
                          selectedHospitalName ??
                              'Select hospital for emergency',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () => hosselection(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10.0,
                      child: ListTile(
                        leading: const Icon(Icons.phone, color: Colors.black),
                        title: Text(
                          relativeNumber.isEmpty
                              ? 'Add Relative\'s Number'
                              : relativeNumber,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () => openAddRelativePopup(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveEmergencyDetails,
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text("Save",
                          style: TextStyle(
                              fontSize: 20, color: Colors.blueAccent)),
                    )
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
