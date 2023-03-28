import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:inmusic/core/models/thumbnail.dart';
import 'package:inmusic/core/models/track.dart';
import 'package:inmusic/core/services/music_service.dart';
import 'package:inmusic/core/utils/showOptions.dart';
import 'package:provider/provider.dart';

class ThumbnailHome extends StatelessWidget {
  final List data;
  const ThumbnailHome(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 1,
      ),
      items: data.map((s) {
        Track song = Track(
          title: s['title'],
          videoId: s['videoId'],
          artists: [],
          thumbnails: [Thumbnail(url: s['image'])],
        );
        return GestureDetector(
          onTap: () async {
            await context.read<MusicPlayer>().addNew(
                  song,
                );
          },
          onLongPress: () {
            showOptions(song, context);
          },
          child: CachedNetworkImage(
            imageUrl: song.thumbnails.first.url,
            // imageUrl:
            //     'https://img.youtube.com/vi/${song.videoId}/maxresdefault.jpg',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      }).toList(),
    );
  }
}
