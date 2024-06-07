import 'package:collaborative_cargo_managment_app/auth/request.dart';
import 'package:collaborative_cargo_managment_app/auth/routes.dart';
import 'package:collaborative_cargo_managment_app/color_themes.dart';
import 'package:collaborative_cargo_managment_app/services/auth.dart';
import 'package:collaborative_cargo_managment_app/wrapper.dart';
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

  _openRequest(int selectedIndex) {
    setState(() {
      _selectedIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DHL Logistics",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                    DrawerTile(
                      title: "Profile",
                      ontap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ProfilePage(),
                        //   ),
                        // );
                      },
                      icon: Icons.person_3_outlined,
                    ),
                    DrawerTile(
                      title: "Vehicles",
                      ontap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => TargetsPage(),
                        //   ),
                        // );
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
                  "2024@ Pefa All rights reserved",
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
                Container(
                  width: MediaQuery.of(context).size.width / 2.1,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "976",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Total requests",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 230, 230, 230),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.1,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "9",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Total routes",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 230, 230, 230),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Column(
              children: [
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestPage(),
                          ),
                        );
                      },
                      child: const Text("view all"),
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 400,
                  // color: Colors.amber,
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
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
                                color: Color.fromARGB(255, 243, 244, 245),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    onPressed: () {
                                      _openRequest(index);
                                    },
                                    icon: const Icon(Icons.arrow_drop_down),
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
                                      color: Color.fromARGB(255, 226, 226, 226),
                                    ),
                                    child: const Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                    },
                  ),
                ),
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
                            builder: (context) => RoutesPage(),
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
                  child: ListView.builder(
                    itemCount: 4,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 3.0),
                        width: 200,
                        padding: EdgeInsets.all(6),
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: const Color.fromARGB(255, 121, 121, 121)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6.0),
                          ),
                        ),
                        child: Row(
                          children: [],
                        ),
                      );
                    },
                  ),
                )
              ],
            )
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
