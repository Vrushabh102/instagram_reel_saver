import 'dart:convert';

import 'package:http/http.dart';

class Fetch {

  String? queryUrl;
  // Constructor to pass query url whenever Fetch instance is created
  Fetch({required this.queryUrl});

  // api endpoint
  Uri url = Uri.parse('https://instagram-media-downloader.p.rapidapi.com/rapid/post.php');

  // url after modifying api endpoint uri with queryParameter
  String? finalUrl;


  // function to get finalUrl
  Future<dynamic> fetchData() async {
    var headers = {
      'X-RapidAPI-Key': '350002b5d7msh673950fc8435f77p1f534fjsnc816888bdd05',
      'X-RapidAPI-Host': 'instagram-media-downloader.p.rapidapi.com'
    };
    var params = {'url' : queryUrl};

    try {
      Response response = await get(url.replace(queryParameters: params), headers: headers);
      if(response.statusCode == 200) {
        var data = jsonDecode(response.body);
        finalUrl = data['video'];
      }
    } catch(error) {
        finalUrl = 'some error has occurred';
    }
  }
}