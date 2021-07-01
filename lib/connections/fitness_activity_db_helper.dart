import 'dart:convert';

import 'package:cnc_flutter_app/connections/db_helper_base.dart';
import 'package:cnc_flutter_app/models/activity_model.dart';
import 'package:http/http.dart' as http;

class ActivityDBHelper extends DBHelperBase {
  //TODO get all activities method shouldn't exist in actual app.
  Future<http.Response> getAllActivities() async {
    var requestUrl = baseUrl + 'api/fitnessActivity/all';
    http.Response response = await http.get(Uri.parse(requestUrl), headers: {});
    return response;
  }

  Future<http.Response> getActivities(int userId) async {
    var requestUrl = baseUrl + 'api/fitnessActivity/all/user';
    var queryParameters = {
      'userId': userId.toString(),
    };
    var uri =
        Uri.https(baseUri, '/api/fitnessActivity/all/user', queryParameters);

    var response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    return response;
  }

  Future<http.Response> getActivityOptions() async {
    var requestUrl = baseUrl + 'api/activityOptions/all';
    http.Response response = await http.get(Uri.parse(requestUrl), headers: {});
    return response;
  }

  Future<http.Response> saveNewActivity(
      ActivityModel fitnessActivityModel) async {
    var requestUrl = baseUrl + 'api/fitnessActivity/add/';
    var uriResponse = await http.post(Uri.parse(requestUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'type': fitnessActivityModel.type,
          'intensity': fitnessActivityModel.intensity.toString(),
          'minutes': fitnessActivityModel.minutes.toString(),
          'dateTime': fitnessActivityModel.dateTime.toIso8601String(),
          'userId': fitnessActivityModel.userId.toString(),
        }));
  }

  Future<http.Response> updateExistingActivity(
      ActivityModel activityModel) async {
    var requestUrl = baseUrl + 'api/fitnessActivity/update/';
    var uriResponse = await http.put(Uri.parse(requestUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id': activityModel.id,
          'type': activityModel.type,
          'intensity': activityModel.intensity.toString(),
          'minutes': activityModel.minutes.toString(),
          'dateTime': activityModel.dateTime.toIso8601String(),
          'userId': activityModel.userId.toString(),
        }));
  }

  Future<http.Response> getDaysActivityList(
      int numberOfDays, int intensity, int userId) async {
    var requestUrl = baseUrl + 'api/fitnessActivity/week/user/';
    var queryParameters = {
      'numberOfDays': numberOfDays.toString(),
      'intensity': intensity.toString(),
      'userId': userId.toString(),
    };
    var uri =
        Uri.https(baseUri, '/api/fitnessActivity/week/user/', queryParameters);

    var response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );
    return response;
  }

  Future<http.Response> getDayActivityList(int userId) async {
    var requestUrl = baseUrl + 'api/fitnessActivity/day/user/';
    var queryParameters = {
      'userId': userId.toString(),
    };
    var uri =
        Uri.https(baseUri, '/api/fitnessActivity/day/user/', queryParameters);

    var response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );
    return response;
  }
}
