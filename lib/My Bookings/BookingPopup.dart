import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class BookingPopup extends StatefulWidget {
  const BookingPopup({super.key});

  @override
  State<BookingPopup> createState() => _BookingPopupState();
}

class _BookingPopupState extends State<BookingPopup> {
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
    fetchDistricts();
  }

  DateTime? selectedDate;

  String? selectedDistrict;
  String? selectedHospital;
  String? selectedDepartment;
  String? selectedDoctor;
  String? selectedSlot;

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> hospitals = [];
  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> doctors = [];

  final _formKey = GlobalKey<FormState>();

  Future<void> fetchDistricts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('Districts').get();

      List<Map<String, dynamic>> tempDistricts = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['district_name'].toString(),
              })
          .toList();

      setState(() {
        districts = tempDistricts;
      });
      print(tempDistricts);
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchHospitals(name) async {
    hospitals = [];
    try {
      // Rehospital 'tbl_course' with your actual collection name
      QuerySnapshot<Map<String, dynamic>> querySnapshot1 =
          await FirebaseFirestore.instance
              .collection('Hospitals')
              .where('district', isEqualTo: name)
              .get();

      List<Map<String, dynamic>> hospital = querySnapshot1.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'].toString(),
              })
          .toList();

      setState(() {
        hospitals = hospital;
      });
      print(hospital);
    } catch (e) {
      print('Error fetching hospital data: $e');
    }
  }

  Future<void> fetchDepartments(name) async {
    departments = []; // Clear previous data
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Doctors') // Assuming this has department data
              .where('hospitalName', isEqualTo: name)
              .get();

      // Creating a set to track unique department names
      Set<String> uniqueDepartmentNames = {};

      List<Map<String, dynamic>> uniqueDepartments =
          querySnapshot.docs.fold<List<Map<String, dynamic>>>([], (list, doc) {
        String departmentName = doc['department'].toString();
        if (!uniqueDepartmentNames.contains(departmentName)) {
          uniqueDepartmentNames.add(departmentName);
          list.add({
            'id': doc.id,
            'department': departmentName,
          });
        }
        return list;
      });

      setState(() {
        departments =
            uniqueDepartments; // Set to the filtered list of unique departments
      });
      print(departments);
    } catch (e) {
      print('Error fetching department data: $e');
    }
  }

  // Modify fetchDoctors to accept nullable parameters if the logic allows
  Future<void> fetchDoctors(String? department, String? hospitalName) async {
    if (department == null || hospitalName == null) {
      print("Department or hospital name is null.");
      return; // Optionally handle this situation appropriately, maybe with an error message.
    }

    doctors = []; // Clear the current list to prepare for new data
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Doctors')
              .where('department', isEqualTo: department)
              .where('hospitalName', isEqualTo: hospitalName)
              .get();

      List<Map<String, dynamic>> doctorList = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'doctorName': doc['doctorName'].toString(),
              })
          .toList();

      setState(() {
        doctors = doctorList;
      });
      print(doctorList);
    } catch (e) {
      print('Error fetching doctor data: $e');
      Fluttertoast.showToast(msg: 'Error fetching doctor data: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ??
          DateTime.now(), // Provide a default date if none is selected
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void submitBooking() async {
    if (_formKey.currentState!.validate() &&
        selectedDistrict != null &&
        selectedHospital != null &&
        selectedDepartment != null &&
        selectedDoctor != null &&
        selectedSlot != null &&
        selectedDate != null) {
      final user = FirebaseAuth.instance.currentUser;
      final patientId = user?.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        // Fetch the hospital ID
        var hospitalsSnapshot = await firestore
            .collection('Hospitals')
            .where('name', isEqualTo: selectedHospital)
            .limit(1)
            .get();

        if (hospitalsSnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hospital not found.')),
          );
          return;
        }
        final hospitalId = hospitalsSnapshot.docs.first.id;

        // Fetch patient details
        var patientSnapshot = await firestore
            .collection('patients')
            .where('patient_id', isEqualTo: patientId)
            .get();

        if (patientSnapshot.docs.isNotEmpty) {
          final patientDoc = patientSnapshot.docs.first;
          final patientName = patientDoc.get('name') as String;

          // Format the date to a string or use Timestamp for Firestore
          String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

          // Add the booking information including the formatted date
          await firestore.collection('Booking').add({
            'patient_name': patientName,
            'district_name': selectedDistrict,
            'hospital_name': selectedHospital,
            'hospital_id': hospitalId, // Add hospital ID to booking
            'department_name': selectedDepartment,
            'doctor_name': selectedDoctor,
            'booking_slot': selectedSlot,
            'patient_id': patientId,
            'booking_status': 0,
            'booking_date': formattedDate,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking submitted successfully.')),
          );

          // Reset fields
          setState(() {
            selectedDistrict = null;
            selectedHospital = null;
            selectedDepartment = null;
            selectedDoctor = null;
            selectedSlot = null;
            selectedDate = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You must be logged in to make a booking.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting booking: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please ensure all fields are selected.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Your Booking',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on),
                        labelText: 'District',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDistrict = newValue;
                          selectedHospital = null;
                          selectedDepartment = null;
                          selectedDoctor = null;
                        });
                        if (newValue != null) {
                          fetchHospitals(newValue);
                        }
                      },
                      isExpanded: true,
                      items: districts.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> district) {
                        return DropdownMenuItem<String>(
                          value: district['name'],
                          child: Text(district['name']),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a district' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedHospital,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.local_hospital),
                        labelText: 'Hospital',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedHospital = newValue;
                          selectedDepartment = null;
                          selectedDoctor = null;
                        });
                        if (newValue != null) {
                          fetchDepartments(newValue);
                        }
                      },
                      isExpanded: true,
                      items: hospitals.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> hospital) {
                        return DropdownMenuItem<String>(
                          value: hospital['name'],
                          child: Text(hospital['name']),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a hospital' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.apartment),
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDepartment = newValue;
                          selectedDoctor = null;
                        });
                        if (newValue != null && selectedHospital != null) {
                          fetchDoctors(newValue, selectedHospital);
                        }
                      },
                      isExpanded: true,
                      items: departments.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> department) {
                        return DropdownMenuItem<String>(
                          value: department['department'],
                          child: Text(department['department']),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a department' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedDoctor,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Doctor',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDoctor = newValue;
                        });
                      },
                      isExpanded: true,
                      items: doctors.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor['doctorName'],
                          child: Text(doctor['doctorName']),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a doctor' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedSlot,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                            Icons.timer), // An icon that suggests time or slots
                        labelText: 'Booking Slot',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSlot = newValue;
                        });
                      },
                      isExpanded: true,
                      items:
                          <String>['Forenoon', 'Afternoon'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a doctor';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        suffixIcon: IconButton(
                          onPressed: () {
                            _selectDate(context);
                          },
                          icon: Icon(Icons.calendar_today),
                        ),
                      ),
                      controller: TextEditingController(
                        text: selectedDate != null
                            ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                            : 'No date selected',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        submitBooking();
                        // Add your button onPressed logic here
                      },
                      child: Text(
                        'Confirm Booking',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Additional widgets like date picker and submit button are assumed to be here
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
