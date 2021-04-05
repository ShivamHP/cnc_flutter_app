import 'dart:convert';
import 'package:cnc_flutter_app/connections/weekly_goals_db_helper.dart';
import 'package:cnc_flutter_app/connections/weekly_goals_saved_db_helper.dart';
import 'package:cnc_flutter_app/models/weekly_goals_model.dart';
import 'package:cnc_flutter_app/models/weekly_goals_saved_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share/share.dart';

import '../choose_goals_screen.dart';
import '../weekly_goals_screen.dart';

class GoalCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChooseGoalsPage(title: 'Choose Weekly Goals'),
    );
  }
}

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences prefs;

  CalendarController _controller2;
  Map<DateTime, List<dynamic>> _events2;
  List<dynamic> _selectedEvents2;
  TextEditingController _eventController2;
  SharedPreferences prefs2;

  int totalWeeklyGoalsCompleted;
  int totalPersonalGoalsCompleted;

  List<String> goals;
  List<WeeklyGoalsModel> weeklyGoalsModelList = [];
  List<WeeklySavedGoalsModel> weeklySavedGoalsModelList = [];
  var db = new WeeklyDBHelper();
  final db2 = WeeklySavedDBHelper();

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];

    _controller2 = CalendarController();
    _eventController2 = TextEditingController();
    _events2 = {};
    _selectedEvents2 = [];
    initPrefs();

    _events2[_controller2.selectedDay] = [];
    _events2[_controller2.selectedDay].add("Goal 1");
    _events2[_controller2.selectedDay].add("Goal 2");
    _events2[_controller2.selectedDay].add("Goal 3");
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      totalWeeklyGoalsCompleted = prefs.getInt("weekly goal total");
      totalPersonalGoalsCompleted = prefs.getInt("personal goal total");
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Weekly Goals'),
      ),
      body: FutureBuilder(
        builder: (context, projectSnap) {
          return buildGoalCalendarView();
        },
        future: getGoals(),
      ),
    );
  }

  Widget buildGoalCalendarView() {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              events: _events,
              initialCalendarFormat: CalendarFormat.week,
              calendarStyle: CalendarStyle(
                  canEventMarkersOverflow: true,
                  todayColor: Theme.of(context).accentColor,
                  selectedColor: Theme.of(context).primaryColor,
                  todayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white)),
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
                formatButtonShowsNext: false,
              ),
              onDaySelected: (date, events, holidays) {
                setState(() {
                  _selectedEvents = events;
                });
              },
              builders: CalendarBuilders(
                selectedDayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    )),
                todayDayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              calendarController: _controller,
            ),

            Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              color: Theme.of(context).primaryColor,
              alignment: Alignment.bottomLeft,
              child: Column(
                children: <Widget>[
                  ExpansionTile(
                    title: Text(
                      "Weekly Goals",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ElevatedButton(
                              child: Text('Choose Weekly Goals'),
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).accentColor, // background
                                onPrimary: Colors.white, // foreground
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChooseWeeklyGoals()),
                                );
                              },
                            ),
                            ElevatedButton(
                              child: Text('Weekly Goal View'),
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).accentColor, // background
                                onPrimary: Colors.white, // foreground
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WeeklyGoals()),
                                );
                              },
                            ),
                          ]),
                    ],
                  ),
                ],
              ),
            ),


            weeklySavedGoalsModelList.length > 0
                ? _buildWeeklyView()
                : SizedBox(height: 0),

            totalWeeklyGoalsCompleted != null
                ? _buildGetWeeklyCompleted()
                : SizedBox(height: 0),

            //Container(
            //  padding: EdgeInsets.all(15.0),
            //  color: Theme.of(context).primaryColor,
            //  alignment: Alignment.bottomLeft,
            //  child: Text(
            //    'Personal Goals',
            //    style: TextStyle(
            //      fontWeight: FontWeight.bold,
            //      fontSize: 18.0,
            //      color: Colors.white,
            //    ),
            //  ),
            //),

            RaisedButton(
              onPressed: _showAddDialog,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Personal Goals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.black54,
                    )
                  ],
                ),
              ),
            ),

            //Container(
            //  alignment: Alignment.center,
            //  child: ElevatedButton(
            //    child: Text('Add a Personal Goal'),
            //    onPressed: _showAddDialog,
            //  ),
            //),

            _events[_controller.selectedDay] != null
                ? _buildListView()
                : SizedBox(height: 0),

            totalPersonalGoalsCompleted != null
                ? _buildGetPersonalCompleted()
                : SizedBox(height: 0),
          ],
        ),
      );
  }

  Widget _buildGetWeeklyCompleted() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Text(
        'Total Weekly Goals Completed: ' +
            prefs.getInt("weekly goal total").toString(),
        style: TextStyle(
          fontSize: 16.0,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildGetPersonalCompleted() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Text(
        'Total Personal Goals Completed: ' +
            prefs.getInt("personal goal total").toString(),
        style: TextStyle(
          fontSize: 16.0,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _events[_controller.selectedDay].length,
        itemBuilder: (context, index) {
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            child: Container(
              color: Colors.white,
              child: ListTile(
                title: Text(_events[_controller.selectedDay][index].toString()),
              ),
            ),
            actions: <Widget>[
              IconSlideAction(
                caption: 'Complete',
                color: Colors.green,
                icon: Icons.check,
                onTap: () {
                  if (totalPersonalGoalsCompleted == null) {
                    totalPersonalGoalsCompleted = 1;
                    prefs.setInt("goal total", totalPersonalGoalsCompleted);
                  } else {
                    totalPersonalGoalsCompleted =
                        (totalPersonalGoalsCompleted + 1);
                    prefs.setInt("goal total", totalPersonalGoalsCompleted);
                  }

                  _events[_controller.selectedDay].removeAt(index);
                  prefs.setInt(
                      "personal goal total", totalPersonalGoalsCompleted);
                  _eventController.clear();
                  setState(() {
                    if (_events[_controller.selectedDay] != null) {
                      _selectedEvents = _events[_controller.selectedDay];
                    }
                    _showSnackBar(context, 'Deleted Goal');
                  });
                },
              ),
              IconSlideAction(
                  caption: 'Copy',
                  color: Colors.grey[400],
                  icon: Icons.content_copy,
                  onTap: () {
                    FlutterClipboard.copy(
                        _events[_controller.selectedDay][index].toString());
                    _showSnackBar(context, 'Copied to Clipboard');
                  }),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                  caption: 'Share',
                  color: Colors.indigo,
                  icon: Icons.share,
                  onTap: () {
                    Share.share(
                        _events[_controller.selectedDay][index].toString(),
                        subject:
                            'Check out my new goal on the Enact diet tracking app!');
                  }),
              IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    _events[_controller.selectedDay].removeAt(index);
                    prefs.setString("events", json.encode(encodeMap(_events)));
                    _eventController.clear();
                    setState(() {
                      if (_events[_controller.selectedDay] != null) {
                        _selectedEvents = _events[_controller.selectedDay];
                      }
                      _showSnackBar(context, 'Deleted Goal');
                    });
                  }),
            ],
          );
        });
  }

  Widget _buildWeeklyView() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: weeklySavedGoalsModelList.length,
        itemBuilder: (context, index) {
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            child: Container(
              color: Colors.white,
              child: ListTile(
                title:
                    Text(weeklySavedGoalsModelList[index].goalDescription),
              ),
            ),
            actions: <Widget>[
              IconSlideAction(
                  caption: 'Completed',
                  color: Colors.green,
                  icon: Icons.check,
                  onTap: () {
                    if (totalWeeklyGoalsCompleted == null) {
                      totalWeeklyGoalsCompleted = 1;
                      prefs.setInt(
                          "weekly goal total", totalWeeklyGoalsCompleted);
                    } else {
                      totalWeeklyGoalsCompleted =
                          (totalWeeklyGoalsCompleted + 1);
                      prefs.setInt(
                          "weekly goal total", totalWeeklyGoalsCompleted);
                    }

                    _events2[_controller2.selectedDay].removeAt(index);
                    prefs.setInt(
                        "weekly goal total", totalWeeklyGoalsCompleted);
                    _eventController2.clear();
                    setState(() {
                      if (_events2[_controller2.selectedDay] != null) {
                        _selectedEvents2 = _events2[_controller2.selectedDay];
                      }
                      _showSnackBar(context, 'Completed Goal');
                    });
                  }),
              IconSlideAction(
                  caption: 'Copy',
                  color: Colors.grey[400],
                  icon: Icons.content_copy,
                  onTap: () {
                    FlutterClipboard.copy(
                        _events2[_controller2.selectedDay][index].toString());
                    _showSnackBar(context, 'Copied to Clipboard');
                  }),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                  caption: 'Share',
                  color: Colors.indigo,
                  icon: Icons.share,
                  onTap: () {
                    Share.share(
                        _events2[_controller2.selectedDay][index].toString(),
                        subject:
                            'Check out my new goal on the Enact diet tracking app!');
                  }),
              IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    _events2[_controller2.selectedDay].removeAt(index);
                    prefs.setString("events", json.encode(encodeMap(_events2)));
                    _eventController2.clear();
                    setState(() {
                      if (_events2[_controller2.selectedDay] != null) {
                        _selectedEvents2 = _events2[_controller2.selectedDay];
                      }
                      _showSnackBar(context, 'Deleted Goal');
                    });
                  }),
            ],
          );
        });
  }

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  _showAddDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title:
                  Text("Add Goals\n\nType out your full goal then press save."),
              content: TextField(
                controller: _eventController,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Save"),
                  onPressed: () {
                    if (_eventController.text.isEmpty) return;
                    if (_events[_controller.selectedDay] != null) {
                      _events[_controller.selectedDay]
                          .add(_eventController.text);
                    } else {
                      _events[_controller.selectedDay] = [
                        _eventController.text
                      ];
                    }
                    prefs.setString("events", json.encode(encodeMap(_events)));
                    _eventController.clear();
                    Navigator.pop(context);
                  },
                )
              ],
            ));
    setState(() {
      if (_events[_controller.selectedDay] != null) {
        _selectedEvents = _events[_controller.selectedDay];
      }
    });
  }

  getGoals() async {
    weeklyGoalsModelList.clear();
    var db = new WeeklyDBHelper();
    var response = await db.getWeeklyGoals();
    var wGDecode = json.decode(response.body);

    for (int i = 0; i < wGDecode.length; i++) {
      WeeklyGoalsModel weeklyGoalsModel = new WeeklyGoalsModel(
          wGDecode[i]['type'],
          wGDecode[i]['goalDescription'],
          wGDecode[i]['help_info']);
      weeklyGoalsModelList.add(weeklyGoalsModel);
      print(wGDecode[i]['type']);
      print(wGDecode[i]['goalDescription']);
      print(wGDecode[i]['help_info']);
    }
    print(wGDecode.length);

    weeklySavedGoalsModelList.clear();
    var db2 = new WeeklySavedDBHelper();
    var response2 = await db2.getWeeklySavedGoals();
    var wGDecode2 = json.decode(response2.body);

    for (int i = 0; i < wGDecode.length; i++) {
      WeeklySavedGoalsModel weeklySavedGoalsModel = new WeeklySavedGoalsModel(
          wGDecode2[i]['id'],
          wGDecode2[i]['type'],
          wGDecode2[i]['goalDescription'],
          wGDecode2[i]['help_info'],
          wGDecode2[i]['user_id']);
      weeklySavedGoalsModelList..add(weeklySavedGoalsModel);
      print(wGDecode2[i]['type']);
      print(wGDecode2[i]['goalDescription']);
      print(wGDecode2[i]['help_info']);
    }
    print(wGDecode2.length);
  }

  addSavedGoals(int index) async {
    int i = 1;
    WeeklySavedGoalsModel m = new WeeklySavedGoalsModel(
        weeklySavedGoalsModelList.length+1,
        weeklyGoalsModelList[index].type,
        weeklyGoalsModelList[index].goalDescription,
        weeklyGoalsModelList[index].helpInfo,
        1);
    db2.saveWeeklySavedGoal(m);
  }
}
