import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inmusic/core/services/api_service.dart';
import 'package:inmusic/core/services/music_service.dart';
import 'package:inmusic/core/services/search_provider.dart';
import 'package:inmusic/ui/widgets/track_tile.dart';
import 'package:provider/provider.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen(
      {required this.playlistId, this.isAlbum = false, super.key});
  final String playlistId;
  final bool isAlbum;

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  Map? playlist;
  bool loading = true;
  @override
  void initState() {
    super.initState();

    if (widget.isAlbum) {
      ApiService.getAlbum(widget.playlistId).then((Map value) {
        setState(() {
          playlist = value;

          playlist?['tracks']
              .removeWhere((element) => element['videoId'] == null);
          loading = false;
        });
      });
    } else {
      YTMUSIC.getPlaylistDetails(widget.playlistId).then((value) {
        setState(() {
          playlist = jsonDecode(jsonEncode(value));
          playlist?['tracks']
              .removeWhere((element) => element['videoId'] == null);
          loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: kToolbarHeight,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    BackButton(
                      color: Colors.white,
                    ),
                    Text(
                      playlist?['title'] ?? "",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: playlist == null || loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green))
            : SingleChildScrollView(
                // physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: playlist?['thumbnails'][
                                  (playlist?['thumbnails'].length / 2)
                                      .floor()]['url'],
                              width: (size.width / 2) - 24,
                              height: (size.width / 2) - 24,
                              errorWidget: ((context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/playlist.png",
                                  width: (size.width / 2) - 24,
                                  height: (size.width / 2) - 24,
                                );
                              }),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlist?['title'],
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  Text(
                                    '${playlist?['tracks'].length} songs',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyMedium,
                                  ),
                                  Text(
                                    playlist?['author']?['name'] ??
                                        playlist?['artists']?.first['name'] ??
                                        "",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyMedium,
                                  ),
                                  MaterialButton(
                                    textColor: Colors.white,
                                    color: Colors.black,
                                    onPressed: () async {
                                      await context
                                          .read<MusicPlayer>()
                                          .addPlayList(
                                            playlist?['tracks'],
                                          );
                                    },
                                    child: Text("Play all"),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Text(
                        "Tracks",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyMedium
                            ?.copyWith(
                                fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (playlist != null)
                      ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: playlist?['tracks'].length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> track =
                                playlist?['tracks'][index];
                            if (track['videoId'] == null) {
                              playlist?['tracks'].remove(track);
                              setState(() {});
                              return const SizedBox.shrink();
                            }
                            return TrackTile(
                              track: track,
                            );
                          }),
                  ],
                ),
              ),
      ),
    );
  }
}
