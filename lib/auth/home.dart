import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborative_cargo_managment_app/auth/add_route.dart';
import 'package:collaborative_cargo_managment_app/auth/orders.dart';
import 'package:collaborative_cargo_managment_app/auth/request.dart';
import 'package:collaborative_cargo_managment_app/auth/routes.dart';
import 'package:collaborative_cargo_managment_app/color_themes.dart';
import 'package:collaborative_cargo_managment_app/services/auth.dart';
import 'package:collaborative_cargo_managment_app/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

ColorTheme _colorTheme = ColorTheme();
AuthService _authService = AuthService();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>?> _companyInfoFuture;
  User? user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot>? _logisticOrdersStream;

  _openRequest(int selectedIndex) {
    setState(() {
      _selectedIndex = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    _companyInfoFuture = _fetchCompanyInfo();
    _fetchCompanyRequests();
  }

  Future<Map<String, dynamic>?> _fetchCompanyInfo() async {
    String uid = user!.uid;
    print(uid);
    if (uid == null) {
      return null;
    }

    try {
      // Fetch operator document based on user ID
      QuerySnapshot operatorSnapshot = await _firestore
          .collection('Operators')
          .where('operatorID', isEqualTo: uid)
          .limit(1)
          .get();

      if (operatorSnapshot.docs.isEmpty) {
        return null;
      }

      var operatorDoc = operatorSnapshot.docs.first;
      String companyId = operatorDoc['companyID'];

      // Fetch company document based on company ID
      DocumentSnapshot companyDoc =
          await _firestore.collection('Companies').doc(companyId).get();

      if (!companyDoc.exists) {
        print("NO company data fetched");
        return null;
      }

      return companyDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching company info: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchRouteDetails() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('Operators')
        .where('operatorID', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((operatorSnapshot) async {
      if (operatorSnapshot.docs.isEmpty) {
        print("No operator found for the user");
        return [];
      }

      var operatorDoc = operatorSnapshot.docs.first;
      String companyId = operatorDoc['companyID'];
      print("Fetched companyID: $companyId");

      QuerySnapshot routeSnapshot = await FirebaseFirestore.instance
          .collection('RoutesPolls')
          .where('companyID', isEqualTo: companyId)
          .get();

      if (routeSnapshot.docs.isEmpty) {
        print("No routes found for the company");
        return [];
      }

      return routeSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['routeId'] = doc.id; // Include the document ID
        return data;
      }).toList();
    });
  }

  Future<void> _fetchCompanyRequests() async {
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

        // Set stream for logistic orders where companyID matches
        setState(() {
          _logisticOrdersStream = FirebaseFirestore.instance
              .collection('LogisticOrders')
              .where('companyID', isEqualTo: companyID)
              .where('paymentStatus', isEqualTo: false)
              .snapshots();
        });
      }
    }
  }

  void _showPaymentVerificationDialog(BuildContext context, String orderNo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Payment'),
          content: Text('Have you received the payment for order $orderNo?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await _verifyPayment(orderNo);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyPayment(String orderNo) async {
    try {
      // Fetch the document ID based on orderNo
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('LogisticOrders')
          .where('orderNo', isEqualTo: orderNo)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;

        // Update the paymentStatus and orderStatus fields
        await FirebaseFirestore.instance
            .collection('LogisticOrders')
            .doc(docId)
            .update({
          'paymentStatus': true,
          'orderStatus': 'pending',
        });
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: FutureBuilder<Map<String, dynamic>?>(
        future: _companyInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No company info found.'));
          } else {
            // Extract the company data
            Map<String, dynamic> companyInfo = snapshot.data!;
            return Text("${companyInfo['companyName']}");
          }
        },
      )),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(color: color.primaryColor),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "John Doe",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              "johndoe@mail.com",
                              style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    // DrawerTile(
                    //   title: "Requests",
                    //   ontap: () {
                    //     // Navigator.push(
                    //     //   context,
                    //     //   MaterialPageRoute(
                    //     //     builder: (context) => ProfilePage(),
                    //     //   ),
                    //     // );
                    //   },
                    //   icon: Icons.person_3_outlined,
                    // ),
                    DrawerTile(
                      title: "Orders",
                      ontap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrdersPage(),
                          ),
                        );
                      },
                      icon: Icons.add_chart,
                    ),
                    // DrawerTile(
                    //   title: "Transactions",
                    //   ontap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => TransactionPage(),
                    //       ),
                    //     );
                    //   },
                    //   icon: Icons.monetization_on_outlined,
                    // ),
                    // DrawerTile(
                    //   title: "Savings",
                    //   ontap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => SavingsPage(),
                    //       ),
                    //     );
                    //   },
                    //   icon: Icons.lightbulb_circle_outlined,
                    // ),
                    // DrawerTile(
                    //   title: "Loans",
                    //   ontap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => LoansPage(),
                    //       ),
                    //     );
                    //   },
                    //   icon: Icons.list_alt_outlined,
                    // ),
                    // DrawerTile(
                    //   title: "About",
                    //   ontap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => AboutPage(),
                    //       ),
                    //     );
                    //   },
                    //   icon: Icons.question_answer_outlined,
                    // ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                      minWidth: 120,
                      height: 50,
                      elevation: 0,
                      color: _colorTheme.primaryColor,
                      child: Row(
                        children: [Icon(Icons.logout), Text("LogOut")],
                      ),
                      onPressed: () async {
                        await _authService.signOutUser();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Wrapper(isSignedIn: false),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 20,
                ),
                // Text("Developed by/S.G4"),
                Text(
                  "2024@ collabo All rights reserved",
                  style: TextStyle(color: Colors.black87, fontSize: 11),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Container(
                //   width: MediaQuery.of(context).size.width / 2.1,
                //   height: 80,
                //   decoration: const BoxDecoration(
                //     color: Colors.green,
                //     borderRadius: BorderRadius.all(
                //       Radius.circular(10),
                //     ),
                //   ),
                //   child: const Column(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         "976",
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.white,
                //         ),
                //       ),
                //       Text(
                //         "Total requests",
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: Color.fromARGB(255, 230, 230, 230),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   width: MediaQuery.of(context).size.width / 2.1,
                //   height: 80,
                //   decoration: const BoxDecoration(
                //     color: Colors.deepPurple,
                //     borderRadius: BorderRadius.all(
                //       Radius.circular(10),
                //     ),
                //   ),
                //   child: const Column(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         "9",
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.white,
                //         ),
                //       ),
                //       Text(
                //         "Total routes",
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: Color.fromARGB(255, 230, 230, 230),
                //         ),
                //       ),
                //     ],
                //   ),
                // )
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Active Requests",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 34, 34, 34),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => RequestPage(),
                      //   ),
                      // );
                    },
                    // child: const Text("view all"),
                  )
                ],
              ),
              Container(
                width: double.infinity,
                height: 400,
                // color: Colors.amber,
                child: _logisticOrdersStream == null
                    ? Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                        stream: _logisticOrdersStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: Text('No active request found'));
                          }

                          var logisticOrders = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: logisticOrders.length,
                            itemBuilder: (context, index) {
                              var order = logisticOrders[index].data()
                                  as Map<String, dynamic>;

                              String paymentStatus;
                              if (order['paymentStatus'] == false) {
                                paymentStatus = "not paid";
                              } else {
                                paymentStatus = "paid";
                              }
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                width: double.infinity,
                                height: (_selectedIndex == index) ? 160 : 70,
                                decoration: const BoxDecoration(
                                    // color: Colors.red,
                                    ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      width: double.infinity,
                                      height: 70,
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 243, 244, 245),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              verticalTextTIle(
                                                title: "orderNo",
                                                content:
                                                    "47CFC4P2MJKWPTCRFYICM",
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    order['from'],
                                                    style:
                                                        TextStyle(fontSize: 11),
                                                  ),
                                                  Text(
                                                    " >>> ",
                                                    style:
                                                        TextStyle(fontSize: 11),
                                                  ),
                                                  Text(
                                                    order['to'],
                                                    style:
                                                        TextStyle(fontSize: 11),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          MaterialButton(
                                            elevation: 0,
                                            color: Colors.green,
                                            onPressed: () {
                                              _showPaymentVerificationDialog(
                                                  context, order['orderNo']);
                                            },
                                            child: Text(
                                              "Attend",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          IconButton(
                                            padding: const EdgeInsets.all(0),
                                            onPressed: () {
                                              _openRequest(index);
                                            },
                                            icon: const Icon(
                                                Icons.arrow_drop_down),
                                          ),
                                        ],
                                      ),
                                    ),
                                    (_selectedIndex == index)
                                        ? Container(
                                            width: double.infinity,
                                            height: 90,
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 226, 226, 226),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    verticalTextTIle(
                                                      title: "package type",
                                                      content:
                                                          "${order['packageType']}",
                                                    ),
                                                    verticalTextTIle(
                                                      title: "package size",
                                                      content:
                                                          "${order['packageSize']}",
                                                    ),
                                                    verticalTextTIle(
                                                      title: "amount",
                                                      content:
                                                          "${order['amount']} Tsh",
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    verticalTextTIle(
                                                      title: "Expires",
                                                      content: "00:34:20",
                                                    ),
                                                    verticalTextTIle(
                                                      title: "Payments",
                                                      content: "$paymentStatus",
                                                    ),
                                                    verticalTextTIle(
                                                      title: "contact",
                                                      content: "+255768543214",
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Active Routes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 34, 34, 34),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRoutePolls(),
                      ),
                    );
                  },
                  child: const Text("Add Route"),
                )
              ],
            ),
            Divider(),
            SizedBox(
                height: 100,
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _fetchRouteDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No routes found.'));
                    } else {
                      List<Map<String, dynamic>> routes = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          var route = routes[index];
                          String routeId = route['routeId'];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RoutesPage(routeId: routeId),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 3.0),
                              width: 200,
                              padding: EdgeInsets.all(6),
                              height: 70,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: const Color.fromARGB(
                                        255, 121, 121, 121)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Text(" ${route['from']} >>> ${route['to']}"),
                                      verticalTextTIle(
                                        title: "From",
                                        content: "${route['from']} ",
                                      ),
                                      verticalTextTIle(
                                        title: "To",
                                        content: "${route['to']} ",
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Text(" ${route['from']} >>> ${route['to']}"),
                                      verticalTextTIle(
                                        title: "depature status",
                                        content: "${route['depatureStatus']} ",
                                      ),
                                      verticalTextTIle(
                                        title: "A/capacity",
                                        content:
                                            "${route['remainingSpace']} Ton",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ))
          ],
        ),
      ),
    );
  }
}

