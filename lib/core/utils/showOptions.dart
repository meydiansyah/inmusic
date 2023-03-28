import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inmusic/core/models/track.dart';
import 'package:inmusic/core/services/music_service.dart';
import 'package:provider/provider.dart';

showOptions(Track song, context) {
  showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return ValueListenableBuilder(
          valueListenable: Hive.box('settings').listenable(),
          builder: (context, Box box, child) {
            return CupertinoActionSheet(
              actions: [
                Material(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        'https://vibeapi-sheikh-haziq.vercel.app/thumb/sd?id=${song.videoId}',
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: ((context, error, stackTrace) {
                          return Image.asset("assets/images/song.png");
                        }),
                      ),
                    ),
                    title: Text(song.title,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleMedium
                            ?.copyWith(overflow: TextOverflow.ellipsis)),
                    subtitle: Text(
                      song.artists.map((e) => e.name).toList().join(', '),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 93, 92, 92),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // trailing: IconButton(
                    //     onPressed: () {
                    //       Share.share(
                    //           "https://music.youtube.com/watch?v=${song.videoId}");
                    //     },
                    //     icon: Icon(
                    //       Icons.share,
                    //       color: isDarkTheme ? Colors.white : Colors.black,
                    //     )),
                  ),
                ),
                Material(
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      context.read<MusicPlayer>().playNext(song);
                    },
                    title: Text(
                      "Play Next",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleMedium
                          ?.copyWith(
                              overflow: TextOverflow.ellipsis, fontSize: 16),
                    ),
                  ),
                ),
                Material(
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      context.read<MusicPlayer>().addToQUeue(song);
                    },
                    title: Text(
                      "Add to queue",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleMedium
                          ?.copyWith(
                              overflow: TextOverflow.ellipsis, fontSize: 16),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: Hive.box('myfavourites').listenable(),
                  builder: (context, Box box, child) {
                    Map? favourite = box.get(song.videoId);
                    return Material(
                      child: ListTile(
                        onTap: () {
                          if (favourite == null) {
                            int timeStamp =
                                DateTime.now().millisecondsSinceEpoch;
                            Map<String, dynamic> mapSong = song.toMap();
                            mapSong['timeStamp'] = timeStamp;

                            box.put(song.videoId, mapSong);
                          } else {
                            box.delete(song.videoId);
                          }
                          Navigator.pop(context);
                        },
                        title: Text(
                          favourite == null
                              ? "Add to favorite"
                              : "Remove from favorite",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleMedium
                              ?.copyWith(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
                // ValueListenableBuilder(
                //   valueListenable: Hive.box('downloads').listenable(),
                //   builder: (context, Box box, child) {
                //     ChunkedDownloader? dl = context
                //         .watch<DownloadManager>()
                //         .getManager(song.videoId);
                //     Map? item =
                //         context.watch<DownloadManager>().getSong(song.videoId);
                //     Map? download = box.get(song.videoId);
                //     return Material(
                //       child: ListTile(
                //         onTap: () {
                //           if (download != null) {
                //             deleteFile(song.videoId);
                //           } else if (dl == null) {
                //             context.read<DownloadManager>().download(song);
                //           } else {
                //             if (dl.paused) {
                //               dl.resume();
                //             } else {
                //               dl.pause();
                //             }
                //           }
                //         },
                //         title: Text(
                //           download != null
                //               ? "Delete"
                //               : (dl == null
                //                   ? "Download"
                //                   : (dl.paused ? "Resume" : "Pause")),
                //           style: Theme.of(context)
                //               .primaryTextTheme
                //               .titleMedium
                //               ?.copyWith(
                //                   overflow: TextOverflow.ellipsis,
                //                   fontSize: 16),
                //         ),
                //         trailing: download != null
                //             ? Icon(
                //                 Icons.delete,
                //                 color: darkTheme ? Colors.white : Colors.black,
                //               )
                //             : (item == null
                //                 ? null
                //                 : Stack(
                //                     children: [
                //                       Padding(
                //                         padding: const EdgeInsets.all(6.0),
                //                         child: Icon(
                //                           dl != null && dl.paused
                //                               ? Icons.play_arrow
                //                               : Icons.pause,
                //                           color: darkTheme
                //                               ? Colors.white
                //                               : Colors.black,
                //                         ),
                //                       ),
                //                       CircularProgressIndicator(
                //                         value: item['progress'] != null
                //                             ? (item['progress'] / 100)
                //                             : null,
                //                         color: darkTheme
                //                             ? Colors.white
                //                             : Colors.black,
                //                         backgroundColor: (darkTheme
                //                                 ? Colors.white
                //                                 : Colors.black)
                //                             .withOpacity(0.4),
                //                       )
                //                     ],
                //                   )),
                //       ),
                //     );
                //   },
                // )
              ],
            );
          },
        );
      });
}
