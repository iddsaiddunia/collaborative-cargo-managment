import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  final String orderNo;
  const RequestPage({super.key, required this.orderNo});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(widget.orderNo),
        ],
      ),
    );
  }
}
