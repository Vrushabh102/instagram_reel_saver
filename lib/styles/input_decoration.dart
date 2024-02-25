import 'package:flutter/material.dart';

InputDecoration buildInputDecoration(BuildContext context) {
  return InputDecoration(
    hintText: 'Enter Url',
    hintStyle: TextStyle(
        letterSpacing: 1.6,
        fontFamily: 'Urbanist',
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white),
    contentPadding: const EdgeInsets.fromLTRB(25, 18, 25, 18),
    fillColor: Colors.amber,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.pink,
        width: 2,
      ),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(255, 166, 92, 115),
        width: 1.4,
      ),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  );
}
