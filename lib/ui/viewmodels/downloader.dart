import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inmusic/core/models/track.dart';
import 'package:inmusic/core/provider/downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart';

class DownloadManager extends ChangeNotifier {
  Map items = {};
  Map<String, ChunkedDownloader> managers = {};
  String path = "/storage/emulated/0/Music/";

  getSong(videoId) => items[videoId];
  ChunkedDownloader? getManager(videoId) => managers[videoId];
  get getSongs => items.values.toList();

  Future<bool> requestPermission() async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }
    if (status.isDenied) {
      await [
        Permission.storage,
      ].request();
    }
    status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }
    log('Request permanently denied');
    await openAppSettings();
    status = await Permission.storage.status;

    return Permission.storage.status.isGranted;
  }

  download(Track song) async {
    print("development . . .");
  }

  static Future<Map?> getAudioUri(String videoId) async {
    Box box = Hive.box('settings');
    String audioQuality = box.get("audioQuality", defaultValue: 'medium');
    String audioUrl = '';
    try {
      YoutubeExplode _youtubeExplode = YoutubeExplode();
      final StreamManifest manifest =
          await _youtubeExplode.videos.streamsClient.getManifest(videoId);
      List<AudioStreamInfo> audios = manifest.audioOnly.sortByBitrate();

      int audioNumber = audioQuality == 'low'
          ? 0
          : (audioQuality == 'high'
              ? audios.length - 1
              : (audios.length / 2).floor());
      var item = audios[audioNumber];

      audioUrl = audios[audioNumber].url.toString();
      String extension = item.container.name;

      return {'url': audioUrl, 'extension': extension};
    } catch (e) {
      return null;
    }
  }
}
