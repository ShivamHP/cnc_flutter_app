import 'dart:convert';

import 'package:cnc_flutter_app/connections/db_helper.dart';
import 'package:cnc_flutter_app/models/food_log_entry_model.dart';
import 'package:cnc_flutter_app/models/food_model.dart';

// import 'package:cnc_flutter_app/screens/nutrient_ratio_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DailySummaryWidget extends StatefulWidget {
  @override
  _DailySummaryWidgetState createState() => _DailySummaryWidgetState();
}

class _DailySummaryWidgetState extends State<DailySummaryWidget> {
  late int dailyCalorieLimit;
  late int dailyProteinLimit;
  late int dailyCarbohydrateLimit;
  late int dailyFatLimit;
  int caloriesRemaining = 0;
  int proteinRatio = 0;
  int carbohydrateRatio = 0;
  int fatRatio = 0;
  double caloriePercent = 0;
  double proteinPercent = 0;
  double carbohydratePercent = 0;
  double fatPercent = 0;
  double kcal = 0;
  double proteinInGrams = 0;
  double fatInGrams = 0;
  double carbohydratesInGrams = 0;
  String calorieMessage = "CALORIES LEFT";
  bool showGrams = false;
  late int userId;
  bool isLoading = false;

  List<FoodLogEntry> dailyFoodLogEntryList = [];

