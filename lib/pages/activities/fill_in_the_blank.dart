import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_page.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/components/skip.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';
import 'package:shared_preferences/shared_preferences.dart';

const FillBlanksGameData dummyData = FillBlanksGameData(displayedProblem: "", multiAcceptedAnswers: [], writtenPrompt: "", blankForm: "", optionList: [], skills: []);

class FillInActivityScreen extends StatelessWidget {
  final FillBlanksGameData fillBlanksGameData;
  final ColorProfile colorProfile;
  final bool fromLevelSelect;

  const FillInActivityScreen({
    super.key,
    this.colorProfile = plainFlavor,
    this.fillBlanksGameData = dummyData,
    this.fromLevelSelect = false
  });

  const FillInActivityScreen.fromLevelSelect({required FillBlanksGameData fillData, required ColorProfile profile, super.key}) : 
    colorProfile = profile,
    fillBlanksGameData = fillData,
    fromLevelSelect = true;

  @override
  Widget build(BuildContext context) {
    FillBlanksGameData randomGameData = gameDataBank.getRandomFillBlanksElement();

    return Scaffold(
      appBar: AppBar(
        title: Text('Fill in the Blank Game', style: TextStyle(color: colorProfile.textColor)),
        backgroundColor: colorProfile.headerColor,
        actions: const [Skip(), ScoreDisplayAction(), CalcButton()],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
        padding: const EdgeInsets.only(top: 40),
        child:  !fromLevelSelect ?
          GameForm(
            answers: randomGameData.multiAcceptedAnswers, 
            questionLabel: randomGameData.displayedProblem,  
            blankQuestLabel: randomGameData.blankForm,
            maxSelectedAnswers: randomGameData.getMinSelection(),
            buttonOptions: randomGameData.optionList,
            colorProfile: colorProfile,
            skills: randomGameData.skills,
            id: randomGameData.id
          ) :
          GameForm(
            answers: fillBlanksGameData.multiAcceptedAnswers, 
            questionLabel: fillBlanksGameData.displayedProblem,  
            blankQuestLabel: fillBlanksGameData.blankForm,
            maxSelectedAnswers: fillBlanksGameData.getMinSelection(),
            buttonOptions: fillBlanksGameData.optionList,
            colorProfile: colorProfile,
            skills: fillBlanksGameData.skills,
            id: fillBlanksGameData.id
          )
      )
    );
  }
}

// Show this game's unique game form using the data
// passed from GameData. The idea is to have the game
// move to the next question after the dialog, using context
// to pass the info over
class GameForm extends GamePage {
  const GameForm({
    super.key,
    required this.answers, 
    required this.questionLabel,
    required this.blankQuestLabel,
    required this.maxSelectedAnswers,
    required this.buttonOptions,
    super.colorProfile,
    required this.skills,
    required this.id
  });

  final String questionLabel;
  final List<String> answers;
  final String blankQuestLabel;
  final int maxSelectedAnswers;
  final List<String> buttonOptions;
  final List<String> skills;
  final String id;

  @override
  GameFormState createState() => GameFormState();
}

class GameFormState extends GamePageState<GameForm> {

  final List<String> _selectedAnswers = [];
  int maxSelection = 0;
  int currentCount = 0;

  @override
  void initState() {
    super.initState();
    maxSelection = widget.maxSelectedAnswers;
  }

  @override
  void dispose() {
    logger.i("Finihing up and disposing Typing Game...");
    // add skills from game for database
    List<String> currentSkills = [];
    for (String skill in widget.skills) {
      currentSkills.add(skill);
    }
    setSkills(currentSkills);
    setQuestionId(widget.id);
    super.dispose();
  }

  bool validateAnswer() {
    bool isCorrect = true;
    if (currentCount >= widget.maxSelectedAnswers) {
      for (int i = 0; i < _selectedAnswers.length; i++) {
        if (_selectedAnswers[i] != widget.answers[i]) {
          isCorrect = false;
          logger.d("Correct answer did not match at: ${widget.answers[i]}");
        }
      }
    } else {
      isCorrect = false;
    }
    logger.d("validated answer");
    return isCorrect;
  }

  List<Widget> renderConditionalLabels(List<String> splitter) {
    List<Widget> widgets =[];
    int countForSelected = 0;
    for (String part in splitter) {
      if (part.contains("_")) {
        if (_selectedAnswers.isNotEmpty && countForSelected < _selectedAnswers.length) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5), 
              child: Text(
                _selectedAnswers[countForSelected],
                style: TextStyle(
                  fontSize: 18.0,
                  color: currentProfile.contrastTextColor
                ),
              )
            )
          );
          countForSelected += 1;
        } else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5), 
              child: Text(
                part,
                style: TextStyle(
                  fontSize: 18.0,
                  color: currentProfile.textColor
                ),
              ),
            )
          );
        }
      }
      else {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 5), 
            child: Text(
              part,
              style: TextStyle(
                fontSize: 18.0,
                color: currentProfile.textColor
              ),
            ),
          )
        );
      }
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 5), 
          child: Text(
            " ",
            style: TextStyle(
              fontSize: 18.0,
              color: currentProfile.textColor
            ),
          ),
        )
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // List<String> selectedAnswers = [];
    // This is the data of multiple games
    List<Widget> dynamicButtonList = <Widget> [];
    List<String> splitter = widget.blankQuestLabel.split(" ");
    bool isValid;

    for (String option in widget.buttonOptions) {
      ElevatedButton button = ElevatedButton(
        onPressed: () => {
          setState(() {
            if (currentCount < maxSelection) {
              _selectedAnswers.add(option);
              currentCount += 1;
            }
          })
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: currentProfile.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 24
          ),
        ),
        child: Text(
          option, 
          style: TextStyle(color: currentProfile.contrastTextColor),
        ),
      );
      Padding padding = Padding(
        padding: const EdgeInsets.all(8.0),
        child: button,
      );
      dynamicButtonList.add(padding);
    }
    
    // Render the form here
    return Container(
      decoration: currentProfile.backBoxDecoration,
      child: Stack(
        children: [
          addConfettiBlasters(),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "Use the blocks below to form the written form of the expression:",
                  style: TextStyle(
                    color: currentProfile.textColor, 
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.questionLabel,
                    style: TextStyle(
                      color: currentProfile.textColor, 
                      fontSize: 30,
                      
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column( // attempt to render the selected answers as they are moved into the list
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: renderConditionalLabels(splitter),
                      ),
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: dynamicButtonList,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextButton(
                        onPressed: () => {
                          isValid = validateAnswer(),
                          if (isValid) {
                            showGameOverlay(-1)
                          } else {
                            showCorrectDialog(isValid, currentProfile, -1)
                          }
                        }, 
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(currentProfile.checkAnswerButtonColor),
                        ),
                        child: Text(
                          'Check Answer',
                          style: TextStyle(color: currentProfile.contrastTextColor),
                        )
                      )
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentCount = 0;
                          _selectedAnswers.clear();
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(currentProfile.clearAnswerButtonColor),
                      ),
                      child: Text(
                        'Clear all answers',
                        style: TextStyle(color: currentProfile.contrastTextColor),
                        )
                      )
                  ],
                )
              ],
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: ProgressBar(),
          )
        ],
      )
    );
    
  }
}