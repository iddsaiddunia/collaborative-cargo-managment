import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborative_cargo_managment_app/auth/home.dart';
import 'package:collaborative_cargo_managment_app/color_themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _logisticOrdersFuture;

  @override
  void initState() {
    super.initState();
    _logisticOrdersFuture = fetchCompanyLogisticOrdersWithClientsAndRoutes();
  }

  Future<List<Map<String, dynamic>>>
      fetchCompanyLogisticOrdersWithClientsAndRoutes() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String operatorID = user.uid;

      // Fetch operator details
      DocumentSnapshot operatorSnapshot = await FirebaseFirestore.instance
          .collection('Operators')
          .doc(operatorID)
          .get();

      if (operatorSnapshot.exists) {
        String companyID = operatorSnapshot['companyID'];

        // Fetch logistic orders where companyID matches
        QuerySnapshot logisticOrdersSnapshot = await FirebaseFirestore.instance
            .collection('LogisticOrders')
            .where('companyID', isEqualTo: companyID)
            .get();

        // Convert to List of Maps and fetch corresponding client and route details
        List<Map<String, dynamic>> logisticOrdersWithClientsAndRoutes = [];

        for (var orderDoc in logisticOrdersSnapshot.docs) {
          var orderData = orderDoc.data() as Map<String, dynamic>;
          String userId = orderData['userId'];
          String routeId = orderData['routeId'];

          // Fetch client details
          DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
              .collection('clients')
              .doc(userId)
              .get();

          // Fetch route details
          DocumentSnapshot routeSnapshot = await FirebaseFirestore.instance
              .collection('RoutesPolls')
              .doc(routeId)
              .get();

          if (clientSnapshot.exists && routeSnapshot.exists) {
            var clientData = clientSnapshot.data() as Map<String, dynamic>;
            var routeData = routeSnapshot.data() as Map<String, dynamic>;

            var combinedData = {
              'order': orderData,
              'client': clientData,
              'route': routeData,
            };
            logisticOrdersWithClientsAndRoutes.add(combinedData);
          }
        }

        return logisticOrdersWithClientsAndRoutes;
      }
    }

    return [];
  }

  void showCargoReceivedPopup(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Cargo Received'),
          content: Text('Have you received the cargo for order $orderId?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('LogisticOrders')
                    .doc(orderId)
                    .update({'cargoReceived': true});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cargo received status updated')),
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _logisticOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No logistic orders found'));
          } else {
            List<Map<String, dynamic>> logisticOrdersWithClientsAndRoutes =
                snapshot.data!;
            return ListView.builder(
              itemCount: logisticOrdersWithClientsAndRoutes.length,
              itemBuilder: (context, index) {
                var orderData = logisticOrdersWithClientsAndRoutes[index]
                    ['order'] as Map<String, dynamic>;
                var clientData = logisticOrdersWithClientsAndRoutes[index]
                    ['client'] as Map<String, dynamic>;
                var routeData = logisticOrdersWithClientsAndRoutes[index]
                    ['route'] as Map<String, dynamic>;

                String orderNo = orderData['orderNo'];
                String from = orderData['from'];
                String to = orderData['to'];
                String clientName = clientData['username'];
                String clientPhone = clientData['phone'];
                String routeInfo = routeData['trackInfo'];

                return Container(
                  child: Column(
                    children: [
                      Text("OrderNo: $orderNo"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          verticalTextTIle(
                            title: "From",
                            content: "$from",
                          ),
                          verticalTextTIle(
                            title: "To",
                            content: "$to",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          verticalTextTIle(
                            title: "Client name",
                            content: "$clientName",
                          ),
                          verticalTextTIle(
                            title: "Client phone",
                            content: "$clientPhone",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          verticalTextTIle(
                            title: "package type",
                            content: "${orderData['packageType']}",
                          ),
                          verticalTextTIle(
                            title: "package size",
                            content: "${orderData['packageSize']}",
                          ),
                          verticalTextTIle(
                            title: "amount",
                            content: "${orderData['amount']} Tsh",
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (!orderData['cargoReceived'])
                          ? MaterialButton(
                              elevation: 0,
                              color: color.primaryColor,
                              onPressed: () {
                                showCargoReceivedPopup(context, orderNo);
                              },
                              child: Text(
                                "verify receiving cargo",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : Container(),
                      Divider()
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