  @override
  void initState() {
    dailyFoodLogEntryList.clear();
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  getFood() async {
    dailyFoodLogEntryList.clear();
    isLoading = true;
    var db = new DBHelper();
    var x = await db.getUserInfo();
    var userData = json.decode(x.body);

    if (userData['weight'] <= 174) {
      dailyCalorieLimit = 1200;
    } else if (userData['weight'] > 174 && userData['weight'] <= 219) {
      dailyCalorieLimit = 1500;
    } else if (userData['weight'] > 219 && userData['weight'] <= 249) {
      dailyCalorieLimit = 1800;
    } else {
      dailyCalorieLimit = 2000;
    }
    caloriesRemaining = 0;
    caloriePercent = 0;
    proteinPercent = 0;
    carbohydratePercent = 0;
    fatPercent = 0;
    kcal = 0;
    proteinInGrams = 0;
    fatInGrams = 0;
    carbohydratesInGrams = 0;

    proteinRatio = userData['proteinPercent'];
    carbohydrateRatio = userData['carbohydratePercent'];
    fatRatio = userData['fatPercent'];
    dailyCarbohydrateLimit =
        (dailyCalorieLimit * (carbohydrateRatio / 100)).truncate();
    dailyProteinLimit = (dailyCalorieLimit * (proteinRatio / 100)).truncate();
    dailyFatLimit = (dailyCalorieLimit * (fatRatio / 100)).truncate();
    dailyFoodLogEntryList.clear();
    DateTime selectedDate = DateTime.now();
    String key = selectedDate.toString().split(" ")[0];
    var response = await db.getFoodLog(key);
    var data = json.decode(response.body);
    for (int i = 0; i < data.length; i++) {
      FoodLogEntry foodLogEntry = new FoodLogEntry();
      foodLogEntry.id = data[i]['id'];
      foodLogEntry.entryTime = data[i]['entryTime'];
      foodLogEntry.date = data[i]['date'];
      foodLogEntry.portion = data[i]['portion'];
      Food food = new Food();
      String description = data[i]['food']['description'].toString();
      description = description.replaceAll('"', "");
      food.description = description;
      food.kcal = data[i]['food']['kcal'];
      food.proteinInGrams = data[i]['food']['proteinInGrams'];
      food.carbohydratesInGrams = data[i]['food']['carbohydratesInGrams'];
      food.fatInGrams = data[i]['food']['fatInGrams'];
      food.alcoholInGrams = data[i]['food']['alcoholInGrams'];
      food.saturatedFattyAcidsInGrams =
          data[i]['food']['saturatedFattyAcidsInGrams'];
      food.polyunsaturatedFattyAcidsInGrams =
          data[i]['food']['polyunsaturatedFattyAcidsInGrams'];
      food.monounsaturatedFattyAcidsInGrams =
          data[i]['food']['monounsaturatedFattyAcidsInGrams'];
      food.insolubleFiberInGrams = data[i]['food']['insolubleFiberInGrams'];
      food.solubleFiberInGrams = data[i]['food']['solubleFiberInGrams'];
      food.sugarInGrams = data[i]['food']['sugarInGrams'];
      food.calciumInMilligrams = data[i]['food']['calciumInMilligrams'];
      food.sodiumInMilligrams = data[i]['food']['sodiumInMilligrams'];
      food.vitaminDInMicrograms = data[i]['food']['vitaminDInMicrograms'];
      food.commonPortionSizeAmount = data[i]['food']['commonPortionSizeAmount'];
      food.commonPortionSizeGramWeight =
          data[i]['food']['commonPortionSizeGramWeight'];
      food.commonPortionSizeDescription =
          data[i]['food']['commonPortionSizeDescription'];
      food.commonPortionSizeUnit = data[i]['food']['commonPortionSizeUnit'];
      foodLogEntry.food = food;
      dailyFoodLogEntryList.add(foodLogEntry);
    }
    for (FoodLogEntry foodLogEntry in dailyFoodLogEntryList) {
      double portion = foodLogEntry.portion;
      Food food = foodLogEntry.food;
      kcal += (food.kcal * portion);
      proteinInGrams += (food.proteinInGrams * portion);
      fatInGrams += (food.fatInGrams * portion);
      carbohydratesInGrams += (food.carbohydratesInGrams * portion);
    }
    caloriesRemaining = (dailyCalorieLimit - kcal).truncate();
    caloriePercent = kcal / dailyCalorieLimit;
    proteinPercent = (proteinInGrams * 4) / dailyProteinLimit;
    carbohydratePercent = (carbohydratesInGrams * 4) / dailyCarbohydrateLimit;
    fatPercent = (fatInGrams * 9) / dailyFatLimit;
    if (caloriePercent > 1) {
      caloriePercent = 1;
    }
    if (proteinPercent > 1) {
      proteinPercent = 1;
    }
    if (carbohydratePercent > 1) {
      carbohydratePercent = 1;
    }
    if (fatPercent > 1) {
      fatPercent = 1;
    }
    if (caloriesRemaining < 0) {
      calorieMessage = "CALORIES OVER";
    } else {
      calorieMessage = 'CALORIES LEFT';
    }
    caloriesRemaining = caloriesRemaining.abs();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if (isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Theme.of(context).buttonColor),
            ),
          );
        } else {
          return Container(
              child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Daily Summary',
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // padding: EdgeInsets.only(left: 55),
                    child: new CircularPercentIndicator(
                      radius: 155.0,
                      animation: true,
                      animationDuration: 1200,
                      lineWidth: 13.0,
                      percent: caloriePercent,
                      center: new Column(
                        children: [
                          Padding(padding: EdgeInsets.all(20)),
                          Text(
                            caloriesRemaining.toString(),
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 40.0),
                          ),
                          Center(
                            child: Text(
                              calorieMessage,
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      circularStrokeCap: CircularStrokeCap.butt,
                      // backgroundColor: Colors.yellow,
                      progressColor: Colors.red,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: new Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new CircularPercentIndicator(
                          radius: 56.0,
                          lineWidth: 5.0,
                          percent: carbohydratePercent,
                          center: new Text(
                              carbohydratesInGrams.truncate().toString() + 'g'),
                          footer: Text("Carbs"),
                          progressColor: Colors.orange,
                        ),
                        new Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                        ),
                        new CircularPercentIndicator(
                          radius: 56.0,
                          lineWidth: 5.0,
                          percent: proteinPercent,
                          center: new Text(
                              proteinInGrams.truncate().toString() + 'g'),
                          footer: Text("Protein"),
                          progressColor: Colors.red,
                        ),
                        new Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                        ),
                        new CircularPercentIndicator(
                          radius: 56.0,
                          lineWidth: 5.0,
                          percent: fatPercent,
                          footer: Text("Fat"),
                          center:
                              new Text(fatInGrams.truncate().toString() + 'g'),
                          progressColor: Colors.yellow,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ));
        }
      },
      future: getFood(),
    );
  }
}
