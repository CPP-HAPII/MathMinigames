

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return ProgressBarState();
  }
}

class ProgressBarState extends State<ProgressBar> {
  final Future<SharedPreferencesWithCache> _prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{'progress'}
      )
    );

  late Future<double> progressCache;

  @override
  void initState() {
    progressCache = _prefs.then((SharedPreferencesWithCache prefs) {
      return prefs.getDouble('progress') ?? 0.0;
    });
    super.initState();
  }
    
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 75,
      child: Center(
        child: FutureBuilder<double>(
        future: progressCache,
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error ${snapshot.error}');
              } else {
                  return Center(
                    child: LinearPercentIndicator(
                      alignment: MainAxisAlignment.center,
                      width: 400,
                      lineHeight: 40.0,
                      animationDuration: 3000,
                      percent: (snapshot.data != null ? snapshot.data!.toDouble() : 0.0),
                      animateFromLastPercent: true,
                      center: Text("${(snapshot.data != null ? snapshot.data!.toDouble() : 0.0) * 100}%"),
                      progressColor: Colors.green,
                    ),
                  );
              }
            }
          }
        ),
      )
    );
  }
}