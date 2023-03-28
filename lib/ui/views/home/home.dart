// import 'dart:developer';

import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inmusic/core/models/artist.dart';
import 'package:inmusic/core/models/playlist.dart';
import 'package:inmusic/core/models/thumbnail.dart';
import 'package:inmusic/core/models/track.dart';
import 'package:inmusic/core/services/api_service.dart';
import 'package:inmusic/core/services/music_service.dart';
import 'package:inmusic/core/utils/connectivity.dart';
import 'package:inmusic/core/utils/showOptions.dart';
import 'package:inmusic/ui/views/home/component/playlist.dart';
import 'package:inmusic/ui/views/home/component/thumbnail.dart';
import 'package:inmusic/ui/views/search/search.dart';
import 'package:inmusic/ui/widgets/error_connection.dart';
import 'package:inmusic/ui/widgets/track_tile.dart';
import 'package:provider/provider.dart';

import 'component/history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  List? head = [];
  List<PlaylistModel> body = [];
  List recommendations = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    isConnectivity().then((value) {
      if (value) {
        getHomeData();
      }
    });
  }

  Future getHomeData() async {
    bool connected = await isConnectivity();
    if (!connected) {
      return;
    }
    Map home = await ApiService().getMusicHome();
    List recommend = await getRelated();
    setState(() {
      head = home['head'];
      body = home['body'];
      recommendations = recommend;
      isLoading = false;
    });
  }

  getRelated() async {
    List boxList = Hive.box('song_history').values.toList();
    if (boxList.isEmpty) {
      return List.empty();
    }
    boxList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    List newList =
        boxList.getRange(0, boxList.length > 20 ? 20 : boxList.length).toList();
    newList.sort((a, b) => b['hits'].compareTo(a['hits']));
    math.Random rand = math.Random();
    int index = rand.nextInt(newList.length > 10 ? 10 : boxList.length);
    return await ApiService.getWatchPlaylist(boxList[index]['videoId'], 20);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: kToolbarHeight,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      "in Music",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: isConnectivity(),
          builder: (context, snapshot) {
            if (snapshot.hasData && !(snapshot.data!)) {
              return ErrorConnection(update: () {
                setState(() {
                  isLoading = true;
                });
                getHomeData();
              });
            }
            return isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: getHomeData,
                          color: Colors.green,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: SafeArea(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // if (head != null) ThumbnailHome(head!),
                                  HistoryHome(),
                                  if (body.isNotEmpty)
                                    ...body.map(
                                      (item) {
                                        String title = item.title;
                                        List content = item.playlists;
                                        bool areSongs = content.isNotEmpty
                                            ? content.first['videoId'] != null
                                            : false;

                                        return content.isEmpty
                                            ? const SizedBox.shrink()
                                            : PlaylistHome(
                                                title: title,
                                                content: content,
                                                areSongs: areSongs,
                                              );
                                      },
                                    ).toList()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
