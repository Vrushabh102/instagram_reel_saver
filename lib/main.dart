import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:instagram_reel_saver/screens/HomeScreen.dart';

void main(){
  runApp(
      const MaterialApp(
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
    )
  );
}

class Api {
  void getData2() async {
    const uri = 'https://andruxnet-random-famous-quotes.p.rapidapi.com/?cat=movies&count=10';
    final url = Uri.parse(uri);
    Response response = await get(url);
    print(response.body);
  }
}
