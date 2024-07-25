import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddRoutePolls extends StatefulWidget {
  const AddRoutePolls({super.key});

  @override
  State<AddRoutePolls> createState() => _AddRoutePollsState();
}

class _AddRoutePollsState extends State<AddRoutePolls> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _trackInfoController = TextEditingController();
  final TextEditingController _spaceController = TextEditingController();
  final TextEditingController _chargesPerTonController =
      TextEditingController();
  DateTime? _departureTime;
  DateTime? _arrivalTime;
  bool _isLoading = false;
  String? _operatorID;
  String? _companyID;

  @override
  void initState() {
    super.initState();
    _fetchOperatorDetails();
  }

  Future<void> _fetchOperatorDetails() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String operatorID = user.uid;

      // Fetch operator details
      DocumentSnapshot operatorSnapshot = await FirebaseFirestore.instance
          .collection('Operators')
          .doc(operatorID)
          .get();

      if (operatorSnapshot.exists) {
        _operatorID = operatorID;
        _companyID = operatorSnapshot['companyID'];
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addRoute() async {
    if (_formKey.currentState!.validate() &&
        _operatorID != null &&
        _companyID != null) {
      final routeData = {
        'from': _fromController.text,
        'to': _toController.text,
        'companyID': _companyID,
        'operatorID': _operatorID,
        'trackInfo': _trackInfoController.text,
        'chargesPerTon': double.parse(_chargesPerTonController.text),
        'depatureTime': _departureTime,
        'ArrivedLocationList': [],
        'route': [],
        'arrivalTime': _arrivalTime,
        'createdAt': Timestamp.now(),
        'depatureStatus': "waiting",
        'totalSpace': double.parse(_spaceController
            .text), // Assuming total space is a constant value, update as needed
        'remainingSpace': double.parse(_spaceController
            .text), // Assuming total space is a constant value, update as needed
      };

      await FirebaseFirestore.instance.collection('RoutesPolls').add(routeData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route added successfully')),
      );

      // Clear form fields after submission
      _fromController.clear();
      _toController.clear();
      _companyNameController.clear();
      _trackInfoController.clear();
      _spaceController.clear();
      _chargesPerTonController.clear();
      setState(() {
        _departureTime = null;
        _arrivalTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Route')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _fromController,
                      decoration: InputDecoration(labelText: 'From'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a starting location';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _toController,
                      decoration: InputDecoration(labelText: 'To'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a destination';
                        }
                        return null;
                      },
                    ),
                    // TextFormField(
                    //   controller: _companyNameController,
                    //   decoration: InputDecoration(labelText: 'Company Name'),
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter the company name';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    TextFormField(
                      controller: _trackInfoController,
                      decoration: InputDecoration(labelText: 'Track Info'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the track information';
                        }
                        return null;
                      },
                    ),
                    // TextFormField(
                    //   controller: _remainingSpaceController,
                    //   decoration:
                    //       InputDecoration(labelText: 'Remaining Space (tons)'),
                    //   keyboardType: TextInputType.number,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please enter the remaining space';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    TextFormField(
                      controller: _chargesPerTonController,
                      decoration: InputDecoration(labelText: 'Charges per Ton'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the charges per ton';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _spaceController,
                      decoration:
                          InputDecoration(labelText: 'Track capacity(Ton)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please track capacity';
                        }
                        return null;
                      },
                    ),
                    ListTile(
                      title: Text(
                          'Departure Time: ${_departureTime != null ? _departureTime.toString() : 'Select Date'}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _departureTime = pickedDate;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(
                          'Arrival Time: ${_arrivalTime != null ? _arrivalTime.toString() : 'Select Date'}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _arrivalTime = pickedDate;
                          });
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: _addRoute,
                      child: Text('Add Route'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
