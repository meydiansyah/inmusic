import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:inmusic/ui/widgets/track_tile.dart';

class HistoryHome extends StatelessWidget {
  const HistoryHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ValueListenableBuilder(
        valueListenable: Hive.box('song_history').listenable(),
        builder: (context, Box box, child) {
          List values = box.values.toList();
          values.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));
          return values.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: Text(
                        "Recently played",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge
                            ?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: values
                            .sublist(0, values.length > 4 ? 4 : values.length)
                            .map((track) {
                          Map<String, dynamic> item =
                              jsonDecode(jsonEncode(track));
                          return TrackTile(track: item);
                        }).toList())
                  ],
                );
        },
      ),
    );
  }
}
