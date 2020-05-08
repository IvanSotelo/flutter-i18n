import 'package:flutter/material.dart';

// import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:i18n_translate/i18n.dart';
import 'package:i18n_translate/AppLanguage.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [
          I18n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        home: TestWidgetPage());
  }
}

class TestWidgetPage extends StatefulWidget {
  @override
  createState() => TestWidgetPageState();
}

class TestWidgetPageState extends State<TestWidgetPage> {
  AppLanguage appLanguage = AppLanguage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Test"),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              children: <Widget>[
                Text(I18n.translate(context, "keySingle")),
                RaisedButton(
                  onPressed: () async {
                    appLanguage.changeLanguage(Locale("en"));
                  },
                ),
              ],
            ),
          );
        }));
  }
}