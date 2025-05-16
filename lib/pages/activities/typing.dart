import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_page.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/components/skip.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';

const TypingGameData dummyData = TypingGameData(
    displayedProblem: "", multiAcceptedAnswers: ["", ""], skills: []);

class TypeActivityScreen extends StatelessWidget {
  final ColorProfile colorProfile;
  final TypingGameData typingGameData;
  final bool fromLevelSelect;

  /// The default constructor that doesn't ask for the gameData.
  const TypeActivityScreen(
      {super.key,
      this.colorProfile = lightFlavor,
      this.typingGameData = dummyData,
      this.fromLevelSelect = false});

  /// Using this constructor allows a gameData to be passed instead of randomly picked from the bank
  const TypeActivityScreen.fromLevelSelect(
      {required ColorProfile profile,
      required TypingGameData typingData,
      super.key})
      : colorProfile = profile,
        typingGameData = typingData,
        fromLevelSelect = true;

  @override
  Widget build(BuildContext context) {
    TypingGameData randomGameData = gameDataBank.getRandomTypingElement();

    return Scaffold(
        appBar: AppBar(
          title: Text('Type it Out Game',
              style: TextStyle(color: colorProfile.textColor)),
          backgroundColor: colorProfile.headerColor,
          actions: const [Skip(), ScoreDisplayAction(), CalcButton()],
          automaticallyImplyLeading: false,
        ),
        body: Container(
            decoration: colorProfile.backBoxDecoration,
            padding: const EdgeInsets.only(top: 40),
            child: !fromLevelSelect
                ? GameForm(
                    // Using the bank's random game data
                    answers: randomGameData.multiAcceptedAnswers,
                    questionLabel: randomGameData.displayedProblem,
                    instructions: randomGameData.writtenPrompt,
                    colorProfile: colorProfile,
                    skills: randomGameData.skills,
                    id: randomGameData.id,
                  )
                : GameForm(
                    // Using the passed gameData
                    answers: typingGameData.multiAcceptedAnswers,
                    questionLabel: typingGameData.displayedProblem,
                    instructions: typingGameData.writtenPrompt,
                    colorProfile: colorProfile,
                    skills: typingGameData.skills,
                    id: typingGameData.id,
                  )));
  }
}

/// Show this game's unique game form using the data
/// passed from GameData. The idea is to have the game
/// move to the next question after the dialog, using context
/// to pass the info over
class GameForm extends GamePage {
  const GameForm(
      {super.key,
      super.colorProfile,
      required this.answers,
      required this.questionLabel,
      required this.instructions,
      required this.skills,
      required this.id});

  final String questionLabel;
  final List<String> answers;
  final String instructions;
  final count = 0;
  final List<String> skills;
  final String id;

  @override
  State<GameForm> createState() => _GameFormState();
}

class _GameFormState extends GamePageState<GameForm> {
  // data for cache
  final _answerFieldController = TextEditingController();

  // data for database
  bool lastCorrectState = false;

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

  /// Checks the answer in the field against the accepted answers. The answer in the
  /// field is turned to lowercase before validation
  bool validateAnswer() {
    var isCorrect = true;
    if (widget.count > 0) {
    } else {
      for (String potAnswer in widget.answers) {
        logger.i("Validating against $potAnswer");
        if (potAnswer != _answerFieldController.text) {
          isCorrect = false;
          // print("Answer was incorrect at: $potAnswer");
        } else {
          isCorrect = true;
          return isCorrect;
        }
      }
    }
    return isCorrect;
  }

  @override
  Widget build(BuildContext context) {
    bool valid;

    return Container(
        decoration: currentProfile.backBoxDecoration,
        child: Stack(
          children: [
            addConfettiBlasters(),
            Align(
              alignment: Alignment.center,
              child: Form(
                key: const Key("_formKey"),
                child: Column(
                  children: [
                    Text(
                      widget.instructions,
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
                    SizedBox(
                        width: 500.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                              maxLines: 3,
                              controller: _answerFieldController,
                              decoration: InputDecoration(
                                hintText: 'Type your answer...',
                                labelText: 'Your Answer',
                                filled: true,
                                hintStyle: TextStyle(
                                    color: currentProfile.textColor,
                                    fontSize: 18),
                                fillColor: Colors.grey,
                                labelStyle: TextStyle(
                                    color: currentProfile.textColor,
                                    fontSize: 18),
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                              ),
                              onFieldSubmitted: (value) {
                                showGameOverlay(-1);
                              }),
                        )),
                    TextButton(
                        onPressed: () => {
                              // note: validate should be called once to avoid inconsistencies
                              valid = validateAnswer(),
                              isCorrect = valid,
                              if (valid)
                                {showGameOverlay(-1)}
                              else
                                {showCorrectDialog(valid, currentProfile, -1)}
                            },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              currentProfile.checkAnswerButtonColor),
                        ),
                        child: Text(
                          'Check Answer',
                          style: TextStyle(
                              color: currentProfile.contrastTextColor),
                        ))
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: ProgressBar(),
            )
          ],
        ));
  }
}
