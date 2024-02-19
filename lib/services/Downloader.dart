import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class Downloader {

  String url;
  String? downloadedFileName;
  String defaultFileName = 'Instagram Reel';

  Downloader({required this.url, this.downloadedFileName});

  // function to download the video using flutter_file_downloader package
  void downloadVideo() {
    FileDownloader.downloadFile(
      url: url,
      onDownloadError: (String error) {
      },
      onDownloadCompleted: (String path) {
        //todo crete a notification or snackBar
      },
      name: downloadedFileName ?? defaultFileName
    );
  }
}