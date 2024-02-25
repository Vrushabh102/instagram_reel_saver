import 'package:flutter/material.dart';

ButtonStyle clearButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
      minimumSize: Size(MediaQuery.of(context).size.width * 0.15,
          MediaQuery.of(context).size.height * 0.065),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey
          : Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ));
}

ButtonStyle downloadButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
      textStyle:
          const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
      backgroundColor: Color.fromARGB(255, 225, 54, 111),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
      minimumSize: Size(MediaQuery.of(context).size.width * 0.88,
          MediaQuery.of(context).size.height * 0.06));
}

ButtonStyle validPasteButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[600]
          : const Color.fromARGB(255, 49, 47, 47),
      elevation: 0,
      minimumSize: Size(MediaQuery.of(context).size.width * 0.88,
          MediaQuery.of(context).size.height * 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(34),
      ));
}

ButtonStyle invalidPasteButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: Size(MediaQuery.of(context).size.width * 0.88,
          MediaQuery.of(context).size.height * 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(34),
      ));
}
