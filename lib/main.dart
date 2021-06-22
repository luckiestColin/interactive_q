// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:interactive_q/models/quizFlow.dart';
import 'package:interactive_q/models/section.dart';
import 'package:interactive_q/models/flowItem.dart';
import 'package:interactive_q/models/answer.dart';
import 'package:interactive_q/models/profile.dart';
import 'package:interactive_q/models/profileColor.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blee',
      theme: ThemeData(
        primaryColor: Colors.white,
        fontFamily: 'Hatton',
      ),
      home: Favorites(),
    );
  }
}

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  static const String _background = 'assets/images/grid.jpeg';
  static const String _splash = 'assets/images/grid.jpeg';
  static const int _retryLimit = 10;
  static const int _affirmationPause = 3;
  static const int _errorPause = 10;
  static const int _splashPause = 10;

  final _header1Font = TextStyle(
      fontSize: 40.0,
      fontWeight: FontWeight.bold
  );
  final _questionFont = TextStyle(fontSize: 40.0);

  QuizFlow? _quizFlow;
  int _sectionIndex = 0;
  int _sectionQuestionIndex = 0;
  int _flowItemCount = -1;
  int _overallIndex = 0;
  int _retryCount = 0;
  
  int _currentStep = 0;

  Future<QuizFlow> _getFlow() async {
    if (_quizFlow != null) {
      return Future<QuizFlow>(() => _quizFlow!);
    }
    Future<String> getJson() {
      return rootBundle.loadString('assets/json/flow.json');
    }
    Map<String, dynamic> userMap = jsonDecode(await getJson());
    return QuizFlow.fromJson(userMap);
  }

  Future<Profile> _getResult() async {
    Future<String> getJson() {
      return rootBundle.loadString('assets/json/colors.json');
    }
    Map<String, dynamic> profileData = jsonDecode(await getJson());
    return Profile.fromJson(profileData);
  }

  @override
  void initState() {
    super.initState();
    _splashTimer();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
                appBar: AppBar(
                  title: Text('Thanks for choosing Blee!'),
                ),
                body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_splash),
                          fit: BoxFit.cover,
                        )
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0)
                ),

              );

  List<Step> _buildFlowSteps(List<Section> sections){
    List<Step> steps = new List<Step>.empty(growable: true);
    int stepIndex = 0;
    for(var section in sections)
      {
        for(var flowItem in section.flowItems) {
          steps.add(Step
            (
            title: Text(section.header),
            subtitle: Text(flowItem.heading),
            isActive: true,
            state: StepState.editing,
            content: flowItem.answers == null ? _buildAffermation() : _buildAnswers(flowItem.answers!, flowItem),
          ));
        }
      }
    return steps;
  }

  Widget _buildAffermation(){
    _affirmationTimer();
    return Text("");
  }

  Widget _buildAnswers(List<Answer> answers, FlowItem flowItem) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: answers.map<Widget>((answer) => FractionallySizedBox(
    widthFactor: 0.85,
    child: Container(
      color: Colors.white,
      child: RadioListTile<int>(
          title: Text(
              answer.text,
              style: TextStyle(fontSize: 30.0)
          ),
          value: answer.value,
          groupValue: flowItem.lastAnswer,
          onChanged: (int? newValue) {
            setState(() {
              flowItem.lastAnswer = newValue;
              _moveOn();
            });
          }
      ),
    ),
    )
        ).toList()
  );

  _splashTimer() async {
    var duration = new Duration(seconds: _splashPause);
    return new Timer(duration, _start);
  }

  _affirmationTimer() async {
    var duration = new Duration(seconds: _affirmationPause);
    return new Timer(duration, _moveOn);
  }

  _errorExitTimer() async {
    var duration = new Duration(seconds: _errorPause);
    return new Timer(duration, exit(1));
  }

  _start() {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => _renderFlowSteps(context))
    );
  }

  Widget _renderFlowSteps(BuildContext context) =>
      FutureBuilder<QuizFlow>(
          future: _getFlow(),
          builder: (context, snapshot) {
            if (snapshot.hasError){

              _errorExitTimer();
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'We were unable to load your quiz, please try again later.'),
                ),
                body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_splash),
                          fit: BoxFit.cover,
                        )
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0)
                ),
              );
            }
            if (snapshot.hasData) {

              if (_flowItemCount < 0) {
                snapshot.data!.sections.forEach((section) =>
                _flowItemCount += section.flowItems.length);
              }

              if (_sectionQuestionIndex >
                  snapshot.data!.sections[_sectionIndex].flowItems.length -
                      1) {
                _sectionIndex++;
                _sectionQuestionIndex = 0;
              }
              if (_sectionIndex > snapshot.data!.sections.length - 1) {
                _showResults();
              }
              return Scaffold(
                  appBar: AppBar(
                    title: Text("Blee"),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_background),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Stepper(
                        type: StepperType.horizontal,
                        physics: PageScrollPhysics(),
                        currentStep: _currentStep,
                        onStepTapped: (step) => _tapped(step),
                        onStepContinue: _continued,
                        onStepCancel: _cancel,
                        steps: _buildFlowSteps(snapshot.data!.sections),
                      )
                  )
              );
            } else {
              if (_retryCount < _retryLimit) {
                //_affirmationTimer();
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                        'Blee'),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_splash),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                        'We are having some trouble loading your quiz, trying again.'),
                  ),
                );
              } else {
                _errorExitTimer();
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                        'Blee'),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_splash),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                          'We were unable to load your quiz, please try again later.'),
                  ),
                );
              }
            }
          }
      );

  Widget _renderResults(BuildContext context) =>
      FutureBuilder<Profile>(
          future: _getResult(),
          builder: (context, snapshot) {
            if (snapshot.hasError){

              _errorExitTimer();
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'Blee.'),
                ),
                body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_splash),
                          fit: BoxFit.cover,
                        )
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: (Text('We were unable to load your results, please try again later.')),
                ),
              );
            }
            if (snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: Text("Personal color profile"),
                  backgroundColor: Color(0xFF444444),
                ),
                body: Column(
                    children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: .5,
                        child: Container (
                          width: 400,
                          height: 400,
                          child: CustomPaint(
                            painter: OpenPainter(color: Color(snapshot.data!.profileColors.where((element) => element.ordinal == 0).first.argbValue)),
                          ),
                        ),
                      ),
                      Text(snapshot.data!.profileColors[0].name,
                          style: _questionFont
                      ),
                      Text("#'${snapshot.data!.profileColors[0].argbValue.toRadixString(16).substring(2)}'",
                          style: _questionFont
                      )
                    ]),
              );
            } else {
              if (_retryCount < _retryLimit) {
                //_affirmationTimer();
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                        'Blee'),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_splash),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                        'We are having some trouble loading your results, trying again.'),
                  ),
                );
              } else {
                _errorExitTimer();
                return Scaffold(
                  appBar: AppBar(
                    title: Text('Blee'),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_splash),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                        'We were unable to load your results, please try again later.'),
                  ),
                );
              }
            }
          }
      );

  _tapped(int step){
    setState(() => _currentStep = step);
  }

  _continued(){
    _currentStep < 2 ?
    setState(() => _currentStep += 1): null;
  }
  _cancel(){
    _currentStep > 0 ?
    setState(() => _currentStep -= 1) : null;
  }

  void _moveOn() =>
      _tapped(++_currentStep);


  void _showResults() =>
      Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: _renderResults
          )
      );

}

