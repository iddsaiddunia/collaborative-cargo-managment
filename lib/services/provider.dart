import 'package:flutter/material.dart';


class UserProvider extends ChangeNotifier {
late String _userId ="";

  String get userId => _userId;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }
}