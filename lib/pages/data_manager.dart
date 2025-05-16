import 'package:onwards/pages/home.dart';

class PageDataManager {
  static final PageDataManager _instance = PageDataManager._internal();

  factory PageDataManager() => _instance;

  PageDataManager._internal();

  // This holds data from each page
  final List<Map<String, dynamic>> _allPageData = [];

  void addPageData(Map<String, dynamic> data) {
    _allPageData.add(data);
  }

  void prettyPrintPageData() {
    String questionCollection = "";
    for (Map<String, dynamic> map in _allPageData) {
      String questionEntry = "";
      for (MapEntry<String, dynamic> mapEntry in map.entries) {
        String entry = "${mapEntry.key} = ${mapEntry.value}";
        questionEntry = "$questionEntry | $entry";
      }
      questionCollection = "$questionCollection, [ $questionEntry ]";
    }
    logger.i("Current Data Snapshot: $questionCollection");
  }

  List<Map<String, dynamic>> get allData => _allPageData;

  void reset() {
    _allPageData.clear();
  }
}