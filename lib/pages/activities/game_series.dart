
// ignore_for_file: unused_field

import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/fill_in_the_blank.dart';
import 'package:onwards/pages/activities/jumble.dart';
import 'package:onwards/pages/activities/playback/playback.dart';
import 'package:onwards/pages/activities/reading/reading.dart';
import 'package:onwards/pages/activities/typing.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/data_manager.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameTestPage extends StatelessWidget {
  const GameTestPage({
    super.key,
    required this.colorProfile,
    this.difficultyType = DifficultyType.random
  });

  final ColorProfile colorProfile;
  final DifficultyType difficultyType;

  @override
  Widget build(BuildContext context) {
    logger.i("The number of questions for the games are as follows: Playback: ${gameDataBank.playbackBank.length}, Reading: ${gameDataBank.readingBank.length}, Fill-in-the-Blank: ${gameDataBank.fillBlanksBank.length}, Jumble: ${gameDataBank.jumbleBank.length}, Typing: ${gameDataBank.typingBank.length}");
    return Align(
      alignment: Alignment.center,
      child: SeriesHomePage(
        maxQuestCount: 10,
        colorProfile: colorProfile,
        difficultyType: difficultyType,
      ),
    );
  }
}

enum DifficultyType {
  random(numId: 0, identifier: "random"),
  easy(numId: 1, identifier: "easy"),
  intermediate(numId: 2, identifier: "intermediate"),
  hard(numId: 3, identifier: "hard");

  const DifficultyType({
    required this.numId,
    required this.identifier
  });

  final int numId;
  final String identifier;

  bool equals(DifficultyType type) {
    return type.numId == numId;
  }

  @override
  String toString() {
    return identifier;
  }

}

class SeriesHomePage extends StatefulWidget {

  final int maxQuestCount;
  final ColorProfile colorProfile;
  final DifficultyType difficultyType;

  const SeriesHomePage({
    super.key, 
    this.maxQuestCount = 10,
    required this.colorProfile,
    required this.difficultyType
  });
  
  @override
  SeriesHomePageState createState() => SeriesHomePageState();
}

