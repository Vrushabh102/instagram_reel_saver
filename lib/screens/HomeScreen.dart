import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instagram_reel_saver/services/Fetch.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Color bgcolor = Colors.white24;
  bool _useListenerLink = false;

  String? url;
  String? linkThroughListener;

  // to track the download progress
  double? _progress;


  @override
  void initState() {
    super.initState();
    print('initState started');


    ReceiveSharingIntent.getInitialMedia().then((value) {
      setState(() {

        try {
          linkThroughListener = value[0].path.toString();
          print('url $url');
          print('value is ${value[0].path}');

          // pass the link to the textFormField if link is received from receive sharing intent
          if(linkThroughListener != null) {
            _controller.text = linkThroughListener!;
          }
        } catch(error) {
          print('error occured $error');
        }

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.reset();
      });
    });
  }

  void showSnackbar(String message) {
    print('showsnackbar called');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  // form key
  var formKey = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();
  Widget _buildTextFormField() {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextFormField(
          controller: _controller,
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
          onChanged: (value) {
            _useListenerLink = false;
          },
          validator: (value) {

            print('value is $value');
            if (value == null || value.isEmpty) {
              return 'Please provide a link.';
            } else {
              Uri? uri = Uri.tryParse(value);
              if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
                return 'Invalid URL';
              } else if (!value.contains('www.instagram.com') || !value.contains('reel')) {
                return 'Please provide a valid Instagram reel link.';
              }
            }
            return null;
          },
          onSaved: (value) {
            url = value;
            print('onsaved $url');
          },
        ), // TextFormField for entering url
      ),
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
              child: _buildTextFormField(),
            )
        ),
      ],
    );
  }

  // return string url of the downloadable video file
  Future<String> _downloadData(String link) async{
    // this function will only be called when the link provided is valid
    Fetch fetchInstance = Fetch(queryUrl: link);
    await fetchInstance.fetchData();
    String? downloadUrl = fetchInstance.finalUrl;
    return downloadUrl.toString();
  }

  // function to download the video from provided url
  void downloadVideo(String downloadableUrl) {
    String defaultFileName = 'Instagram Reel';

    FileDownloader.downloadFile(
      url: downloadableUrl,
      onDownloadError: (String error) {
        showSnackbar('Error');
      },
      onDownloadCompleted: (String path) {
        print('download completed');
        showSnackbar('Downloaded at $path');
        setState(() {
          _progress = null;
        });
      },
      name: defaultFileName,
      onProgress: (fileName, progress) {
        print('progress is $progress');
        setState(() {
          _progress = progress;
        });
      },
      notificationType: NotificationType.all,
    );
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
        color: bgcolor,
        padding: const EdgeInsets.all(10),

        // parent column
        child: Column(
          children: [
            // Row for TextFormField
            _buildFirstRow(),
            // validation button
            _progress != null ? const CircularProgressIndicator() : ElevatedButton(
              onPressed: () async {

                  if(formKey.currentState!.validate()) {
                    formKey.currentState!.save();

                    String downloadableUrl = await _downloadData(_controller.text);
                    // function to download the video
                    downloadVideo(downloadableUrl);
                  }
              },
              child: const Text('Download',style: TextStyle(fontSize: 20),),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}