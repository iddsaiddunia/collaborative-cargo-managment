import 'package:collaborative_cargo_managment_app/auth/home.dart';
import 'package:collaborative_cargo_managment_app/nonAuth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// class Wrapper extends StatelessWidget {
//   final bool isSignedIn;
//   const Wrapper({super.key, required this.isSignedIn});

//   @override
//   Widget build(BuildContext context) {
//     if (isSignedIn) {
//       return const HomePage();
//     } else {
//       return const LoginPage();
//     }
//   }
// }

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')));
        }

        if (snapshot.data == null) {
          return Wrapper(isSignedIn: false);
        }

        return Wrapper(isSignedIn: true);
      },
    );
  }
}

class Wrapper extends StatelessWidget {
  final bool isSignedIn;
  const Wrapper({Key? key, required this.isSignedIn}) : super(key: key);

  Future<bool> isDriver(String uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Operators')
        .where('operatorID', isEqualTo: uid)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!isSignedIn) {
      return const LoginPage();
    }

    return FutureBuilder<bool>(
      future: isDriver(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.data!) {
          return Scaffold(
              body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Text('Only for Companies operators ')),
              MaterialButton(
                  color: Colors.blue,
                  child: Text("Go Back"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  })
            ],
          ));
        }

        return HomePage();
      },
    );
  }
}