class SeriesHomePageState extends State<SeriesHomePage> {
  // Set cache to save user data
  final Future<SharedPreferencesWithCache> _prefs =
      SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
              allowList: <String>{'correct', 'progress', 'score', 'highscore'}));

  late Future<int> correctCount;
  late Future<double> gameProgress;
  late Future<int> gameScore;
  late Future<int> gameHighscore;

  List<Widget> pageTypesList = [];
  List<int> randomPageOrderList = [];
  List<Widget> fixedPageOrderList = [];
  int questionCount = 0;
  int currentProgress = 0;
  double progressForBar = 0.0;
  int currentScore = 0;
  bool isHighScoreUpdated = false;

  // Data for database. These are the sequence start times
  Timestamp startTime = Timestamp.now();
  Timestamp endTime = Timestamp.now();

  /// Resets the number of correct answers back to 0
  Future<void> resetCorrectCount() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('correct') ?? 0) <= 0) {
      return;
    }

    const int correctCounter = 0;
    setState(() {
      correctCount = prefs.setInt('correct', correctCounter).then((_) {
        logger.i("reset counter for this session");
        return correctCounter;
      });
    });
  }

  /// Reset the game progress
  Future<void> resetProgressCount() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getDouble('progress') ?? 0) <= 0) {
      return;
    }

    const double progressCache = 0;
    setState(() {
      gameProgress = prefs.setDouble('progress', progressCache).then((_) {
        logger.i("reset counter for this session");
        return progressCache;
      });
    });
  }

  /// Reset game score for this session
  Future<void> resetCurrentScore() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    if ((prefs.getInt('score') ?? 0) <= 0) {
      return;
    }

    const int scoreCache = 0;
    setState(() {
      gameHighscore = prefs.setInt('score', scoreCache).then((_) {
        logger.i("reset game score for this session");
        return scoreCache;
      });
    });
  }

  Future<void> increaseProgress(double nextProgress) async {
    final SharedPreferencesWithCache prefs = await _prefs;
    final double progressCache = clampDouble(nextProgress, 0, 1);

    setState(() {
      gameProgress = prefs.setDouble('progress', progressCache).then((_) {
        logger.d('Updating progress for bar...');
        return progressCache;
      });
    });
  }

  Future<void> increaseHighScore() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    int? cachedScore = (prefs.getInt('score') ?? 0);
    int? cachedHighScore = (prefs.getInt('highscore') ?? 0);
    bool shouldReplace = cachedScore > cachedHighScore;
    isHighScoreUpdated = shouldReplace;

    setState(() {
      int updatedScore = shouldReplace ? cachedScore : cachedHighScore;
      gameScore = prefs.setInt('highcore', updatedScore).then((_) {
        logger.d('Updating highscore...');
        return updatedScore;
      });
    });
  }
  
  @override
  void initState() {
    super.initState();
    correctCount = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    gameProgress = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getDouble('progress') ?? 0.0;
    });
    gameScore = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('score') ?? 0;
    });
    gameHighscore = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('highscore') ?? 0;
    });
  }

  void selectFixedPages() {
    if (!widget.difficultyType.equals(DifficultyType.random)) {
      // either easy, medium, hard
      for (GameData gameData in gameDataBank.getSeriesByDifficulty(widget.difficultyType)) {
          if (gameData is PlaybackGameData) {
            PlaybackGameData playbackGameData = gameData;
            PlaybackActivityScreen playbackGame = PlaybackActivityScreen.fromLevelSelect(profile: widget.colorProfile, gameData: playbackGameData,);
            fixedPageOrderList.add(playbackGame);
          }

          if (gameData is ReadAloudGameData) {
            ReadAloudGameData readAloudGameData = gameData;
            ReadingActivityScreen readingGame = ReadingActivityScreen.fromLevelSelect(readingData: readAloudGameData, profile: widget.colorProfile,);
            fixedPageOrderList.add(readingGame);
          }

          if (gameData is JumbleGameData) {
            JumbleActivityScreen jumbleGame = JumbleActivityScreen.fromLevelSelect(jumbleData: gameData, profile: widget.colorProfile,);
            fixedPageOrderList.add(jumbleGame);
          }

          if (gameData is FillBlanksGameData) {
            FillInActivityScreen fillGame = FillInActivityScreen.fromLevelSelect(fillData: gameData, profile: widget.colorProfile,);
            fixedPageOrderList.add(fillGame);
          }

          if (gameData is TypingGameData) {
            TypingGameData typingGameData = gameData;
            TypeActivityScreen typingGame = TypeActivityScreen.fromLevelSelect(profile: widget.colorProfile, typingData: typingGameData);
            fixedPageOrderList.add(typingGame);
          }
      }
    } else {
      // choose pages randomly
    }
  }

  /// Fill the selectedPageOrder list with X number of random questions, where X is the max number of questions in a series
  void selectRandPages() {
    final random = Random();
    int randStartIndex = random.nextInt(pageTypesList.length);
    randomPageOrderList.clear();
    questionCount = pageTypesList.length;

    for (int i =0; i < widget.maxQuestCount; i++) {
      int next = (randStartIndex + i) % pageTypesList.length;
      randomPageOrderList.add(next);
    }
    logger.d('Color profile for this series: ${widget.colorProfile.idKey}');
    logger.d('Order for this session: $randomPageOrderList');
  }

  /// Navigate to the next page listed in the selectPageOrder and construct the page for navigation
  void navigateToNextRandom(int currentIndex) {
    if (currentIndex < randomPageOrderList.length) {
      increaseProgress(progressForBar);
      currentProgress++;
      progressForBar = (currentProgress / randomPageOrderList.length).roundToDouble();
      logger.d("Profile for the next page is: ${widget.colorProfile.idKey}, Question Number: $currentProgress, Progress: $progressForBar");
      

      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => pageTypesList[randomPageOrderList[currentIndex]],
        ),
      ).then((_) {
        // recurssively navigate to next until we can't
        navigateToNextRandom(currentIndex + 1);
      });
    } else {
      logger.d("Reached the end of the navigation, showing end results");
      increaseProgress(1.0);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SeriesEndPage(
          colorProfile: widget.colorProfile, 
          seriesCount: randomPageOrderList.length,
        ))
      );
    }
  }

  /// Naviagate thru the fixed series pages until we iterated thru it completely. Note: page list may have less
  /// questions than the number defined in MaxQuestCount
  void navigateFixedSeries(int currentIndex) {
    if (currentIndex < fixedPageOrderList.length) {
      increaseProgress(progressForBar); 
      currentProgress++;
      progressForBar = currentProgress / fixedPageOrderList.length;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => fixedPageOrderList[currentIndex],
        ),
      ).then((_) {
        navigateFixedSeries(currentIndex + 1);
      });
    } else {
      // set progress to max
      increaseProgress(1.0);
      increaseHighScore();
      endTime = Timestamp.now();
      logger.i("Stopped quiz timer");
      writeData();

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SeriesEndPage(
          colorProfile: widget.colorProfile, 
          seriesCount: fixedPageOrderList.length,
        ))
      );
    }
  }

  Future<void> writeData() async {
    try {
      logger.i("Sending game data to database");
      CollectionReference quizAttempt = FirebaseFirestore.instance.collection("quizAttempts");
      List<Map<String, dynamic>> collectedData = PageDataManager().allData;
      // We assume all data is available at this time
      Map<String, dynamic> quizData = {
        'startTime': startTime,
        'submissionTime': endTime,
        "difficulty": widget.difficultyType.toString(),
        'questions': collectedData
      };

      await quizAttempt.add(quizData);
      logger.i("Data added to firestore...");
    } catch (e) {
      logger.e('Error adding data to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d("This GameTest has a profile of: ${widget.colorProfile.idKey}");
    // Add the page types to the page list to pick from
    pageTypesList.addAll(List.of([
      FillInActivityScreen(colorProfile: widget.colorProfile),
      JumbleActivityScreen(colorProfile: widget.colorProfile),
      PlaybackActivityScreen(colorProfile: widget.colorProfile),
      ReadingActivityScreen(colorProfile: widget.colorProfile),
      TypeActivityScreen(colorProfile: widget.colorProfile)
    ]));

    String buttonLabel = "Random Mode";
    if (widget.difficultyType.equals(DifficultyType.easy)) {
      buttonLabel = "Easy Mode";
    } else if (widget.difficultyType.equals(DifficultyType.intermediate)) {
      buttonLabel = "Intermediate Mode";
    }
    else if (widget.difficultyType.equals(DifficultyType.hard)) {
      buttonLabel = "Hard Mode";
    }
    

    return Scaffold(
      appBar: AppBar(
        title: Text(buttonLabel, style: TextStyle(color: widget.colorProfile.textColor)),
        backgroundColor: widget.colorProfile.headerColor,
        actions: const [ScoreDisplayAction(), CalcButton()],
      ),
      body: Container(
        decoration: widget.colorProfile.backBoxDecoration,
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.center,
                child: Text(
                  "Click to start the question series. You will navigate through ${gameDataBank.getSeriesByDifficulty(widget.difficultyType).length + 1} questions. You can use the calculator on the top-right of the screen to help you answer the questions.",
                  style: TextStyle(
                      color: widget.colorProfile.textColor, fontSize: 16),
                ),
              ),
            Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            widget.colorProfile.buttonColor)),
                    onPressed: () {
                      if (widget.difficultyType.equals(DifficultyType.random)) {
                        // select up to X pages for a random selection. Dynamically done at user request!
                        selectRandPages();
                      } else {
                        // select up to X pages for a fixed selection based on difficulty.  Dynamically done at user request!
                        selectFixedPages();
                      }

                      resetCorrectCount(); // In case count has something in it
                      try {
                        startTime = Timestamp.now();
                        logger.i("Started quiz timer");
                        if (widget.difficultyType.equals(DifficultyType.random)) {
                          navigateToNextRandom(0);
                        } else {
                          navigateFixedSeries(0);
                        }
                      } catch (exception) {
                        logger.e("an error has occured");
                      }
                    },
                    child: Text(
                      buttonLabel,
                      style: TextStyle(color: widget.colorProfile.textColor),
                    )),
              )
          ],
        )
      ),
    );
  }
}

