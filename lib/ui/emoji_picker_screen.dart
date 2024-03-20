import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmojiPickerScreen extends StatefulWidget {
  @override
  _EmojiPickerScreenState createState() => _EmojiPickerScreenState();
}

class _EmojiPickerScreenState extends State<EmojiPickerScreen> {
  List<List<String>> emojis = [];
  List<String> recentEmojis = [];


  @override
  void initState() {
    super.initState();
    fetchEmojis();
    loadRecentEmojis();
  }

  Future<void> fetchEmojis() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/Fantantonio/Emoji-List-Unicode/master/json/all-emoji.json'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> categoryData = jsonData;
      List<String> currentCategory = [];
      for (var item in categoryData) {
        if (item.length > 1) {
          String emoji = item[2];
          currentCategory.add(emoji);
          if (currentCategory.length >= 7) {
            emojis.add(List<String>.from(currentCategory));
            currentCategory.clear();
          }
        }
      }
      if (currentCategory.isNotEmpty) {
        emojis.add(List<String>.from(currentCategory));
      }
    } else {
      throw Exception('Failed to load emojis');
    }
  }
  Future<void> loadRecentEmojis() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentEmojiList = prefs.getStringList('recentEmojis');
    if (recentEmojiList != null) {
      setState(() {
        recentEmojis = recentEmojiList;
      });
    }
  }

  Future<void> addRecentEmoji(String emoji) async {
    recentEmojis.remove(emoji);

    recentEmojis.add(emoji);

    if (recentEmojis.length > 10) {
      recentEmojis.removeAt(0); // Remove the oldest emoji if the limit is exceeded
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recentEmojis', recentEmojis);
    setState(() {});
  }

  void toggleEmojiPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,

            child: DefaultTabController(
              length: emojis.length + 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TabBar(
                    isScrollable: true,
                    indicatorPadding: EdgeInsets.only(left: 0.0),
                    labelStyle: TextStyle(fontSize: 20),
                    tabs: [
                      Tab(
                      child: Icon(Icons.history),),
                      ...emojis.map((category) => Tab(text: category.first)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: recentEmojis.map((emoji) {
                              return GestureDetector(
                                onTap: () {
                                  addRecentEmoji(emoji);
                                  print('Selected recent emoji: $emoji');
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  emoji,
                                  style: TextStyle(fontSize: 30),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        ...emojis.map((category) {
                          return SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: category.map((emoji) {
                                return GestureDetector(
                                  onTap: () {
                                    addRecentEmoji(emoji);
                                    print('Selected emoji: $emoji');
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    emoji,
                                    style: TextStyle(fontSize: 30),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emoji Keyboard Demo',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleEmojiPicker,
        child: Icon(Icons.emoji_emotions),
      ),
      body: Container(

      )
    );
  }

}