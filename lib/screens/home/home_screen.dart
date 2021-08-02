import 'dart:developer';

import 'package:cnc_flutter_app/connections/db_helper.dart';
import 'package:cnc_flutter_app/connections/fitness_activity_db_helper.dart';
import 'package:cnc_flutter_app/connections/metric_db_helper.dart';
import 'package:cnc_flutter_app/connections/symptom_db_helper.dart';
import 'package:cnc_flutter_app/connections/weekly_goals_saved_db_helper.dart';
import 'package:cnc_flutter_app/models/activity_model.dart';
import 'package:cnc_flutter_app/models/food_log_entry_model.dart';
import 'package:cnc_flutter_app/models/food_model.dart';
import 'package:cnc_flutter_app/models/metric_model.dart';
import 'package:cnc_flutter_app/models/symptom_model.dart';
import 'package:cnc_flutter_app/models/weekly_goals_saved_model.dart';
import 'package:cnc_flutter_app/screens/navigator_screen.dart';
import 'package:cnc_flutter_app/widgets/diet_tracking_widgets/diet_summary_widget.dart';
import 'package:cnc_flutter_app/widgets/food_search.dart';
import 'package:cnc_flutter_app/widgets/user_questions_screen_widgets/user_questions_entry_widget.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FoodLogEntry> dayFoodLogEntryList = [];
  List<ActivityModel> dayActivityList = [];
  List<MetricModel> dayMetricList = [];
  List<SymptomModel> daySymptomList = [];

  refresh() {
    setState(() {
      // getDailyActivity();
    });
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    // rebuildAllChildren(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile')
                  .then((value) => print("okay"));
              // rebuildAllChildren(context));
            },
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        backgroundColor: Theme.of(context).buttonColor,
        children: [
          SpeedDialChild(
              child: Icon(Icons.question_answer),
              label: 'Log Questions',
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (_) => AddQuestionScreen(false, null)));
              }),
          SpeedDialChild(
              child: Icon(Icons.thermostat_outlined),
              label: 'Log Symptoms',
              onTap: () async {
                await Navigator.pushNamed(context, '/inputSymptom')
                    .then((value) => setState(() {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(content: Text("$value")));
                        }));
                await getDailySymptom();
                // rebuildAllChildren(context);
                refresh();
              }),
          SpeedDialChild(
              child: Icon(MdiIcons.scale),
              label: 'Log Weight',
              onTap: () async {
                await Navigator.pushNamed(context, '/inputMetric')
                    .then((value) => setState(() {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(content: Text("$value")));
                        }));
                await getDailyWeight();
                rebuildAllChildren(context);
                refresh();
              }),
          // Navigator.pushNamed(context, '/inputActivity');
          SpeedDialChild(
              child: Icon(Icons.directions_run),
              label: 'Log Activity',
              onTap: () async {
                await Navigator.pushNamed(context, '/inputActivity')
                    .then((value) => setState(() {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(content: Text("$value")));
                        }));
                await getDailyActivity();
                rebuildAllChildren(context);
                refresh();
              }),
          SpeedDialChild(
              child: Icon(Icons.food_bank),
              label: 'Log Food',
              onTap: () async {
                await showSearch(
                        context: context,
                        delegate: FoodSearch(DateTime.now().toString()))
                    .then((value) => setState(() {
                          if (value != null) {
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(SnackBar(content: Text("$value")));
                          }

                          // ScaffoldMessenger.of(context)
                          //   ..removeCurrentSnackBar()
                          //   ..showSnackBar(SnackBar(content: Text("$value")));
                          rebuildAllChildren(context);
                          refresh();
                        }));

                // onTap: () {
                //   showSearch(
                //           context: context,
                //           delegate: FoodSearch(DateTime.now().toString()))
                //       .then((value) => rebuildAllChildren(context));
                // }),
              }),

          // SpeedDialChild(
          //     child: Icon(MdiIcons.abTesting),
          //     label: 'Test',
          //     onTap: () {
          //       Navigator.pushNamed(context, '/tests');
          //     }),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: ListView(
            children: [
              DietSummaryWidget(),
              // HomeSummaryCardWidget('food', dayFoodLogEntryList),
              Card(
                color: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Theme.of(context).buttonColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FutureBuilder(
                    future: getDailyFood(),
                    builder: (context, projectSnap) {
                      return Column(
                        children: [
                          ExpansionTile(
                            leading: Icon(
                              Icons.food_bank,
                              color: Theme.of(context).buttonColor,
                              size: 40,
                            ),
                            title: Text('Daily Diet Summary',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Theme.of(context).hintColor)),

                            // Align(
                            //   child: Text('Daily Diet Summary',
                            //       style: TextStyle(
                            //           fontSize: 18.0,
                            //           color: Theme.of(context).hintColor )),
                            //   alignment: Alignment(-1, 0),
                            // ),
                            subtitle: dayFoodLogEntryList.length == 0
                                ? Text('No food tracked today!',
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor))
                                : dayFoodLogEntryList.length == 1
                                    ? Text(
                                        dayFoodLogEntryList.length.toString() +
                                            ' item totaling ' +
                                            getDayFoodCalories().toString() +
                                            ' calories.',
                                        style: TextStyle(
                                            color: Theme.of(context).hintColor))
                                    : Text(
                                        dayFoodLogEntryList.length.toString() +
                                            ' items totaling ' +
                                            getDayFoodCalories().toString() +
                                            ' calories.',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).hintColor)),
                            // subtitle: (dayFoodLogEntryList.length() == 0) ? Text(dayFoodLogEntryList.length.toString() + ' items totaling ' + getDayFoodCalories().toString() +  ' calories.'),
                            children: getDailyFoodChildren(),
                          ),
                        ],
                      );
                    }),
              ),
              Card(
                color: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Theme.of(context).buttonColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FutureBuilder(
                    future: getDailyActivity(),
                    builder: (context, projectSnap) {
                      return Column(
                        children: [
                          ExpansionTile(
                            leading: Icon(
                              Icons.directions_run,
                              color: Theme.of(context).buttonColor,
                              size: 40,
                            ),
                            title: Text("Daily Activity Summary",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context).hintColor)),
                            subtitle: dayActivityList.length == 0
                                ? Text("No activities tracked today!",
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor))
                                : Text(
                                    dayActivityList.length.toString() +
                                        " Activities Logged - " +
                                        getDayActivityMinutes().toString() +
                                        " Minutes",
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor)),
                            // subtitle: dayActivityList.length == 0 ? Text(
                            //     "No activities tracked!") : Text(dayActivityList
                            //     .length.toString() + " activities logged."),
                            children: getDailyActivityChildren(),
                          ),
                        ],
                      );
                    }),
              ),
              Card(
                color: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Theme.of(context).buttonColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FutureBuilder(
                    future: getDailyWeight(),
                    builder: (context, projectSnap) {
                      return Column(
                        children: [
                          ExpansionTile(
                            leading: Icon(
                              MdiIcons.scale,
                              color: Theme.of(context).buttonColor,
                              size: 40,
                            ),
                            title: Text("Daily Weight Summary",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Theme.of(context).hintColor)),
                            subtitle: dayMetricList.length == 0
                                ? Text("No Weight Logged Today!",
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor))
                                : dayMetricList.length == 1
                                    ? Text(
                                        dayMetricList.length.toString() +
                                            " Weight Logged",
                                        style: TextStyle(
                                            color: Theme.of(context).hintColor))
                                    : Text(
                                        dayMetricList.length.toString() +
                                            " Weights Logged",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).hintColor)),
                            // subtitle: dayActivityList.length == 0 ? Text(
                            //     "No activities tracked!") : Text(dayActivityList
                            //     .length.toString() + " activities logged."),
                            children: getDailyWeightChildren(),
                          ),
                        ],
                      );
                    }),
              ),
              Card(
                color: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Theme.of(context).buttonColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FutureBuilder(
                    future: getDailySymptom(),
                    builder: (context, projectSnap) {
                      return Column(
                        children: [
                          ExpansionTile(
                            leading: Icon(
                              Icons.thermostat_outlined,
                              color: Theme.of(context).buttonColor,
                              size: 40,
                            ),
                            title: Text("Daily Symptom Summary",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Theme.of(context).hintColor)),
                            subtitle: daySymptomList.length == 0
                                ? Text("No Symptoms Logged Today!",
                                    style: TextStyle(
                                        color: Theme.of(context).hintColor))
                                : daySymptomList.length == 1
                                    ? Text("1 Symptom logged",
                                        style: TextStyle(
                                            color: Theme.of(context).hintColor))
                                    : Text(
                                        daySymptomList.length.toString() +
                                            " Symptoms Logged",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).hintColor)),
                            // subtitle: dayActivityList.length == 0 ? Text(
                            //     "No activities tracked!") : Text(dayActivityList
                            //     .length.toString() + " activities logged."),
                            children: getDailySymptomChildren(),
                          ),
                        ],
                      );
                    }),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: WeeklyCalorieWidget(),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: MetricSummaryWidget(),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: ActivitySummaryWidget(),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: SymptomSummaryWidget(),
              // ),
              // Container(
              //   height: 50,
              // ),
            ],
          )),
    );
  }

  getDailyFood() async {
    List<FoodLogEntry> newFoodLogEntry = [];
    DBHelper db = new DBHelper();
    var response = await db.getFoodLog(DateTime.now().toIso8601String());
    var data = json.decode(response.body);
    for (int i = 0; i < data.length; i++) {
      FoodLogEntry foodLogEntry = new FoodLogEntry();
      foodLogEntry.portion = data[i]['portion'];
      Food food = new Food();
      String description = data[i]['food']['description'].toString();
      description = description.replaceAll('"', "");
      food.description = description;

      food.kcal = data[i]['food']['kcal'];
      // food.proteinInGrams = data[i]['food']['proteinInGrams'];
      // food.carbohydratesInGrams = data[i]['food']['carbohydratesInGrams'];
      // food.fatInGrams = data[i]['food']['fatInGrams'];
      // food.alcoholInGrams = data[i]['food']['alcoholInGrams'];
      // food.saturatedFattyAcidsInGrams =
      // data[i]['food']['saturatedFattyAcidsInGrams'];
      // food.polyunsaturatedFattyAcidsInGrams =
      // data[i]['food']['polyunsaturatedFattyAcidsInGrams'];
      // food.monounsaturatedFattyAcidsInGrams =
      // data[i]['food']['monounsaturatedFattyAcidsInGrams'];
      // food.insolubleFiberInGrams = data[i]['food']['insolubleFiberInGrams'];
      // food.solubleFiberInGrams = data[i]['food']['solubleFiberInGrams'];
      // food.sugarInGrams = data[i]['food']['sugarInGrams'];
      // food.calciumInMilligrams = data[i]['food']['calciumInMilligrams'];
      // food.sodiumInMilligrams = data[i]['food']['sodiumInMilligrams'];
      // food.vitaminDInMicrograms = data[i]['food']['vitaminDInMicrograms'];
      // food.commonPortionSizeAmount = data[i]['food']['commonPortionSizeAmount'];
      // food.commonPortionSizeGramWeight =
      // data[i]['food']['commonPortionSizeGramWeight'];
      // food.commonPortionSizeDescription =
      // data[i]['food']['commonPortionSizeDescription'];
      // food.commonPortionSizeUnit = data[i]['food']['commonPortionSizeUnit'];
      // food.nccFoodGroupCategory = data[i]['food']['nccFoodGroupCategory'];
      foodLogEntry.food = food;
      newFoodLogEntry.add(foodLogEntry);
    }
    dayFoodLogEntryList = newFoodLogEntry;
  }

  getDailyActivity() async {
    ActivityDBHelper db = new ActivityDBHelper();
    var sharedPref = await SharedPreferences.getInstance();
    String id = sharedPref.getString('id')!;
    var response = await db.getDayActivityList(int.parse(id));
    List<ActivityModel> newActivityList = (json.decode(response.body) as List)
        .map((data) => ActivityModel.fromJson(data))
        .toList();
    dayActivityList = newActivityList;
  }

  getDailyWeight() async {
    MetricDBHelper db = new MetricDBHelper();
    var sharedPref = await SharedPreferences.getInstance();
    String id = sharedPref.getString('id')!;
    var response = await db.getDayMetricList(int.parse(id));
    List<MetricModel> newMetricList = (json.decode(response.body) as List)
        .map((data) => MetricModel.fromJson(data))
        .toList();
    dayMetricList = newMetricList;
  }

  getDailySymptom() async {
    SymptomDBHelper db = new SymptomDBHelper();
    var sharedPref = await SharedPreferences.getInstance();
    String id = sharedPref.getString('id')!;
    var response = await db.getDaySymptomList(int.parse(id));
    List<SymptomModel> newSymptomList = (json.decode(response.body) as List)
        .map((data) => SymptomModel.fromJson(data))
        .toList();
    daySymptomList = newSymptomList;
  }

  getDailyActivityChildren() {
    if (dayActivityList.isEmpty) {
      return <Widget>[
        Text("Nothing here. Log some activities.",
            style: TextStyle(color: Theme.of(context).hintColor)),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/fitnessTracking')
                  .then((value) => setState(() {
                        refresh();
                        rebuildAllChildren(context);
                      }));
            },
            child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: Text("View All Activities",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor))),
                )))
      ];
    } else if (dayActivityList.isNotEmpty) {
      return <Widget>[
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: dayActivityList.length,
          itemBuilder: (context, index) {
            final item = dayActivityList[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 2, 0, 2),
              child: Text(
                  "- " +
                      item.type +
                      " for " +
                      item.minutes.toString() +
                      " minutes.",
                  style: TextStyle(color: Theme.of(context).hintColor)),
            );
          },
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/fitnessTracking')
                  .then((value) => setState(() {
                        refresh();
                        // rebuildAllChildren(context);
                      }));
            },
            child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: Text("View All Activities",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor))),
                )))
      ];
    }
    return <Widget>[];
  }

  getDailyFoodChildren() {
    if (dayFoodLogEntryList.isEmpty) {
      return <Widget>[
        Text("Nothing here. Log some foods.",
            style: TextStyle(color: Theme.of(context).hintColor)),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/dietTracking')
                  .then((value) => setState(() {
                        refresh();
                        rebuildAllChildren(context);
                      }));
            },
            child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: Text("View Today's Food Log",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor))),
                )))
      ];
    } else if (dayFoodLogEntryList.isNotEmpty) {
      return <Widget>[
        // Padding(padding: const EdgeInsets.fromLTRB(8,0,8,0),  child: Container(
        //   padding: const EdgeInsets.fromLTRB(0,8,0,8),
        // width: double.infinity,
        // decoration: BoxDecoration(
        // color: Theme.of(context).buttonColor,
        // ),
        // child:
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: dayFoodLogEntryList.length,
          itemBuilder: (context, index) {
            final item = dayFoodLogEntryList[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 0, 2),
              child: Text("- " + item.food.description,
                  style: TextStyle(color: Theme.of(context).hintColor)),
            );
          },
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/dietTracking')
                  .then((value) => setState(() {
                        refresh();
                        rebuildAllChildren(context);
                      }));
            },
            child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Text("View Today's Food Log",
                        style:
                            TextStyle(color: Theme.of(context).highlightColor)),
                  ),
                )))
      ];
    }
    return <Widget>[];
  }

  getDailyWeightChildren() {
    if (dayMetricList.isEmpty) {
      return <Widget>[
        Text("Nothing here. Log your weight!",
            style: TextStyle(color: Theme.of(context).hintColor)),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/metricTracking')
                  .then((value) => setState(() {
                        refresh();
                        rebuildAllChildren(context);
                      }));
            },
            child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: Text("View Weight Log",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor))),
                )))
      ];
    } else if (dayMetricList.isNotEmpty) {
      return <Widget>[
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: dayMetricList.length,
          itemBuilder: (context, index) {
            final item = dayMetricList[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 2, 0, 2),
              child: Text(
                  "- " +
                      item.weight.toString() +
                      "lbs @ " +
                      DateFormat.Hm().format(item.dateTime.toLocal()),
                  style: TextStyle(color: Theme.of(context).hintColor)),
            );
          },
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/metricTracking')
                  .then((value) => setState(() {
                        refresh();
                        rebuildAllChildren(context);
                      }));
            },
            child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: Text("View Weight Log",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor))),
                )))
      ];
    }
    return <Widget>[];
  }

  getDayActivityMinutes() {
    int minutes = 0;
    for (ActivityModel activityModel in dayActivityList) {
      minutes += activityModel.minutes;
    }
    return minutes;
  }

  getDayFoodCalories() {
    double calories = 0;
    for (FoodLogEntry foodLogEntry in dayFoodLogEntryList) {
      calories += (foodLogEntry.food.kcal * foodLogEntry.portion);
    }
    return calories.toInt();
  }

  getGoals() async {
    var db2 = new WeeklySavedDBHelper();
    weeklySavedGoalsModelList.clear();
    var response2 = await db2.getWeeklySavedGoalsByUserID();
    var wGDecode2 = json.decode(response2.body);
  }

  getDailySymptomChildren() {
    if (daySymptomList.isEmpty) {
      return <Widget>[
        Text("No Symptoms Tracked Today!",
            style: TextStyle(color: Theme.of(context).hintColor)),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/symptomTracking')
                  .then((value) => setState(() {
                        refresh();
                        // rebuildAllChildren(context);
                      }));
            },
            child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: Text("View Symptom Log",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor))),
                )))
      ];
    } else if (daySymptomList.isNotEmpty) {
      return <Widget>[
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: daySymptomList.length,
          itemBuilder: (context, index) {
            final item = daySymptomList[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 2, 0, 2),
              child: Text(
                  "- " +
                      "Symptom(s) recorded @ " +
                      DateFormat.Hm().format(item.dateTime.toLocal()),
                  style: TextStyle(color: Theme.of(context).hintColor)),
            );
          },
        ),
        TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/symptomTracking')
                  .then((value) => setState(() {
                        refresh();
                        // rebuildAllChildren(context);
                      }));
            },
            child: Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      child: Text("View Symptom Log",
                          style: TextStyle(
                              color: Theme.of(context).highlightColor))),
                )))
      ];
    }
    return <Widget>[];
  }
}
