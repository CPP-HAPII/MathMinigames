

import 'package:flutter/material.dart';
import 'package:onwards/pages/components/calculator.dart';
import 'package:onwards/pages/components/progress_bar.dart';
import 'package:onwards/pages/components/skip.dart';
import 'package:onwards/pages/constants.dart';
import 'package:onwards/pages/game_data.dart';
import 'package:onwards/pages/home.dart';
import 'package:onwards/pages/score_display.dart';

import 'package:onwards/pages/activities/game_page.dart';
import 'package:onwards/pages/activities/reading/speech_to_text_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

const ReadAloudGameData dummyData = ReadAloudGameData(displayedProblem: "", multiAcceptedAnswers: [], skills: []);

class ReadingActivityScreen extends StatelessWidget {
  const ReadingActivityScreen({
    super.key,
    this.colorProfile = lightFlavor,
    this.readingGameData = dummyData,
    this.fromLevelSelect = false
  });

  final ColorProfile colorProfile;
  final ReadAloudGameData readingGameData;
  final bool fromLevelSelect;

  const ReadingActivityScreen.fromLevelSelect({required ReadAloudGameData readingData, required ColorProfile profile, super.key}) :
    colorProfile = profile,
    readingGameData = readingData,
    fromLevelSelect = true;

  @override
  Widget build(BuildContext context) {
    ReadAloudGameData randomData = gameDataBank.getRandomReadingElement();

    return Scaffold(
      appBar: AppBar(
        title: Text('Read Aloud Game', style: TextStyle(color: colorProfile.textColor)),
        backgroundColor: colorProfile.headerColor,
        actions: const [Skip(), ScoreDisplayAction(), CalcButton()],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: colorProfile.backBoxDecoration,
        padding: const EdgeInsets.only(top: 40),
        child: !fromLevelSelect ?
          AudioTranscriptionWidget(
            key: const Key('1'),
            acceptedAnswers: randomData.multiAcceptedAnswers,
            questionLabel: randomData.displayedProblem,
            titleText: randomData.writtenPrompt,
            useNumWordProtocol: randomData.useNumWordProtocol,
            colorProfile: colorProfile,
            skills: randomData.skills,
            id: randomData.id
          ) :
          AudioTranscriptionWidget(
            key: const Key('1'),
            acceptedAnswers: readingGameData.multiAcceptedAnswers,
            questionLabel: readingGameData.displayedProblem,
            titleText: readingGameData.writtenPrompt,
            useNumWordProtocol: readingGameData.useNumWordProtocol,
            colorProfile: colorProfile,
            skills: readingGameData.skills,
            id: readingGameData.id
          )
      )
    );
  }
}

class AudioTranscriptionWidget extends GamePage {
  const AudioTranscriptionWidget({
    super.key,
    required this.acceptedAnswers,
    required this.questionLabel,
    required this.titleText,
    super.colorProfile,
    this.useNumWordProtocol = true,
    required this.skills,
    required this.id
  });

  final String questionLabel;
  final List<List<String>> acceptedAnswers;
  final String titleText;
  final bool useNumWordProtocol;
  final List<String> skills;
  final String id;

  @override
  AudioTranscriptionWidgetState createState() => AudioTranscriptionWidgetState();
}

class AudioTranscriptionWidgetState extends GamePageState<AudioTranscriptionWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String defaultTranscribedText = "Press the button to start speaking and your words will appear here!";
  String _transcribedText = "Press the button to start speaking and your words will appear here!";
  String listenNotifier = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    // we get here from the microphone button

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => logger.i('onStatus: $val'),
        onError: (val) => logger.e('onError: $val'),
      );
      if (available && mounted) {
        setState(() => _isListening = true);
          _speech.listen(
            listenFor: const Duration(minutes: 2),
            onSoundLevelChange: (val) => {
              setState(() {
                listenNotifier = "Listening...";
              })
            },
            listenOptions: stt.SpeechListenOptions(partialResults: true, cancelOnError: true, onDevice: false),
            onResult: (val) => setState(() {
              _transcribedText = val.recognizedWords;
              if (widget.useNumWordProtocol) {
                _transcribedText = convertNumbersAndSymbolsToWords(_transcribedText);
              }
            }
          )
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  bool validateAnswer() {
    bool isCorrect = true;

    for (List<String> answerList in widget.acceptedAnswers) {
      for (String potentialAnswer in answerList) {
        if (_transcribedText.toLowerCase() != potentialAnswer) {
          logger.i("Could not find a match in one of the answers");
          isCorrect = false;
        } else {
          logger.i("Found one match in one of the answers");
          isCorrect = true;
          return isCorrect;
        }
      }
    }
    return isCorrect;
  }

  void clearText() {
    stopEngine();
    setState(() {
      _transcribedText = defaultTranscribedText;
    });
  }

  void stopEngine() {
    setState(() {
      _isListening = false;
      _speech.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isValid;
    
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
                  widget.titleText,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Your phrase",
                        style: TextStyle(
                          fontSize: 14,
                          color: currentProfile.textColor
                        ),
                      ),
                      Text(
                        listenNotifier,
                        style: TextStyle(
                          fontSize: 14,
                          color: currentProfile.textColor
                        ),
                      ),
                      Text(
                        _transcribedText,
                        style: TextStyle(
                          fontSize: 18,
                          color: currentProfile.textColor
                        ),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        onPressed: _listen,
                        backgroundColor: currentProfile.buttonColor,
                        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isListening || _speech.isListening ? stopEngine : () => {
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
                    ),
                    TextButton(
                      onPressed: () => {
                        clearText()
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
      ),
    );
  }
}