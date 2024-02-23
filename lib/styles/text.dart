import 'package:flutter/material.dart';

const TextStyle downloadButtonTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 20,
);

const TextStyle validPasteButtonTextStyle = TextStyle(
  color: Colors.red,
);

TextStyle inValidPasteButtonTextStyle = validPasteButtonTextStyle.copyWith(
  backgroundColor: Colors.orange[100],
);
