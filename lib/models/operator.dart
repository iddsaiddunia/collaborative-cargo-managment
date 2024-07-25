import 'package:cloud_firestore/cloud_firestore.dart';

class Operator {
  final String companyID;
  final String operatorID;
  final String email;
  final String operatorName;
  final String phone;
  final String role;

  Operator({
    required this.companyID,
    required this.operatorID,
    required this.email,
    required this.operatorName,
    required this.phone,
    required this.role,
  });

  factory Operator.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Operator(
      companyID: data['companyID'],
      operatorID: data['operatorID'],
      email: data['email'],
      operatorName: data['operatorName'],
      phone: data['phone'],
      role: data['role'],
    );
  }
}
