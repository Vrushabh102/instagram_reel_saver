import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instagram_reel_saver/services/Downloader.dart';
import 'package:instagram_reel_saver/services/Fetch.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription _intentSubscription;

  final _files = <SharedMediaFile>[];
  String? url = '';
  String? downloaderUri;

  // form key
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // receiving url while app is opened
    _intentSubscription =
        ReceiveSharingIntent.getMediaStream().listen((event) {
          setState(() {
            _files.clear();
            _files.addAll(event);
            url = _files[0].path.toString();
          });
        },
          onError: (error) {
      });

    // receiving url when app is closed
    ReceiveSharingIntent.getInitialMedia().then((value){
      setState(() {
        _files.clear();
        _files.addAll(value);
        url = _files[0].path.toString();
      });
    });
    ReceiveSharingIntent.reset();

  }

  @override
  void dispose() {
    _intentSubscription.cancel();
    super.dispose();
  }

  Widget _buildTextFormField() {
    return TextFormField(
      decoration: const InputDecoration(
            hintText: 'Enter Url',
            contentPadding: EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.orange,
                width: 10,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            )
        ),
      controller: TextEditingController(text: url),
      validator: (value) {
        if(value == null || value.isEmpty) {
          return 'Paste the Video Link';
        } else if(true) {
          //Todo: url validation
        }
        return null;
      },
      onSaved: (value) {
        url = value;
      },
    );
  }

  Widget _buildFirstRow() {
    return Row(
      children: [
        // TextInputField
        Expanded(
            child: Container(
              width: 385,
              margin: const EdgeInsets.all(4),
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: _buildTextFormField(), // TextFormField for entering url
                ),
              ),
            )
        ),
      ],
    );
  }

  // return string url of the downloadable video file
  Future<String> _downloadData() async{
    // this function will only be called when the link provided is valid
    Fetch fetchInstance = Fetch(queryUrl: url);
    await fetchInstance.fetchData();
    String? downloadUrl = fetchInstance.finalUrl;
    return downloadUrl.toString();
  }

  // Main Build Function
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reel Saver',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 1.2),),
        backgroundColor: Colors.red[600],
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.black,
            height: 1,
          ),
        ),
      ),

      body: Container(
        color: Colors.white24,

        padding: const EdgeInsets.all(16),

        // parent column
        child: Column(
          children: [

            // Row for TextFormField
            _buildFirstRow(),

            // validation button
            ElevatedButton(
              onPressed: () async {
                  if(formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    String downloadableUrl = await _downloadData();
                    // function to download the video
                    Downloader downloaderInstance = Downloader(url: downloadableUrl);
                    downloaderInstance.downloadVideo();
                  }
              },
              child: const Text('Download',style: TextStyle(fontSize: 30),),
            ),

          ],
        ),
      ),
    );
  }
}

