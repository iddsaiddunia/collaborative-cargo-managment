
import 'package:collaborative_cargo_managment_app/services/auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authServices = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _operatorNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Enter a password 6+ chars long' : null,
              ),
              TextFormField(
                controller: _operatorNameController,
                decoration: InputDecoration(labelText: 'Operator Name'),
                validator: (value) => value!.isEmpty ? 'Enter the operator name' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) => value!.isEmpty ? 'Enter the phone number' : null,
              ),
              TextFormField(
                controller: _companyIDController,
                decoration: InputDecoration(labelText: 'Company ID'),
                validator: (value) => value!.isEmpty ? 'Enter the company ID' : null,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await _authServices.registerUser(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        operatorName: _operatorNameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        companyID: _companyIDController.text.trim(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User registered successfully')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register user: $e')));
                    }
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
