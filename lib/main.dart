// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X/O game',
      theme: ThemeData(
        // Add the 3 lines from here...
        primaryColor: Colors.white,
      ), // ... to here.
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  var array = new List(9);
  var arrayPlaceHolder = new List(10);
  bool easyMode = false;
  Color _color = Colors.amber[600];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('X/O game'),
/*        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {},
          ),
        ],*/
      ),
      body: _newScreen(),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
          DrawerHeader(
          child: Text('Options',style: TextStyle(fontSize: 20),),
          decoration: BoxDecoration(
            color: _color,
          ),
        ),
        ListTile(
          title: Text('Reset'),
          onTap: () {
            // Update the state of the app
            setState(() {
              resetGame();
            });
            // Then close the drawer
            Navigator.pop(context);
          },
        ),
        ListTile(
            title: Text('Change Colour'),
            onTap: () {
              // Update the state of the app
              setState(() {
                _color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
              });
              // Then close the drawer
              Navigator.pop(context);
            },
        ),
          ListTile(
            title: Text(!useAi ? "Play With Computer":'Play With a Friend'),
            onTap: () {
              // Update the state of the app
              setState(() {
                useAi = !useAi;
                resetGame();
              });
              // Then close the drawer
              Navigator.pop(context);
            },
          ),

          CheckboxListTile(
            title: Text('Easy Mode'),
            onChanged: (bool value) { setState(() {
              value? easyMode = true: easyMode = false;
            });  }, value: easyMode,
            selected: easyMode,
          )
              ],
          ),
        ),
    );
  }

  bool detectWinner(String testWinner) {
    if (arrayPlaceHolder[3] == testWinner && arrayPlaceHolder[5] == testWinner && arrayPlaceHolder[7] == testWinner) {
      return true;
    }
    if (arrayPlaceHolder[1] == testWinner && arrayPlaceHolder[5] == testWinner && arrayPlaceHolder[9] == testWinner) {
      return true;
    }
    if (arrayPlaceHolder[1] == testWinner && arrayPlaceHolder[4] == testWinner && arrayPlaceHolder[7] == testWinner) {
      return true;
    }
    if (arrayPlaceHolder[2] == testWinner && arrayPlaceHolder[5] == testWinner && arrayPlaceHolder[8] == testWinner) {
      return true;
    }
    if (arrayPlaceHolder[3] == testWinner && arrayPlaceHolder[6] == testWinner && arrayPlaceHolder[9] == testWinner) {
      return true;
    }
    if (arrayPlaceHolder[1] == testWinner && arrayPlaceHolder[2] == testWinner && arrayPlaceHolder[3] == testWinner) {
      return true;
    }
    if (arrayPlaceHolder[4] == testWinner && arrayPlaceHolder[5] == testWinner && arrayPlaceHolder[6] == testWinner) {
      return true;
    }
    if (arrayPlaceHolder[7] == testWinner && arrayPlaceHolder[8] == testWinner && arrayPlaceHolder[9] == testWinner) {
      return true;
    }
    return false;
  }

  bool detectDraw() {
    if (detectWinner("X") || detectWinner("O")) {
      return false;
    }
    var test = true;
    for (int i = 1; i < arrayPlaceHolder.length; i++) {
      if (arrayPlaceHolder[i] == null) {
        test = false;
      }
    }
    return test;
  }

  void showDialoge(String name){
    showDialog(
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("The game is DONE!"),
          content: Text(name == null ? "Game is a draw" : "The winner is $name"),
          actions: <Widget>[
            FlatButton(onPressed: () {setState(() {
              Navigator.of(context).pop();
              resetGame();
            });}, child: Text("Reset"))
          ],
        );
      }, context: this.context,
    );
  }

  void resetGame() {
    array = new List(9);
    arrayPlaceHolder = new List(10);
    word = "X";
  }

  void Ai() {
    var possible = new List();
    if (!detectWinner("X")) {
      for (int i = 1; i < arrayPlaceHolder.length; i++) {
        if (arrayPlaceHolder[i] == null) {
          //arrayPlaceHolder[i] = "O";
          possible.add(i - 1);
        }
      }
      print(easyMode);
        if (possible.isNotEmpty && easyMode) {
          math.Random random = new math.Random();
          updateGame(possible[random.nextInt(possible.length)]);
        } else if (possible.isNotEmpty && !easyMode) {
          int idealPosition = -1;
          print(possible.length);
          for(int i = 0; i < possible.length; i++) {
            int element = possible[i]+1;
            arrayPlaceHolder[element] = "O";
            if (detectWinner("O")) {
              idealPosition = element;
              arrayPlaceHolder[element] = null;
              break;
            }
            arrayPlaceHolder[element] = "X";
            if (detectWinner("X")) {
              idealPosition = element;
              arrayPlaceHolder[element] = null;
              break;
            }
            arrayPlaceHolder[element] = null;
          }
          if (idealPosition == -1) {
            math.Random random = new math.Random();
            updateGame(possible[random.nextInt(possible.length)]);
          } else {
            updateGame(idealPosition-1);
          }
        }
    }
  }

  var tapped = "";
  var word = "X";
  bool useAi = true;

  Widget _newScreen() {
    for (int i = 0; i < array.length; i++) {
      array[i] = GestureDetector(
        onTap: () {
          updateGame(i);
        },
        child: AnimatedContainer(
          margin: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          color: _color,
          width: 90.0,
          child: AnimatedDefaultTextStyle(
            style: arrayPlaceHolder[i+1] != null?

            arrayPlaceHolder[i+1] == "X"? TextStyle(fontSize: 80): TextStyle(fontSize: 80, color: Colors.black) : TextStyle(fontSize: 80, color: Colors.deepPurple),



            duration: Duration(seconds: 2),
            child: Text(arrayPlaceHolder[i + 1] != null
                ? arrayPlaceHolder[i + 1]
                : ""),
          ),
          height: 90.0, duration: Duration(seconds: 2),
        ),
      );
    }

    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: 3,
      crossAxisSpacing: 2,

      children: List.generate(9, (index) {
        return Center(
          child: array[index],
        );
      }),
    );
  }

  void updateGame(int i) {
    print((i + 1).toString());
    tapped = (i + 1).toString();
    setState(() {
      if (arrayPlaceHolder[i+1] == null) {
        arrayPlaceHolder[i + 1] = word; // move this down and remove AI for non-AI
        if (word == "O") {
          word = "X";
        } else if (word == "X") {
          word = "O";
        }
        // HERE MOVE IT HERE
      }

      if (detectDraw()) {
        showDialoge(null);
      }
      if (detectWinner("X")) {
        showDialoge("X");
      }
      if (detectWinner("O")) {
        showDialoge("O");
      }
      _color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

      if (word == "O" && useAi) {
        Ai();
      }

    });
  }
}
