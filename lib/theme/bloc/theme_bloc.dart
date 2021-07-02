import 'dart:async';
import 'package:bloc/bloc.dart';
import '../app_themes.dart';
import 'bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(
          ThemeState(
            themeData: AppThemes.appThemeData[AppTheme.Default]!,
          ),
        );

  @override
  Stream<ThemeState> mapEventToState(ThemeEvent event) async* {
    if (event is ThemeEvent) {
      yield ThemeState(
        themeData: AppThemes.appThemeData[event.appTheme]!,
      );
    }
  }

// @override
//   Stream<ThemeState> mapEventToState(
//     ThemeEvent event,
//   ) async* {
//     if (event is ThemeChanged) {
//       yield ThemeState(themeData: appThemeData[event.theme]);
//       // setCurrent(event.theme.toString());
//       // addThemeToSP(event.theme.toString());
//     }
//   }

  // @override
  // get initialState => ThemeState(themeData: appThemeData[setTheme()]);

  addThemeToSP(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('savedTheme', theme);
  }

  setTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString('savedTheme');
    if (stringValue != null) {
      return stringValue;
    } else {
      stringValue = "AppTheme.Default";
      return stringValue;
    }
  }
}