class OpenPainter extends CustomPainter {
  OpenPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    //a circle
    canvas.drawCircle(Offset(100, 100), 50, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


/*
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:interactive_q/models/quizFlow.dart';
import 'package:interactive_q/models/section.dart';
import 'package:interactive_q/models/flowItem.dart';
import 'package:interactive_q/models/answer.dart';
import 'package:interactive_q/models/profile.dart';
import 'package:interactive_q/models/profileColor.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blee',
      theme: ThemeData(
        primaryColor: Colors.white,
        fontFamily: 'Hatton',
      ),
      home: Favorites(),
    );
  }
}

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  static const String _background = 'assets/images/grid.jpeg';
  static const String _splash = 'assets/images/grid.jpeg';
  static const int _retryLimit = 10;
  static const int _affirmationPause = 3;
  static const int _errorPause = 10;

  final _header1Font = TextStyle(
      fontSize: 40.0,
      fontWeight: FontWeight.bold
  );
  final _questionFont = TextStyle(fontSize: 40.0);

  QuizFlow? _quizFlow;
  int _sectionIndex = 0;
  int _sectionQuestionIndex = 0;
  int _flowItemCount = -1;
  int _overallIndex = 0;
  int _retryCount = 0;

  Future<QuizFlow> _getFlow() async {
    if (_quizFlow != null) {
      return Future<QuizFlow>(() => _quizFlow!);
    }
    Future<String> getJson() {
      return rootBundle.loadString('assets/json/flow.json');
    }
    Map<String, dynamic> userMap = jsonDecode(await getJson());
    return QuizFlow.fromJson(userMap);
  }

  Future<Profile> _getResult() async {
    Future<String> getJson() {
      return rootBundle.loadString('assets/json/colors.json');
    }
    Map<String, dynamic> profileData = jsonDecode(await getJson());
    return Profile.fromJson(profileData);
  }

  @override
  void initState() {
    super.initState();
    _affirmationTimer();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
                appBar: AppBar(
                  title: Text('Thanks for choosing Blee!'),
                ),
                body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_splash),
                          fit: BoxFit.cover,
                        )
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0)
                ),

              );


  Widget _buildFlowItem(FlowItem flowItem, String heading, int currentIndex,
      int totalCount) {
    List<Widget> flowChildren = new List<Widget>.empty(growable: true);
    flowChildren.add(
            FractionallySizedBox(
                widthFactor: 0.99,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    FractionallySizedBox(
                      widthFactor: 0.90,
                      child: Container(
                        color: Colors.white,
                        child: Text(
                          flowItem.heading,
                          style: _questionFont,),
                      ),),

                    SizedBox(height: 20,)
                  ],
                )
            )
    );

    if (flowItem.answers != null) {
      for(var answer in flowItem.answers!) {
        flowChildren.add(
          FractionallySizedBox(
            widthFactor: 0.85,
            child: Container(
              color: Colors.white,
              child: RadioListTile<int>(
                  title: Text(
                      answer.text,
                      style: TextStyle(fontSize: 30.0)
                  ),
                  value: answer.value,
                  groupValue: flowItem.lastAnswer,
                  onChanged: (int? newColor) {
                    setState(() {
                      flowItem.lastAnswer = newColor;
                      _moveOn();
                    });
                  }
              ),
            ),
          ),
        );
        flowChildren.add(SizedBox(height: 10,));
      }
    }else{
      _affirmationTimer();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(heading),
        ),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_background),
                  fit: BoxFit.cover,
                )
            ),
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child:
            FractionallySizedBox(
                widthFactor: 0.99,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: flowChildren
                )
            )
        )
    );
  }

  _affirmationTimer() async {
    var duration = new Duration(seconds: _affirmationPause);
    return new Timer(duration, _moveOn);
  }

  _errorExitTimer() async {
    var duration = new Duration(seconds: _errorPause);
    return new Timer(duration, exit(1));
  }

  Widget _renderFlowStep(BuildContext context) =>
      FutureBuilder<QuizFlow>(
          future: _getFlow(),
          builder: (context, snapshot) {
            if (snapshot.hasError){

              _errorExitTimer();
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'We were unable to load your quiz, please try again later.'),
                ),
                body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_splash),
                          fit: BoxFit.cover,
                        )
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0)
                ),
              );
            }
            if (snapshot.hasData) {

              if (_flowItemCount < 0) {
                snapshot.data!.sections.forEach((section) =>
                _flowItemCount += section.flowItems.length);
              }

              if (_sectionQuestionIndex >
                  snapshot.data!.sections[_sectionIndex].flowItems.length -
                      1) {
                _sectionIndex++;
                _sectionQuestionIndex = 0;
              }
              if (_sectionIndex > snapshot.data!.sections.length - 1) {
                _showResults();
              }
              return _buildFlowItem(snapshot.data!.sections[_sectionIndex]
                  .flowItems[_sectionQuestionIndex++],
                  snapshot.data!.sections[_sectionIndex].header, _overallIndex,
                  _flowItemCount);
            } else {
              if (_retryCount < _retryLimit) {
                //_affirmationTimer();
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                        'Blee'),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_splash),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                        'We are having some trouble loading your quiz, trying again.'),
                  ),
                );
              } else {
                _errorExitTimer();
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                        'Blee'),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_splash),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                          'We were unable to load your quiz, please try again later.'),
                  ),
                );
              }
            }
          }
      );

  Widget _renderResults(BuildContext context) =>
      FutureBuilder<Profile>(
          future: _getResult(),
          builder: (context, snapshot) {
            if (snapshot.hasError){

              _errorExitTimer();
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'Blee.'),
                ),
                body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_splash),
                          fit: BoxFit.cover,
                        )
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: (Text('We were unable to load your results, please try again later.')),
                ),
              );
            }
            if (snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: Text("Personal color profile"),
                  backgroundColor: Color(0xFF444444),
                ),
                body: Column(
                    children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: .5,
                        child: Container (
                          width: 400,
                          height: 400,
                          child: CustomPaint(
                            painter: OpenPainter(color: Color(snapshot.data!.profileColors.where((element) => element.ordinal == 0).first.argbValue)),
                          ),
                        ),
                      ),
                      Text(snapshot.data!.profileColors[0].name,
                          style: _questionFont
                      ),
                      Text("#'${snapshot.data!.profileColors[0].argbValue.toRadixString(16).substring(2)}'",
                          style: _questionFont
                      )
                    ]),
              );
            } else {
              if (_retryCount < _retryLimit) {
                //_affirmationTimer();
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                        'Blee'),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_splash),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                        'We are having some trouble loading your results, trying again.'),
                  ),
                );
              } else {
                _errorExitTimer();
                return Scaffold(
                  appBar: AppBar(
                    title: Text('Blee'),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_splash),
                            fit: BoxFit.cover,
                          )
                      ),
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                        'We were unable to load your results, please try again later.'),
                  ),
                );
              }
            }
          }
      );


  void _moveOn() =>
      Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: _renderFlowStep
          )
      );


  void _showResults() =>
      Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: _renderResults
          )
      );

}

class OpenPainter extends CustomPainter {
  OpenPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    //a circle
    canvas.drawCircle(Offset(100, 100), 50, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

 */