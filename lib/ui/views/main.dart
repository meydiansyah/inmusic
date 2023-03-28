import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inmusic/core/services/music_service.dart';
import 'package:inmusic/ui/views/home/home.dart';
import 'package:inmusic/ui/views/player/player.dart';
import 'package:inmusic/ui/widgets/panel_header.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // final PageController _pageController = PageController(initialPage: 0);
  // final _homeNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    context.read<MusicPlayer>().player.stop();
    context.read<MusicPlayer>().player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
        builder: (context, Box box, child) {
          return Scaffold(
            body: LayoutBuilder(builder: (context, constraints) {
              return Column(
                children: [
                  const Expanded(
                    child: HomeScreen(),
                  ),
                  if (context.watch<MusicPlayer>().isInitialized &&
                      context.watch<MusicPlayer>().song != null)
                    Miniplayer(
                        backgroundColor: Colors.black,
                        controller:
                            context.watch<MusicPlayer>().miniplayerController,
                        minHeight: 70,
                        maxHeight: constraints.maxHeight,
                        builder: (height, percentage) {
                          return Stack(
                            children: [
                              Opacity(
                                opacity: percentage,
                                child: const PlayerScreen(),
                              ),
                              Opacity(
                                  opacity: 1 - (percentage),
                                  child: PanelHeader(
                                    song: context.watch<MusicPlayer>().song!,
                                  )),
                            ],
                          );
                        }),
                ],
              );
            }),
          );
        });
  }
}
