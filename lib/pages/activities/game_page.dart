import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/data_manager.dart';
import 'package:onwards/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    this.colorProfile = lightFlavor
  });

  final ColorProfile colorProfile;
}

abstract class GamePageState<T extends GamePage> extends State<T> {
  final Future<SharedPreferencesWithCache> userSessionCache =
      SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
              allowList: <String>{'correct', 'theme_id', 'missed', 'score', 'highscore'}));
      
  late Future<int> correctCount;
  late Future<int> missedCount;

  late Future<int> gameScore;
  int? cachedScore;
  late Future<int> gameHighscore;
  int? cachedHighScore;

  late Future<int> themeId;
  ColorProfile? cachedTheme;

  late ColorProfile currentProfile = lightFlavor;

  OverlayEntry? entry;
  late ConfettiController _bottomRightController1;
  late ConfettiController _bottomRightController2;
  late ConfettiController _bottomLeftController1;
  late ConfettiController _bottomLeftController2;
  final globalGravity = 0.10;
  final maxBlastForce = 80.0;
  final minBlastForce = 60.0;
      
  late DateTime startTime;
  late Timestamp startTimeStamp;
  late List<String> skillsTested;
  bool isCorrect = false;
  bool madeMistake = false;
  late String questionId;

  @override
  void initState() {
    super.initState();
    loadTheme();

    correctCount = userSessionCache.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('correct') ?? 0;
    });
    missedCount = userSessionCache.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('missed') ?? 0;
    });
    gameScore = userSessionCache.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('score') ?? 0;
    });
    gameHighscore = userSessionCache.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('highscore') ?? 0;
    });
    themeId = userSessionCache.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('theme_id') ?? 0;
    });
    
    _bottomRightController1 = ConfettiController(duration: const Duration(seconds: 5));
    _bottomRightController2 = ConfettiController(duration: const Duration(seconds: 5));
    _bottomLeftController1 = ConfettiController(duration: const Duration(seconds: 5));
    _bottomLeftController2 = ConfettiController(duration: const Duration(seconds: 5));
    
    startTime = DateTime.now();
    startTimeStamp = Timestamp.now();
    skillsTested = [];
    questionId = "unknown";
  }

  @override
  void dispose() {
    logger.i("Cleaning up and sending data to database...");
    // final endTimeStamp = Timestamp.now();
    final duration = DateTime.now().difference(startTime);
    // we need to send the data to the manager as a map
    PageDataManager().addPageData({
      "questionId" : questionId,
      "skills" : skillsTested,
      "result" : isCorrect,
      "timeTakenInSeconds" : duration.inSeconds,
    });

    PageDataManager().prettyPrintPageData();

    _bottomRightController1.dispose();
    _bottomRightController2.dispose();
    _bottomLeftController1.dispose();
    _bottomLeftController2.dispose();

    super.dispose();
  }

  Future<void> loadTheme() async {
    final SharedPreferencesWithCache prefs = await userSessionCache;
    int? themeIndex = (prefs.getInt('theme_id') ?? 0);
    setState(() {
      cachedTheme = getProfileByIndex(themeIndex);
      logger.i("Loaded theme: ${cachedTheme?.idKey}");
    });
    // check if cached theme is diffrent from the current one
    if (cachedTheme?.idKey != widget.colorProfile.idKey) {
      logger.w("Cached theme did not match the current one. Current: ${widget.colorProfile.idKey}, Cached: ${cachedTheme?.idKey}");
      currentProfile = cachedTheme!;
    } else {
      logger.i("Both themes match");
      currentProfile = widget.colorProfile;
    }
  }

  Future<void> increaseCorrectCount() async {
    final SharedPreferencesWithCache prefs = await userSessionCache;
    final int counter = (prefs.getInt('correct') ?? 0) + 1;
    setState(() {
      correctCount = prefs.setInt('correct', counter).then((_) {
        logger.i('Updating correct count...');
        return counter;
      });
    });
  }

  Future<void> increaseScore(int scoreToAdd) async {
    final SharedPreferencesWithCache prefs = await userSessionCache;
    final int newScore = (prefs.getInt('score') ?? 0) + scoreToAdd;
    setState(() {
      gameScore = prefs.setInt('score', newScore).then((_) {
        logger.i('Updating score count...');
        return newScore;
      });
    });
  }

  ColorProfile getProfileByIndex(int index) {
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

  Future showCorrectDialog(bool showOverlay, ColorProfile currentProfile, int errorIndex) {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () async {
          increaseCorrectCount();
          increaseScore(10);
          isCorrect = !madeMistake;
          Navigator.pop(context);
          Navigator.pop(context);
        }, 
        child: Text('Continue',
          style: TextStyle(
            color: currentProfile.textColor
          ),
        )
      ),
    ];
    
    if (errorIndex == 0) {
      // Used by Jumble to tell the player to select more answers
      madeMistake = true;
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(
              "Please select more answers",
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            title: Text(
              'Incomplete Answer',
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    }

    if (errorIndex > 0) {
      // Used by Jumble to tell the player where the incorrect word is
      madeMistake = true;
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(
              "Incorrect Answer",
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            title: Text(
              'Try again',
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            backgroundColor: currentProfile.backgroundColor,
          );
        }
      );
    }

    if (showOverlay) {
      return showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            actions: answerDialogList,
            title: Text('Way to go!',
              style: TextStyle(
                color: currentProfile.textColor
              ),),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    } else {
      madeMistake = true;
      return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(
              "Click any where to return to the problem",
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            title: Text(
              'Try again...',
              style: TextStyle(
                color: currentProfile.textColor
              ),
            ),
            backgroundColor: currentProfile.buttonColor,
          );
        }
      );
    }
  }

  void setSkills(List<String> challengedSkills) {
    this.skillsTested = List.from(challengedSkills);
    logger.i("Skills Set");
  }

  void setQuestionId(String id) {
    this.questionId = id;
    logger.i("Question ID Set");
  }

  void hideOverlay(int validIndex) {
    entry?.remove();
    entry = null;
    showCorrectDialog(true, currentProfile, validIndex);
  }

  void showAnimation(int validIndex) {
    entry = OverlayEntry(
        builder: (context) => OverlayBanner(
              onBannerDismissed: () {
                hideOverlay(validIndex);
              },
            ));

    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  void showGameOverlay(int vaildIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) => showAnimation(vaildIndex));
    _bottomLeftController1.play();
    _bottomLeftController2.play();
    _bottomRightController1.play();
    _bottomRightController2.play();
  }

  /// Create the confetti blasters
  Widget addConfettiBlasters() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: ConfettiWidget(
            confettiController: _bottomRightController1,
            blastDirection: (4*pi)/3, // 7 pi /4
            emissionFrequency: 0.000001,
            particleDrag: 0.05,
            numberOfParticles: 25,
            gravity: globalGravity,
            minBlastForce: minBlastForce,
            maxBlastForce: maxBlastForce,
            shouldLoop: false,

          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: ConfettiWidget(
            confettiController: _bottomRightController2,
            blastDirection: (7*pi)/6, // 7 pi /4
            emissionFrequency: 0.000001,
            particleDrag: 0.05,
            numberOfParticles: 25,
            gravity: globalGravity,
            minBlastForce: minBlastForce,
            maxBlastForce: maxBlastForce,
            shouldLoop: false,

          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: ConfettiWidget(
            confettiController: _bottomLeftController1,
            blastDirection: (11*pi)/6,
            emissionFrequency: 0.000001,
            particleDrag: 0.05,
            numberOfParticles: 25,
            gravity: globalGravity,
            minBlastForce: minBlastForce,
            maxBlastForce: maxBlastForce,
            shouldLoop: false,

          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: ConfettiWidget(
            confettiController: _bottomLeftController2,
            blastDirection: (5*pi)/3,
            emissionFrequency: 0.000001,
            particleDrag: 0.05,
            numberOfParticles: 25,
            gravity: globalGravity,
            minBlastForce: minBlastForce,
            maxBlastForce: maxBlastForce,
            shouldLoop: false,
          ),
        ),
      ],
    );
  }

}