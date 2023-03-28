import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inmusic/core/services/search_provider.dart';
import 'package:inmusic/ui/views/search/songs.dart';
import 'package:inmusic/ui/views/search/video.dart';
import 'package:provider/provider.dart';

import 'history.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen>, TickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool loading = false;
  bool submitted = false;
  List songs = [];
  List suggestions = [];

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }

  search(value) {
    focusNode.unfocus();
    if (value != null) {
      setState(() {
        submitted = true;
      });
      context.read<SearchProvider>().refresh();
      textEditingController.text = value;
      Box box = Hive.box('search_history');
      int index = box.values.toList().indexOf(textEditingController.text);
      if (index != -1) {
        box.deleteAt(index);
      }
      box.add(textEditingController.text);
    }
    setState(() {});
  }

  getSuggestions() async {
    if (mounted) {
      setState(() {
        submitted = false;
      });

      YTMUSIC.suggestions(textEditingController.text).then((value) {
        if (mounted) {
          setState(() {
            suggestions = value;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white,
          ),
          actions: textEditingController.text.trim().isNotEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                        onPressed: () {
                          textEditingController.text = "";
                          setState(() {});
                        },
                        icon: Icon(
                          CupertinoIcons.xmark,
                          color: Theme.of(context)
                              .primaryTextTheme
                              .bodyLarge
                              ?.color,
                        )),
                  )
                ]
              : [],
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: TextField(
            focusNode: focusNode,
            style: Theme.of(context).primaryTextTheme.titleLarge,
            decoration: InputDecoration(
                hintText: "Find something",
                hintStyle: TextStyle(color: Colors.white.withOpacity(.4)),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                )),
            textInputAction: TextInputAction.search,
            onChanged: (text) {
              getSuggestions();
            },
            onSubmitted: (text) {
              search(text);
            },
            controller: textEditingController,
          ),
        ),
        body: Column(
          children: [
            if (textEditingController.text.trim().isNotEmpty && submitted)
              Expanded(
                child: textEditingController.text.trim().isEmpty
                    ? SearchHistory(
                        onTap: (value) {
                          search(value);
                        },
                        onTrailing: (e) {
                          setState(() {
                            textEditingController.text = e;
                            submitted = false;
                          });
                        },
                      )
                    : submitted
                        ? SongsSearch(query: textEditingController.text)
                        : ValueListenableBuilder(
                            valueListenable: Hive.box('settings').listenable(),
                            builder: (context, Box box, child) {
                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: suggestions.length,
                                itemBuilder: (context, index) {
                                  String e = suggestions[index];
                                  return ListTile(
                                    enableFeedback: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 0),
                                    visualDensity: VisualDensity.compact,
                                    leading: Icon(Icons.search,
                                        color: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyLarge
                                            ?.color),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          textEditingController.text = e;
                                          submitted = false;
                                        });
                                      },
                                      icon: Icon(
                                          box.get('textDirection',
                                                      defaultValue: 'ltr') ==
                                                  'rtl'
                                              ? CupertinoIcons.arrow_up_right
                                              : CupertinoIcons.arrow_up_left,
                                          color: Theme.of(context)
                                              .primaryTextTheme
                                              .bodyLarge
                                              ?.color),
                                    ),
                                    dense: true,
                                    title: Text(
                                      e,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyLarge,
                                    ),
                                    onTap: () {
                                      search(e);
                                    },
                                  );
                                },
                              );
                            }),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
