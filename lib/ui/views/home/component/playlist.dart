import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:inmusic/core/models/artist.dart';
import 'package:inmusic/core/models/thumbnail.dart';
import 'package:inmusic/ui/views/playlist/playlist.dart';
import 'package:inmusic/ui/widgets/track_tile.dart';

class PlaylistHome extends StatelessWidget {
  final String title;
  final List content;
  final bool areSongs;
  const PlaylistHome({required this.title, required this.content, required this.areSongs, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Text(
              title,
              style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (areSongs)
            ExpandablePageView(
              controller: PageController(
                initialPage: 0,
                viewportFraction: 0.9,
              ),
              padEnds: false,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content.sublist(0, content.length > 4 ? 4 : content.length).map((track) {
                      track['artists'] = [Artist(name: track['count']).toMap()];
                      track['thumbnails'] = [Thumbnail(url: track['image']).toMap()];
                      return TrackTile(track: track);
                    }).toList()),
                if (content.length > 4)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content.sublist(4, content.length > 8 ? 8 : content.length).map((track) {
                        track['artists'] = [Artist(name: track['count']).toMap()];
                        track['thumbnails'] = [Thumbnail(url: track['image']).toMap()];
                        return TrackTile(track: track);
                      }).toList()),
                if (content.length > 8)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content.sublist(8, content.length > 12 ? 12 : content.length).map((track) {
                        track['artists'] = [Artist(name: track['count']).toMap()];
                        track['thumbnails'] = [Thumbnail(url: track['image']).toMap()];
                        return TrackTile(track: track);
                      }).toList()),
                if (content.length > 12)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content.sublist(12, content.length > 16 ? 16 : content.length).map((track) {
                        track['artists'] = [Artist(name: track['count']).toMap()];
                        track['thumbnails'] = [Thumbnail(url: track['image']).toMap()];
                        return TrackTile(track: track);
                      }).toList()),
              ],
            ),
          if (!areSongs)
            SizedBox(
              height: 150,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: content.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 10);
                },
                itemBuilder: (context, index) {
                  Map playlist = content[index] as Map;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayListScreen(
                              playlistId: playlist['playlistId'] ?? playlist['browseId'],
                              isAlbum: playlist['browseId'] != null,
                            ),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: playlist['image'],
                        errorWidget: ((context, error, stackTrace) {
                          return Image.asset("assets/images/playlist.png");
                        }),
                        height: 150,
                        // width: 150,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }
}
