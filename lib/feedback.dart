import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedDistrict;
  String? selectedHospital;

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
                .where("district",
                    isEqualTo: selectedDistrict) // Filter by selected district
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                List<String> hospitals = snapshot.data!.docs
                    .map((doc) => doc['name']
                        as String) // Assuming the field for the hospital name is 'name'
                    .toList();
                return SingleChildScrollView(
                  child: ListBody(
                    children: hospitals
                        .map((hospital) => RadioListTile<String>(
                              title: Text(hospital),
                              value: hospital,
                              groupValue: selectedHospital,
                              onChanged: (value) {
                                setState(() {
                                  selectedHospital = value;
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

  void _submitFeedback() async {
    if (_formKey.currentState!.validate() &&
        selectedDistrict != null &&
        selectedHospital != null) {
      final user = FirebaseAuth.instance.currentUser;
      final patientId = user?.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Retrieve hospital details
      QuerySnapshot hospitalSnapshot = await firestore
          .collection('Hospitals')
          .where('name', isEqualTo: selectedHospital)
          .get();

      if (hospitalSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hospital found with the given name.'),
          ),
        );
        return;
      }

      final hospitalDoc = hospitalSnapshot.docs.first;
      String hospitalId = hospitalDoc.id; // Get hospital ID

      QuerySnapshot patientSnapshot = await firestore
          .collection('patients')
          .where('patient_id', isEqualTo: patientId)
          .get();

      if (patientSnapshot.docs.isNotEmpty) {
        final patientDoc = patientSnapshot.docs.first;
        final patientName = patientDoc.get('name') as String;
        String uDoc = patientDoc.id;
        final feedbackContent = _feedbackController.text.trim();

        try {
          await FirebaseFirestore.instance.collection('feedback').add({
            'patient_name': patientName,
            'feedback_content': feedbackContent,
            'district_name': selectedDistrict,
            'hospital_name': selectedHospital,
            'hospital_id': hospitalId, // Include hospital ID
            'patient_id': uDoc,
            'feedback_status': 0,
            'feedback_date': FieldValue.serverTimestamp(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback submitted successfully.'),
            ),
          );
          _feedbackController.clear();
          setState(() {
            selectedDistrict = null;
            selectedHospital = null;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting feedback: $e'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to submit feedback.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select a district, hospital, and enter your feedback.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontStyle: FontStyle.italic),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 10.0,
                child: ListTile(
                  leading: const Icon(Icons.location_city, color: Colors.black),
                  title: Text(
                    selectedDistrict ?? 'Select your district',
                    style: const TextStyle(
                        fontSize: 20,
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
                  leading:
                      const Icon(Icons.local_hospital, color: Colors.black),
                  title: Text(
                    selectedHospital ?? 'Select hospital for emergency',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () => hosselection(context),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _feedbackController,
                  maxLines: null,
                  minLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Enter your feedback',
                    hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
