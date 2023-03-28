import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inmusic/core/services/api_service.dart';
import 'package:inmusic/core/services/music_service.dart';
import 'package:inmusic/core/services/search_provider.dart';
import 'package:inmusic/ui/viewmodels/downloader.dart';
import 'package:inmusic/ui/views/app.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.bin.inmusic',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }
  await Hive.initFlutter();
  await Hive.openBox('myfavourites');
  await Hive.openBox('settings');
  await Hive.openBox('search_history');
  await Hive.openBox('song_history');
  await Hive.openBox('downloads');
  await ApiService.setCountry();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => MusicPlayer()),
    ChangeNotifierProvider(create: (_) => SearchProvider()),
    ChangeNotifierProvider(create: (_) => DownloadManager()),
  ], child: const MyApp()));
}
