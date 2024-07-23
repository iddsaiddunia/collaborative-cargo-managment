import 'package:collaborative_cargo_managment_app/services/auth.dart';
import 'package:collaborative_cargo_managment_app/services/provider.dart';
import 'package:collaborative_cargo_managment_app/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

AuthService auth = AuthService();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  int selectedIndex = 0;

  // Future<void> authenticateUser() async {
  //   // Simulate a login request
  //   setState(() {
  //     isLoading = true;
  //   });

  //   await Future.delayed(Duration(seconds: 2)); // Simulate network delay

  //   // Replace this with your actual authentication logic
  //   if (emailController.text == 'user@mail.com' &&
  //       passwordController.text == '1234') {
  //     // Authentication successful, navigate to the next page
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => Wrapper(
  //           isSignedIn: true,
  //         ),
  //       ),
  //     );
  //   } else {
  //     // Authentication failed, show an error message
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Authentication Failed'),
  //           content: Text('Invalid username or password.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: ListView(children: [
        Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 3.3,
            color: Colors.transparent),
        SizedBox(
          height: 20.0,
        ),
        Text(
          "Login",
          style: TextStyle(fontSize: 26),
        ),
        Text(
          "Please Sign in to continue.",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 20.0,
        ),
        Container(
          width: double.infinity,
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: "Email",
                border: InputBorder.none),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 55.0,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: "Password",
                border: InputBorder.none),
          ),
        ),
        Align(
            alignment: Alignment.centerRight, child: Text("forgot password?")),
        SizedBox(height: 30),
        GestureDetector(
          onTap: () {
            _logIn(userProvider);
          },
          child: Container(
            width: double.infinity,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.red[200],
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            child: Center(
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      )
                    : Text(
                        "Sign In",
                        style: TextStyle(fontSize: 17),
                      )),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        // Center(
        //   child: GestureDetector(
        //     onTap: () {
        //       // Navigator.push(
        //       //   context,
        //       //   MaterialPageRoute(builder: (context) => RegistrationPage()),
        //       // );
        //     },
        //     child: Text(
        //       "Don't have an account?Sign Up",
        //       style: TextStyle(fontSize: 16),
        //     ),
        //   ),
        // ),
      ]),
    ));
  }

  _logIn(UserProvider userProvider) async {
    // Simulate a login request
    setState(() {
      isLoading = true;
    });

    // await Future.delayed(Duration(seconds: 2));

    // Replace this with your actual authentication logic
    if (emailController.text != '' || passwordController.text != '') {
      // Authentication successful, navigate to the next page
      final user = await auth.signInUser(
          emailController.text, passwordController.text, userProvider);
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Wrapper(
              isSignedIn: true,
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Authentication failed, show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Authentication Failed'),
            content: Text('Invalid username or password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
