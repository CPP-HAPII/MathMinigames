
// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_page.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/components/skip.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';

import '../constants.dart';

const JumbleGameData dummyData = JumbleGameData(displayedProblem: '', multiAcceptedAnswers: [], optionList: [], skills: []);

class JumbleActivityScreen extends StatelessWidget {
  final JumbleGameData jumbleGameData;
  final ColorProfile colorProfile;
  final bool fromLevelSelect;

  const JumbleActivityScreen({
    super.key,
    this.colorProfile = lightFlavor,
    this.jumbleGameData = dummyData,
    this.fromLevelSelect = false
  });

  const JumbleActivityScreen.fromLevelSelect({required JumbleGameData jumbleData, required ColorProfile profile, super.key}) :
    colorProfile = profile,
    jumbleGameData = jumbleData,
    fromLevelSelect = true;

  @override
  Widget build(BuildContext context) {
    JumbleGameData randomGameData = gameDataBank.getRandomJumbleElement();

    return Scaffold(
      appBar: AppBar(
        title: Text('Word Jumble Game', style: TextStyle(color: colorProfile.textColor)),
        backgroundColor: colorProfile.headerColor,
        actions: const [Skip(), ScoreDisplayAction(), CalcButton()],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
        padding: const EdgeInsets.only(top: 40),
        child: !fromLevelSelect ?
          GameForm(
            // Using the bank's random data
            answers: randomGameData.multiAcceptedAnswers, 
            questionLabel: randomGameData.displayedProblem, 
            maxSelectedAnswers: randomGameData.getMinSelection(), 
            buttonOptions: randomGameData.optionList,
            titleQuestion: randomGameData.writtenPrompt,
            showArithmitic: true,
            colorProfile: colorProfile,
            skills: randomGameData.skills,
            scoreValue: randomGameData.score,
            id: randomGameData.id,
          ) :
          GameForm(
            // using the passed gameData
            answers: jumbleGameData.multiAcceptedAnswers, 
            questionLabel: jumbleGameData.displayedProblem, 
            maxSelectedAnswers: jumbleGameData.getMinSelection(), 
            buttonOptions: jumbleGameData.optionList,
            titleQuestion: jumbleGameData.writtenPrompt,
            showArithmitic: true,
            colorProfile: colorProfile,
            skills: jumbleGameData.skills,
            scoreValue: jumbleGameData.score,
            id: jumbleGameData.id,
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
    super.colorProfile,
    required this.answers, 
    required this.questionLabel,
    required this.maxSelectedAnswers,
    required this.buttonOptions,
    required this.titleQuestion,
    required this.showArithmitic,
    required this.skills,
    required this.scoreValue,
    required this.id
  });

  /// The label for the question, which should be the math form for this game
  final String questionLabel;
  /// The list of combos accepted as answers
  final List<List<String>> answers;
  /// The number of max soloutions in the correct answer
  final int maxSelectedAnswers;
  /// the text for the buttons that can be used to create this phrase
  final List<String> buttonOptions;
  final String titleQuestion;
  final bool showArithmitic;
  final List<String> skills;
  final int scoreValue;
  final String id;

  @override
  GameFormState createState() => GameFormState();
}

class GameFormState extends GamePageState<GameForm> {
  final List<String> _selectedAnswers = [];
  int maxSelection = 0;
  int currentCount = 0;
  // data for database
  bool lastCorrectState = false;

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

  /// Validate the current selection against the multiple answers. 
  /// If the value is -1, the answer is correct. If the answer is 0, not enough answers were selected. If the answer is greater than 0, then there is an error somewhere
  int validateAnswer() {
    int errorIndex = -1;
    bool isCorrect = true;
    bool isMultipleCorrect = true;
    if (currentCount >= maxSelection) {
      // go thru all the answers in the multiAcceptedAnswers
      for (List<String> answerList in widget.answers) {
        logger.d("Checking a list of answers: ${widget.answers.length}");
        // go thru the answer elements in the current list
        for (int i = 0; i < answerList.length; i++) {
          isCorrect = true;
          // If the current answer does not match the one from the list, save the location and mark the flag
          if (_selectedAnswers[i] != answerList[i]) {
            logger.d("Validating Answer: Expected ${answerList[i]} at Position: $i but got ${_selectedAnswers[i]}");
            isCorrect = false;
            errorIndex = i;
          }
        }

        // when we are done going through one answer, if its correct, just skip checking the rest
        if (isCorrect) {
          logger.i("Skipping checking the rest of the multiAcceptedAnswers as one matched already");
          return -1;
        } else {
          logger.d("Match hasn't been found yet, continuing...");
          isMultipleCorrect = isCorrect; // save last correctness
        }
      }
      
    } else {
      logger.d("Not enough answers are selected, could not validate. Expected $maxSelection but got $currentCount");
      return 0;
    }

    logger.d("Returning the answer index");
    return errorIndex;
  }

  void clearAnswers() {
    setState(() {
      currentCount = 0;
      logger.d("Cleared answer selection");
      _selectedAnswers.clear();
    });
  }

  // create a list of widgets that represents the selected button choices
  List<Widget> renderConditionalLabels() {
    List<Widget> widgets =[];

    for (String part in _selectedAnswers) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5), 
        child: Text(
          part,
          style: TextStyle(
            fontSize: 18.0,
            color: currentProfile.textColor
          ),
        )
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // List<String> selectedAnswers = [];
    // This is the data of multiple games
    List<Widget> dynamicButtonList = <Widget> [];
    int validIndex = 0;

    for (String option in widget.buttonOptions) {
      Widget button = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: GameButton(
          onPressed: () => {
            setState(() {
              if (currentCount < maxSelection) {
                _selectedAnswers.add(option);
                // _selectedIds.add(id);
                currentCount += 1;
              }
            }),
          }, 
          isDisabled: _selectedAnswers.contains(option), 
          label: option,
          colorProfile: currentProfile,
        ),
      );
      
      dynamicButtonList.add(button);
    }
    
    // Render the form here
    /*
    'Button tapped ${snapshot.data ?? 0 + _externalCounter} time${(snapshot.data ?? 0 + _externalCounter) == 1 ? '' : 's'}.\n\n'
    'This should persist across restarts.', style: TextStyle(color: currentProfile.textColor)
    */
    return Container(
      decoration: currentProfile.backBoxDecoration,
      child: Stack(
        children: [
          addConfettiBlasters(),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Text(
                    widget.titleQuestion,
                    style: TextStyle(
                        color: currentProfile.textColor, 
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                  ),
                  // Render the question label
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: widget.showArithmitic ? Text(
                      widget.questionLabel,
                      style: TextStyle(
                        color: currentProfile.textColor, 
                        fontSize: 30,
                        
                      ),
                    ) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column( 
                      // attempt to render the selected answers as they are moved into the list
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: renderConditionalLabels(),
                        ),
                      ],
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: dynamicButtonList,
                      ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _selectedAnswers.isEmpty ? null : () => {
                          validIndex = validateAnswer(),
                          if (validIndex < 0) {
                            showGameOverlay(validIndex)
                          } else {
                            showCorrectDialog(validIndex == -1, currentProfile, validIndex)
                          }
                        }, 
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(currentProfile.checkAnswerButtonColor),
                        ),
                        child: Text(
                          'Check Answer',
                            style: TextStyle(
                              color: currentProfile.contrastTextColor
                            ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => {
                          clearAnswers()
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(currentProfile.clearAnswerButtonColor),
                        ),
                        child: Text(
                          'Clear all answers',
                          style: TextStyle(
                            color: currentProfile.contrastTextColor),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            )
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

class GameButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDisabled;
  final String label;
  final String disabledLabel;
  final ColorProfile colorProfile;
  final int id;

  const GameButton({
    super.key, 
    required this.onPressed, 
    required this.isDisabled,
    required this.label,
    this.disabledLabel = "",
    this.id = 0,
    required this.colorProfile
    });

    int getID() {
      return id;
    }

  @override
  GameButtonState createState() => GameButtonState();

}

class GameButtonState extends State<GameButton> {
  late bool isDisabled;

  @override
  void initState() {
    super.initState();
    isDisabled = widget.isDisabled; // Initialize internal state based on external flag
  }

  @override
  void didUpdateWidget(GameButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the internal state when the external flag changes
    if (widget.isDisabled != oldWidget.isDisabled) {
      setState(() {
        isDisabled = widget.isDisabled;
      });
    }
  }

  void setDisabled(bool disabled) {
    setState(() {
      isDisabled = disabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : () {
        widget.onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          image: isDisabled ? const DecorationImage(
            image: AssetImage('images/disabled_button.png'),
            fit: BoxFit.fitHeight
          ) : null,
          color: isDisabled ? widget.colorProfile.buttonColor : widget.colorProfile.buttonColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: widget.colorProfile.contrastTextColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}