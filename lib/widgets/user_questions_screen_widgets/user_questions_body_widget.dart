import 'package:cnc_flutter_app/connections/database.dart' as DBHelper;
import 'package:cnc_flutter_app/connections/database.dart';
import 'package:cnc_flutter_app/models/user_question_model.dart';
import 'package:flutter/material.dart';
import 'user_questions_list_tile_widget.dart';

class UserQuestionsBody extends StatefulWidget {
  final List<UserQuestion> userQuestions = [];

  @override
  _UserQuestionsBodyState createState() => _UserQuestionsBodyState();
}

class _UserQuestionsBodyState extends State<UserQuestionsBody> {
  DBProvider dbp = DBHelper.DBProvider.instance;
  String dropDownSort = 'Old to New';
  List<UserQuestion> currentQuestions = [];
  List<String> _sorts = ['New to Old', 'Old to New'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: ScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Column(children: [
          Container(
              padding: EdgeInsets.only(left: 5, right: 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Sort by '),
                    _buildSort(),
                  ])),
          FutureBuilder(
            builder: (context, projectSnap) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.userQuestions.length,
                itemBuilder: (context, index) {
                  return UserQuestionsListTile(widget.userQuestions[index]);
                },
              );
            },
            future: getQuestions(),
          ),
        ]));
  }

  Widget _buildSort() {
    return Container(
        width: 10.0,
        child: DropdownButtonHideUnderline(
            child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonFormField(
                  isExpanded: true,
                  decoration: InputDecoration(
                    // labelText: 'Sort by',
                    border: OutlineInputBorder(),
                    // hintText: "Sort by",
                  ),
                  value: dropDownSort,
                  validator: (value) => value == null ? 'Field Required' : null,
                  onChanged: (String? value) {
                    setState(() {
                      if (value != null) {
                        dropDownSort = value;
                      }
                      sortContent();

                      // _heightInches = _inches.indexOf(Value) + 1;
                    });
                  },
                  items: _sorts
                      .map((sort) =>
                          DropdownMenuItem(value: sort, child: Text("$sort")))
                      .toList(),
                ))));
  }

  sortContent() {
    //currentQuestions = widget.userQuestions;
    if (dropDownSort == "New to Old") {
      widget.userQuestions.sort((a, b) {
        var adate = a.dateCreated;
        var bdate = b.dateCreated;
        return -adate.compareTo(bdate);
      });
    }
  }

  // List<ActivityTrackingListTile> buildFitnessTrackingListTileWidgets(
  //     List<ActivityModel> fitnessActivityModelList) {
  //   List<ActivityTrackingListTile> fitnessTrackingListTileList = [];
  //   for (ActivityModel fitnessActivity in widget.activityModelList) {
  //     ActivityTrackingListTile fitnessTrackingListTile =
  //     new ActivityTrackingListTile(fitnessActivity);
  //     fitnessTrackingListTileList.add(fitnessTrackingListTile);
  //   }
  //   return fitnessTrackingListTileList;
  // }

  getQuestions() async {
    widget.userQuestions.clear();
    var userQuestionsFromDB = await dbp.getAllUserQuestions(1);
    if (userQuestionsFromDB != null) {
      for (int i = 0; i < userQuestionsFromDB.length; i++) {
        UserQuestion userQuestion =
            UserQuestion.fromMap(userQuestionsFromDB[i]);
        /*(
          id: userQuestionsFromDB[i]['id'],
          question: userQuestionsFromDB[i]['question'],
          questionNotes: userQuestionsFromDB[i]['question_notes'],
          dateCreated: userQuestionsFromDB[i]['date_created'],
          dateUpdated: userQuestionsFromDB[i]['date_updated'], isAnswered: null, userId: 1,
        );*/
        widget.userQuestions.add(userQuestion);
      }
    }
  }

  void refresh() {
    setState(() {});
  }
}
