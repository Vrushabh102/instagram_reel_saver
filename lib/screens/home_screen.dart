import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_reel_saver/services/Fetch.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:instagram_reel_saver/styles/button.dart';
import 'package:instagram_reel_saver/styles/text.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:instagram_reel_saver/styles/input_decoration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    implements WidgetsBindingObserver {
  String? url;
  String? linkThroughListener;

  // to track the download progress
  double? _progress;

  bool showPasteButtonOrNot = false;

  ClipboardData? data;
  bool isClipBoardNull = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    getClipboardData();

    ReceiveSharingIntent.getInitialMedia().then((value) {
      setState(() {
        try {
          linkThroughListener = value[0].path.toString();

          // pass the link to the textFormField if link is received from receive sharing intent
          if (linkThroughListener != null) {
            _controller.text = linkThroughListener!;
          }
        }
        catch(error) {
          // do nothing
        }
        ReceiveSharingIntent.reset();
      });
    });
  }

  getClipboardData() async {
    data = await Clipboard.getData('text/plain');
    if (data != null) {
      setState(() {
        showPasteButtonOrNot = true;
      });
    }
  }

  Widget showPasteButton(String url, BuildContext context) {
    isClipBoardNull = (data != null);
    return ElevatedButton(
      onPressed: isClipBoardNull
          ? () {
              setState(() {
                _controller.text = url;
              });
            }
          : null,
      style: isClipBoardNull ? validPasteButtonStyle : inValidPasteButtonStyle,
      child: const Icon(
        Icons.paste_rounded,
        color: Colors.white,
      ),
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
              _buildFirstRow(context);
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

  Widget _buildFirstRow(BuildContext context) {
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
          IconButton(
            onPressed: () async {
              setState(() {
                _controller.text = '';
              });
            },
            style: downloadButtonStyle.copyWith(
                minimumSize: MaterialStatePropertyAll(
              Size(MediaQuery.of(context).size.width * 0.18,
                  MediaQuery.of(context).size.height * 0.065),
            )),
            icon: const Icon(
              Icons.clear,
              color: Colors.white,
            ),
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
        _progress = null;
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

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    await getClipboardData();
    setState(() {
      _controller.text = _controller.text;
    });
  }

  // Main Build Function
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        // todo appbar customizations
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
            _buildFirstRow(context),

            if (data != null)
              // paste button to paste text from pasted from the clipboard
              showPasteButton(data!.text.toString(), context),
            const SizedBox(
              height: 10,
            ),

            // download button with validation
            _progress != null
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      ClipboardData? data =
                          await Clipboard.getData('text/plain');
                      if (data != null) {
                      }
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        String downloadableUrl =
                            await _downloadData(_controller.text);
                        // function to download the video
                        downloadVideo(downloadableUrl);
                      }
                    },
                    // using buttonStyle from created styles
                    style: downloadButtonStyle.copyWith(
                        minimumSize: MaterialStatePropertyAll(
                            Size(width * 0.9, height * 0.06))),

                    child: const Text(
                      'Download',
                      //style: TextStyle(fontSize: 20, color: Colors.white),
                      style: downloadButtonTextStyle,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() {
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    throw UnimplementedError();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    throw UnimplementedError();
  }
}