class RequestBox extends StatelessWidget {
  final int isSelectedIndex;
  final int index;
  final Function()? ontap;
  const RequestBox({
    super.key,
    required this.isSelectedIndex,
    required this.index,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      height: (isSelectedIndex == index) ? 160 : 70,
      decoration: const BoxDecoration(
          // color: Colors.red,
          ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            width: double.infinity,
            height: 70,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 243, 244, 245),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalTextTIle(
                      title: "orderNo",
                      content: "47CFC4P2MJKWPTCRFYICM",
                    ),
                    Row(
                      children: [
                        Text(
                          "Dar es salaam",
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          " >>> ",
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          "Mbeya",
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    )
                  ],
                ),
                IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: ontap,
                  icon: const Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
          (isSelectedIndex == index)
              ? Container(
                  width: double.infinity,
                  height: 90,
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 226, 226, 226),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          verticalTextTIle(
                            title: "package type",
                            content: "Electronics",
                          ),
                          verticalTextTIle(
                            title: "package size",
                            content: "40X40",
                          ),
                          verticalTextTIle(
                            title: "amount",
                            content: "16000 Tsh",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          verticalTextTIle(
                            title: "Expires",
                            content: "00:34:20",
                          ),
                          verticalTextTIle(
                            title: "contact",
                            content: "+255768543214",
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}

class verticalTextTIle extends StatelessWidget {
  final String title;
  final String content;
  const verticalTextTIle({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          content,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class DrawerTile extends StatelessWidget {
  final String title;
  final Function() ontap;
  final IconData icon;
  const DrawerTile({
    super.key,
    required this.title,
    required this.ontap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.orange,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(title),
            )
          ],
        ),
      ),
    );
  }
}
