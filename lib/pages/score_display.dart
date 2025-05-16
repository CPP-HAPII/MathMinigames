

import 'package:flutter/material.dart';
import 'package:onwards/pages/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreDisplayAction extends StatelessWidget {
  const ScoreDisplayAction({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        SizedBox(
          width: 400,
          child: ScoreDisplayWidget(currentProfile: lightFlavor),
        )
      ],
    );
  }  
}

class ScoreDisplayWidget extends StatefulWidget {
  const ScoreDisplayWidget({
    super.key,
    required this.currentProfile
  });

  final ColorProfile currentProfile;

  @override
  ScoreDisplayWidgetState createState() => ScoreDisplayWidgetState();
}

class ScoreDisplayWidgetState extends State<ScoreDisplayWidget> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'score'}
      ));

  late Future<int> scoreCount;

  @override
  void initState() {
    scoreCount = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getInt('score') ?? 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<int>(
        future: scoreCount, 
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}', style: TextStyle(color: widget.currentProfile.textColor));
              } else {
                return Text(
                  'Score: ${snapshot.data}',
                  style: TextStyle(
                    color: widget.currentProfile.textColor
                  ),
                );
              }
          }
        }
      ),
    );
  }
}