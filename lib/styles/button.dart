import 'package:flutter/material.dart';

final ButtonStyle downloadButtonStyle = ElevatedButton.styleFrom(
  textStyle: const TextStyle(
    fontFamily: 'Urbanist',
  ),
  backgroundColor: Colors.orange,
  elevation: 0,
);

final ButtonStyle validPasteButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.orange,
  elevation: 0,
);

final ButtonStyle inValidPasteButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.orange[100],
  elevation: 0,
);
