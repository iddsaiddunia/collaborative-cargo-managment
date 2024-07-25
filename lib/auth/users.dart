import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collaborative_cargo_managment_app/models/operator.dart';
import 'package:collaborative_cargo_managment_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  final String companyID;

  UsersPage({required this.companyID});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  Stream<List<Operator>> fetchUsersByCompany(String companyID) {
  return FirebaseFirestore.instance
      .collection('Operators')
      .where('companyID', isEqualTo: companyID)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Operator.fromDocument(doc)).toList());
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: StreamBuilder<List<Operator>>(
        stream: fetchUsersByCompany(widget.companyID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users available'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.operatorName),
                subtitle: Text(user.email),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddUserDialog(companyID: widget.companyID),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class AddUserDialog extends StatefulWidget {
  final String companyID;

  AddUserDialog({required this.companyID});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String operatorName = '';
  String phone = '';
  String role = 'normal';

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: 'password123', // Note: use a secure method for passwords
        );

        await FirebaseFirestore.instance
            .collection('Operators')
            .doc(userCredential.user!.uid)
            .set({
          'companyID': widget.companyID,
          'email': email,
          'operatorID': userCredential.user!.uid,
          'operatorName': operatorName,
          'phone': phone,
          'role': role,
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User created successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to create user: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
              onSaved: (value) {
                email = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                operatorName = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Phone'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
              onSaved: (value) {
                phone = value!;
              },
            ),
            ElevatedButton(
              onPressed: _createUser,
              child: Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }
}
