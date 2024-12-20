import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController mycontroller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;

  const MyTextField({
    super.key,
    required this.mycontroller,
    required this.hintText,
    required this.obscureText,
    this.keyboardType = TextInputType.text
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: mycontroller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          fillColor: const Color(0xFFEEEEEE),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
