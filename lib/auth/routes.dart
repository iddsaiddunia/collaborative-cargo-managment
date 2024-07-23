import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborative_cargo_managment_app/auth/home.dart';
import 'package:collaborative_cargo_managment_app/auth/location_search.dart';
import 'package:collaborative_cargo_managment_app/color_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:intl/intl.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class RoutesPage extends StatefulWidget {
  final String routeId;
  const RoutesPage({super.key, required this.routeId});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _locationList = [];
  String? _selectedPlace;
  bool _isLoading = false;

  Future<Map<String, dynamic>> fetchRouteAndOrderDetails(String routeId) async {
    final firestore = FirebaseFirestore.instance;

    // Fetch route details from RoutesPolls
    DocumentSnapshot routeDoc =
        await firestore.collection('RoutesPolls').doc(routeId).get();
    if (!routeDoc.exists) {
      throw Exception('Route not found');
    }
    Map<String, dynamic> routeDetails = routeDoc.data() as Map<String, dynamic>;

    // Fetch order count from LogisticOrders with the given routeId
    QuerySnapshot orderSnapshot = await firestore
        .collection('LogisticOrders')
        .where('routeId', isEqualTo: routeId)
        .get();
    int orderCount = orderSnapshot.docs.length;

    // Combine route details and order count
    routeDetails['orderCount'] = orderCount;

    return routeDetails;
  }

  String formatDate(Timestamp timestamp) {
    final dateFormat = DateFormat('yy-MM-d');
    final date = timestamp.toDate();
    return dateFormat.format(date);
  }

  // Replace with your actual route ID

  Future<void> _addLocationToRoute(String location, String _routeId) async {
    setState(() {
      _isLoading = true;
    });
    DocumentReference routeDoc =
        _firestore.collection('RoutesPolls').doc(_routeId);

    await routeDoc.update({
      'locationList': FieldValue.arrayUnion([location])
    });

    setState(() {
      _selectedPlace = location;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$location added to route'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _updateDepartureStatus(String routeId, String status) async {
    DocumentReference routeDoc =
        _firestore.collection('RoutesPolls').doc(routeId);

    await routeDoc.update({
      'depatureStatus': status,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Departure status updated to $status'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showStatusDialog(String routeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Departure Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Canceled'),
                onTap: () {
                  _updateDepartureStatus(routeId, 'canceled');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Departed'),
                onTap: () {
                  _updateDepartureStatus(routeId, 'depatured');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Arrived'),
                onTap: () {
                  _updateDepartureStatus(routeId, 'arrived');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRouteAndOrderDetails(widget.routeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          }

          Map<String, dynamic> routeDetails = snapshot.data!;
          int orderCount = routeDetails['orderCount'];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    verticalTextTIle(
                      title: "From",
                      content: "${routeDetails['from']}",
                    ),
                    verticalTextTIle(
                      title: "To",
                      content: "${routeDetails['to']}",
                    ),
                    verticalTextTIle(
                      title: "Depature",
                      content: "${formatDate(routeDetails['depatureTime'])}",
                    ),
                    verticalTextTIle(
                      title: "Status",
                      content: "${routeDetails['depatureStatus']}",
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    verticalTextTIle(
                      title: "Total capacity",
                      content: "${routeDetails['totalSpace']} Ton",
                    ),
                    verticalTextTIle(
                      title: "Remaining capacity",
                      content: "${routeDetails['remainingSpace']} Ton",
                    ),
                    verticalTextTIle(
                      title: "Total orders",
                      content: "$orderCount ",
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                (routeDetails['depatureStatus'] != "depatured" ||
                        routeDetails['depatureStatus'] != "arrived")
                    ? MaterialButton(
                        color: color.primaryColor,
                        onPressed: () {
                          _showStatusDialog(widget.routeId);
                        },
                        child: Text(
                          "Update Depature",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Column(
                    children: [
                      Text("Current Location: Dodoma"),
                      MaterialButton(
                        color: color.primaryColor,
                        onPressed: () async {
                          final selectedPlace = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPlacesPage()),
                          );
                          if (selectedPlace != null) {
                            setState(() {
                              _selectedPlace = selectedPlace.name;
                            });
                          }
                        },
                        child: Text(
                          "Select current Location",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Text("$_selectedPlace"),
                      (_selectedPlace != null)
                          ? MaterialButton(
                              color: color.primaryColor,
                              onPressed: () async {
                                if (_selectedPlace != null) {
                                  await _addLocationToRoute(
                                      _selectedPlace!, widget.routeId);
                                }
                              },
                              child: (!_isLoading)
                                  ? Text(
                                      "Update Location",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : CircularProgressIndicator(),
                            )
                          : Container(),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
