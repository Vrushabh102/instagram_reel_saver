import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_reel_saver/services/Fetch.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:instagram_reel_saver/interface/inputdecoration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? url;
  String? linkThroughListener;

  // to track the download progress
  double? _progress;

  bool showPasteButtonOrNot = false;
  bool isClipboardTextValid = false;


  ClipboardData? data;

  @override
  void initState()  {
    super.initState();


    getClipboardData();

    ReceiveSharingIntent.getInitialMedia().then((value) {
      setState(() {
        try {
          linkThroughListener = value[0].path.toString();

          // pass the link to the textFormField if link is received from receive sharing intent
          if (linkThroughListener != null) {
            _controller.text = linkThroughListener!;
          }
        } catch (error) {
          print('received intent sharing error $error');
        }

        ReceiveSharingIntent.reset();
      });
    });
  }

  bool validateCLipBoardUri(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    } else {
      Uri? uri = Uri.tryParse(value);
      if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
        return false;
      } else if (!value.contains('www.instagram.com') ||
          !value.contains('reel')) {
        return false;
      }
    }
    return true;
  }

  void getClipboardData() async {
    data = await Clipboard.getData('text/plain');
    if(data != null) {
      setState(() {
        showPasteButtonOrNot = true;
        print('clipboard data printed ${data!.text}');
        isClipboardTextValid = validateCLipBoardUri(data!.text);
      });
    }
  }


  Widget showPasteButton(String url) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _controller.text = url;
        });
      },
      child: const Icon(Icons.paste_rounded),
    );
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // form key
  var formKey = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();
  Widget _buildTextFormField() {
    // Instance of Ui clas to build the ui for InputTextField
    Ui buildUi = Ui();
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextFormField(
          controller: _controller,
          decoration: buildUi.buildInputDecoration(),
          onChanged: (value) {
            setState(() {
              _buildFirstRow();
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please provide a link.';
            } else {
              Uri? uri = Uri.tryParse(value);
              if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
                return 'Invalid URL';
              } else if (!value.contains('www.instagram.com') ||
                  !value.contains('reel')) {
                return 'Please provide a valid Instagram reel link.';
              }
            }
            return null;
          },
          onSaved: (value) {
            url = value;
          },
        ),
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
        )),
        if (_controller.text != '')
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _controller.text = '';
              });
            },
            child: const Icon(Icons.clear),
          ),
      ],
    );
  }

  // return string url of the downloadable video file
  Future<String> _downloadData(String link) async {
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
        showSnackbar('Downloaded at $path');
        setState(() {
          _progress = null;
        });
      },
      name: defaultFileName,
      onProgress: (fileName, progress) {
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
        title: const Text(
          'Reel Saver',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2),
        ),
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
        color: Colors.white38,
        padding: const EdgeInsets.all(10),

        // parent column
        child: Column(
          children: [
            // Row for TextFormField
            _buildFirstRow(),

            if(showPasteButtonOrNot && isClipboardTextValid) showPasteButton(data!.text.toString()),
            // validation button
            _progress != null ? const CircularProgressIndicator() : ElevatedButton(
              onPressed: () async {
                print('heeeefjdlkfjdklfjkldfjkldjlfk');
                ClipboardData? data = await Clipboard.getData('text/plain');
                if (data != null) {
                  print(data.text);
                }
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  String downloadableUrl =
                      await _downloadData(_controller.text);
                  // function to download the video
                  downloadVideo(downloadableUrl);
                }
              },
              child: const Text(
                'Download',
                style: TextStyle(fontSize: 20),
              ),
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