class SeriesEndPage extends StatefulWidget {
  const SeriesEndPage({
    super.key, 
    required this.colorProfile,
    this.seriesCount = 5,
    this.showNewScore = false
  });

  final ColorProfile colorProfile;
  final int seriesCount;
  final bool showNewScore;

  @override
  State<StatefulWidget> createState() => SeriesEndPageState();

}

class SeriesEndPageState extends State<SeriesEndPage> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'correct', 'missed', 'mastered_topics', 'weak_topics', 'score', 'highscore'}
      ));
  late Future<int> correctCounter;
  late Future<int> missedCounter;
  late Future<List<String>> masteredTopicList;
  late Future<List<String>> weakTopicList;
  late Future<int> score;
  late Future<int> highscore;

  // handle the end of the series game
  @override
  void initState() {
    correctCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    missedCounter = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('missed') ?? 0;
    });

    masteredTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('mastered_topics') ?? <String>[];
    });
    weakTopicList = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getStringList('weak_topics') ?? <String>[];
    });
    score = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('score') ?? 0;
    });
    highscore = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('highscore') ?? 0;
    });
    super.initState();
  }

  List<Widget> skillLabels = [];
  List<Widget> getSkillLabels(List<String>? skills, String heading) {
    if (skills != null) {
      logger.i("Skills: $skills");
      // <----------- Remove duplicate skills ---------------->
      Set<String> seen = {};
      List<String> uniqueSkills = [];

      for (String skill in skills) {
        if (!seen.contains(skill)) {
          seen.add(skill);
          uniqueSkills.add(skill);
        }
      }
      
      List<String> vals = List.of(skillMap.values);
      for (String skill in uniqueSkills) {
        int index = 0;
        int counter = 0;

        // for each mapped skill in the keys
        for (String mappedSkill in skillMap.keys) {
          if (mappedSkill == skill) {
            index = counter;
          } else {
            counter += 1;
          }
        }
        // add the true skill name into the list
        skillLabels.add(
          Text(
            vals[index],
            style: TextStyle(
              color: widget.colorProfile.textColor
            ),
          )
        );
      }
    }
    skillLabels.insert(0, 
      Text(
        heading, 
        style: TextStyle(
          color: widget.colorProfile.textColor,
          fontSize: 18
        ),
      )
    );
    return skillLabels;
  }

  @override
  Widget build(BuildContext context) {
    const double sizeFactor = 10;

    

    return Scaffold(
      appBar: AppBar(
        title: Text("Results", style: TextStyle(color: widget.colorProfile.textColor),),
        backgroundColor: widget.colorProfile.headerColor,
        actions: const [ProgressBar(), ScoreDisplayAction()],
      ),
      body: Container(
        decoration: widget.colorProfile.backBoxDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Results from the question series",
              style: TextStyle(
                color: widget.colorProfile.textColor,
                  fontSize: 20 + sizeFactor,
              ),
            ),
            FutureBuilder<int>(
              future: correctCounter, 
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: TextStyle(color: widget.colorProfile.textColor));
                    } else {
                      return Column(
                        children: [
                          Text(
                            'Number of Questions: ${widget.seriesCount}, Total Correct: ${snapshot.data}',
                            style: TextStyle(
                              color: widget.colorProfile.textColor,
                              fontSize: 15 + sizeFactor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: widget.showNewScore ? const Text("New highscore acheived!") : Text("Your score: $score")
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(widget.colorProfile.buttonColor)
                                  ),
                                  onPressed: () => {
                                    Navigator.of(context).pop(),
                                    Navigator.of(context).pop(),
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage()
                                      )
                                    )
                                  }, 
                                  child: Text(
                                    "Go back to Home",
                                    style: TextStyle(
                                      color: widget.colorProfile.textColor
                                    ),
                                  )
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    }
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}