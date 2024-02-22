import 'package:flutter/material.dart';

class Ui {
  InputDecoration buildInputDecoration() {
    return const InputDecoration(
      hintText: 'Enter Url',
      hintStyle: TextStyle(letterSpacing: 1.6, fontFamily: 'Urbanist'),
      contentPadding: EdgeInsets.fromLTRB(25, 20, 25, 20),
      fillColor: Colors.amber,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.orange,
          width: 2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.green,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}
