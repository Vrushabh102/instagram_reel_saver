import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_reel_saver/services/Fetch.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:instagram_reel_saver/styles/button.dart';
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
  bool isClipBoardNull = true;

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
        } catch (error) {
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
        isClipBoardNull = false;
      });
    }
  }

  Widget showPasteButton(BuildContext context) {
    return ElevatedButton(
        onPressed: showPasteButtonOrNot
            ? () {
                setState(() {
                  _controller.text = data!.text.toString();
                });
              }
            : null,
        style: isClipBoardNull
            ? invalidPasteButtonStyle(context).copyWith(
                backgroundColor: MaterialStatePropertyAll(
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[300]
                        : Colors.grey[400]))
            : validPasteButtonStyle(context),
        child: const Text(
          'PASTE',
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
              fontFamily: 'Urbanist',
              fontSize: 16),
        ));
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: const EdgeInsets.fromLTRB(25, 16, 16, 16),
        decoration: const BoxDecoration(
          color: const Color.fromARGB(255, 225, 54, 111),
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ));
  }

  // form key
  var formKey = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();
  Widget _buildTextFormField() {
    // Instance of Ui clas to build the ui for InputTextField
    return Form(
      key: formKey,
      child: TextFormField(
        controller: _controller,
        decoration: buildInputDecoration(context).copyWith(
            suffixIcon: _controller.text != ''
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _controller.text = '';
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ))
                : null),
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
    );
  }

  Widget _buildFirstRow() {
    return Row(
      children: [
        // TextInputField
        Expanded(
            child: Container(
          margin: const EdgeInsets.all(4),
          child: _buildTextFormField(),
        )),
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
    FileDownloader.downloadFile(
      url: downloadableUrl,
      onDownloadError: (String error) {
        showSnackbar('Error');
        _progress = null;
      },
      onDownloadCompleted: (String path) {
        showSnackbar('Downloaded Successfully');
        setState(() {
          _progress = null;
        });
      },
      name: DateTime.now().microsecondsSinceEpoch.toString(),
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
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 225, 54, 111),
        title: const Text(
          'Instagram Reel Saver',
          style: TextStyle(
              fontFamily: 'Urbanist',
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : const Color.fromARGB(255, 18, 17, 17),
        padding: const EdgeInsets.all(10),

        // parent column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Row for TextFormField
            _buildFirstRow(),

            const SizedBox(height: 10),
            // paste button to paste text from pasted from the clipboard
            showPasteButton(context),
            const SizedBox(height: 15),

            // download button with validation
            _progress != null
                ? const CircularProgressIndicator(
                    color: const Color.fromARGB(255, 202, 75, 118))
                : ElevatedButton(
                    onPressed: () async {
                      ClipboardData? data =
                          await Clipboard.getData('text/plain');
                      if (data != null) {}
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();

                        String downloadableUrl =
                            await _downloadData(_controller.text);
                        // function to download the video
                        downloadVideo(downloadableUrl);
                      }
                    },
                    // using buttonStyle from created styles
                    style: downloadButtonStyle(context),
                    child: const Text(
                      'DOWNLOAD',
                      //style: TextStyle(fontSize: 20, color: Colors.white),
                      style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontSize: 15),
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
