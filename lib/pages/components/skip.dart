import 'package:flutter/material.dart';

class Skip extends StatelessWidget {
  const Skip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        SizedBox(
          width: 500,
          child: SkipButton()
        )
      ],
    );
  }
}

class SkipButton extends StatefulWidget {
  const SkipButton({
    super.key
  });

  @override
  State<StatefulWidget> createState() => SkipButtonState();
}

class SkipButtonState extends State<SkipButton> {

  Future showSkipDialog() {
    List<Widget> answerDialogList = [
      TextButton(
        onPressed: () async {
          Navigator.pop(context);
          Navigator.pop(context);
        }, 
        child: const Text('Yes',
          style: TextStyle(
            color: Colors.black
          ),
        )
      ),
      TextButton(
        onPressed: () async {
          Navigator.pop(context);
        }, 
        child: const Text('No',
          style: TextStyle(
            color: Colors.black
          ),
        )
      )
    ];

    return showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: const Text(
              "Are you sure you want to skip?",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            actions: answerDialogList,
            backgroundColor: Colors.white,
          );
        }
      );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {
        showSkipDialog()
      }, 
      child: const Text("Skip this Question"));
  }
}