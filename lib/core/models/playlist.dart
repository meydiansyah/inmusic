import 'dart:convert';

import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PlaylistModel {
  String title;
  List playlists;

  PlaylistModel({
    required this.title,
    required this.playlists,
  });

  String get getTitle => title;
  List get getPlaylist => playlists;

  set setTitle(String title) => this.title = title;
  set setPlaylist(List playlists) => this.playlists = playlists;

  PlaylistModel copyWith({
    String? title,
    List? playlists,
  }) {
    return PlaylistModel(
      title: title ?? this.title,
      playlists: playlists ?? this.playlists,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'playlist': playlists,
    };
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      title: map['title'] as String,
      playlists: List.from(
        (map['playlist'] as List),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlaylistModel.fromJson(String source) =>
      PlaylistModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'HomeModel(title: $title, playlist: $playlists)';

  @override
  bool operator ==(covariant PlaylistModel other) {
    if (identical(this, other)) return true;

    return other.title == title && listEquals(other.playlists, playlists);
  }

  @override
  int get hashCode => title.hashCode ^ playlists.hashCode;
}
