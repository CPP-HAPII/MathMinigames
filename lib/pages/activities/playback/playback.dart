import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:onwards/pages/activities/game_page.dart';
import 'package:onwards/pages/activities/jumble.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/components/skip.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';
import 'package:onwards/pages/tts.dart';

const PlaybackGameData dummyData = PlaybackGameData(webAudioLink: "", multiAcceptedAnswers: [], writtenPrompt: "", optionList: [], skills: []);

class PlaybackActivityScreen extends StatelessWidget {
  final ColorProfile colorProfile;
  final PlaybackGameData playbackGameData;
  final bool fromLevelSelect;

  const PlaybackActivityScreen({
    super.key,
    this.colorProfile = lightFlavor,
    this.playbackGameData = dummyData,
    this.fromLevelSelect = false
  });

  const PlaybackActivityScreen.fromLevelSelect({super.key, required PlaybackGameData gameData, required ColorProfile profile}) :
    colorProfile = profile,
    playbackGameData = gameData,
    fromLevelSelect = true;

  @override
  Widget build(BuildContext context) {
    PlaybackGameData randomData = gameDataBank.getRandomPlaybackElement();

    return Scaffold(
      appBar: AppBar(
        title: Text('Playback and Answer Game', style: TextStyle(color: colorProfile.textColor)),
        backgroundColor: colorProfile.headerColor,
        actions: const [Skip(), ScoreDisplayAction(), CalcButton()],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
        child: !fromLevelSelect ?
          PlaybackGameForm(
            audioSource: AssetSource(randomData.webAudioLink),
            answers: randomData.multiAcceptedAnswers, 
            questionLabel: randomData.audioTranscript, 
            maxSelectedAnswers: randomData.getMinSelection(), 
            buttonOptions: randomData.optionList,
            titleQuestion: randomData.writtenPrompt,
            showArithmitic: true,
            colorProfile: colorProfile,
            skills: randomData.skills,
            id: randomData.id
          ) :
          PlaybackGameForm(
            audioSource: AssetSource(playbackGameData.webAudioLink),
            answers: playbackGameData.multiAcceptedAnswers, 
            questionLabel: playbackGameData.audioTranscript, 
            maxSelectedAnswers: playbackGameData.getMinSelection(), 
            buttonOptions: playbackGameData.optionList,
            titleQuestion: playbackGameData.writtenPrompt,
            showArithmitic: true,
            colorProfile: colorProfile,
            skills: playbackGameData.skills,
            id: playbackGameData.id
          ),
      )
    );
  }
}

// Show this game's unique game form using the data
// passed from GameData. The idea is to have the game
// move to the next question after the dialog, using context
// to pass the info over
class PlaybackGameForm extends GamePage {
  const PlaybackGameForm({
    super.key,
    required this.answers, 
    required this.questionLabel,
    required this.maxSelectedAnswers,
    required this.buttonOptions,
    required this.titleQuestion,
    required this.showArithmitic,
    super.colorProfile,
    required this.audioSource,
    required this.skills,
    required this.id
  });

  final AssetSource audioSource;
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
  final String id;

  @override
  PlaybackGameFormState createState() => PlaybackGameFormState();
}

class PlaybackGameFormState extends GamePageState<PlaybackGameForm> {

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

  /// Validate the current selection against the multiple answers
  int validateAnswer() {
    int errorIndex = 0;
    bool isCorrect = true;
    if (currentCount >= maxSelection) {
      for (List<String> answerList in widget.answers) {
        for (int i = 0; i < answerList.length; i++) {
          if (_selectedAnswers[i] != answerList[i]) {
            logger.d("Validating Answer: Expected ${answerList[i]}");
            isCorrect = false;
            errorIndex = i;
          }
        }
        
        // when we are done going through one answer, if its correct, just skip checking the rest
        if (isCorrect) {
          return -1;
        } else {
          return errorIndex;
        }
      }
    } else {
      logger.d("Not enough answers are selected, could not validate");
      return 0;
    }
    return 0;
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
                  TTSRunner(voiceLine: widget.questionLabel),
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
                            showCorrectDialog(validIndex < 0, currentProfile, validIndex)
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
                        )
                    ],
                  )
                ],
              ),  
            )
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: ProgressBar(),
          )
        ],
      ),
    );
  }
}