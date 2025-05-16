
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/fill_in_the_blank.dart';
import 'package:onwards/pages/activities/jumble.dart';
import 'package:onwards/pages/activities/playback/playback.dart';
import 'package:onwards/pages/activities/reading/reading.dart';
import 'package:onwards/pages/activities/typing.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugHomePage extends StatefulWidget {
  const DebugHomePage ({super.key});

  @override
  DebugHomePageState createState() => DebugHomePageState();
}

class DebugHomePageState extends State<DebugHomePage> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'theme_id', 'correct', 'missed', 'mastered_topics', 'weak_topics', 'score'}
      )
    );

  late Future<int> themeId;
  late Future<int> correctCounter;
  late Future<int> missedCounter;
  late Future<List<String>> masteredTopicList;
  late Future<List<String>> weakTopicList;
  late Future<int> score;

  final maxThemes = 6;

  ColorProfile currentProfile = lightFlavor;

  Future<void> loadTheme() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    int? themeIndex = (prefs.getInt('theme_id') ?? 0);

    setState(() {
      currentProfile = _getProfileByIndex(themeIndex);
    });
  }

  ColorProfile _getProfileByIndex(int index) {
    switch(index) {
        case 0:
          return lightFlavor;
        case 1:
          return darkFlavor;
        case 2:
          return plainFlavor;
        case 3:
          return mintFlavor;
        case 4:
          return strawberryFlavor;
        case 5:
          return bananaFlavor;
        case 6:
          return peanutFlavor;
        default:
          return lightFlavor;
      }
  }

  Future<void> _incrementCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('theme_id') ?? 0) >= maxThemes) {
      return;
    }
    final int counter = (prefs.getInt('theme_id') ?? 0) + 1;
    setState(() {
      themeId = prefs.setInt('theme_id', counter).then((_) {
        logger.i('Updating theme...');
        currentProfile = _getProfileByIndex(counter);
        return counter;
      });
    });
  }

  Future<void> addMasteredTopic(String topic) async {
    final SharedPreferencesWithCache prefs = await _prefs;
    final List<String> mastered = (prefs.getStringList('mastered_topics') ?? <String>[]);
    if (mastered.contains(topic)) {
      return;
    }

    mastered.add(topic);

    setState(() {
      masteredTopicList = prefs.setStringList('mastered_topics', mastered).then((_) {
        return mastered;
      });
    });
  }

  Future<void> removeMasteredTopic(String topic) async {
    final SharedPreferencesWithCache prefs = await _prefs;
    final List<String> mastered = (prefs.getStringList('mastered_topics') ?? <String>[]);
    if (!mastered.contains(topic)) {
      return;
    }
    
    mastered.remove(topic);

    setState(() {
      masteredTopicList = prefs.setStringList('mastered_topics', mastered).then((_) {
        return mastered;
      });
    });
  }

  Future<void> _decrementCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('theme_id') ?? 0) <= 0) {
      return;
    }

    final int counter = (prefs.getInt('theme_id') ?? 0) - 1;
    setState(() {
      themeId = prefs.setInt('theme_id', counter).then((_) {
        logger.i('Updating theme...');
        currentProfile = _getProfileByIndex(counter);
        return counter;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    themeId = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('theme_id') ?? 0;
    });
    correctCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    missedCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('missed') ?? 0;
    });
    score = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('score') ?? 0;
    });

    masteredTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('mastered_topics') ?? <String>[];
    });
    weakTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('weak_topics') ?? <String>[];
    });

    loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> gameCards = <Widget> [
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/audio-playback-preview.png'
        ),
        gameRoute: "/easy-mode", 
        gameWidget: PlaybackActivityScreen(colorProfile: currentProfile),
        keyId: 0,
        title: "Playback and Choose",
        subtitle: "Difficulty: Hard",
        styleMode: darkStyle,
      ),
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/fill-in-the-blank-preview.png'
        ),
        gameRoute: '/intermediate-mode',
        gameWidget: FillInActivityScreen(colorProfile: currentProfile), 
        keyId: 1,
        title: "Fill in the Blank",
        subtitle: "Difficulty: Easy",
        styleMode: darkStyle,
      ),
      GameCard(
        imageAsset: const AssetImage('assets/images/jumble-preview.png'),
        gameRoute: '/jumble',
         gameWidget: JumbleActivityScreen(colorProfile: currentProfile),
        keyId: 2,
        title: "Translate Jumble",
        subtitle: "Difficulty: Medium",
        styleMode: darkStyle,
      ),
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/reading-preview.png'
        ),
        gameRoute: '/reading', 
        gameWidget: ReadingActivityScreen(colorProfile: currentProfile),
        keyId: 3,
        title: "Read Aloud",
        subtitle: "Difficulty: Challenging",
        styleMode: darkStyle,
      ),
      GameCard(
        imageAsset: const AssetImage(
          'assets/images/type-preview.png'
        ),
        gameRoute: '/typing', 
        gameWidget: TypeActivityScreen(colorProfile: currentProfile),
        keyId: 4,
        title: "Type it Out",
        subtitle: "Difficulty: Challenging",
        styleMode: darkStyle,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: currentProfile.headerColor,
        centerTitle: true,
        actions: const [ScoreDisplayAction()],
        
      ),
      body: Container(
        decoration: currentProfile.backBoxDecoration,
        child: Column(
          children: [
            SizedBox(
              width: 900.0,
              height: 500.0,
              child: ListView(
                key: const ValueKey('HomeListView'),
                primary: true,
                padding: const EdgeInsetsDirectional.only(
                  top: 90.0
                ),
                children: [
                  CarouselCardItem(
                    child: DesktopCarousel(
                      height: minHeight,
                      modeHeader: "Debug Mode: Select a game to play that instance of it",
                      colorProfile: currentProfile, 
                      children: gameCards,
                    )
                  )
                ],
              ),
            ),
            FutureBuilder<int>(
              future: themeId, 
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: TextStyle(color: currentProfile.textColor));
                    } else {
                      return Text(
                        'Current theme: ${currentProfile.idKey}',
                        style: TextStyle(
                          color: currentProfile.textColor
                        ),
                      );
                    }
                }
              }
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: "Previous Theme",
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(currentProfile.buttonColor)),
                    onPressed: _decrementCounter, 
                    child: const Icon(Icons.arrow_left)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Theme Select",
                    style: TextStyle(
                      color: currentProfile.textColor
                    ),
                  ),
                ),
                Tooltip(
                  message: "Next Theme",
                  preferBelow: true,
                  child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(currentProfile.buttonColor)),
                    onPressed: _incrementCounter,
                    child: const Icon(Icons.arrow_right),
                  ),
                )
              ],
            ),
          ],
        )
      )
    );
  }
}