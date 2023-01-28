// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertwo/blank_pixel.dart';
import 'package:fluttertwo/food_pixel.dart';
import 'package:fluttertwo/highscore_tile.dart';
import 'package:fluttertwo/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ignore: camel_case_types
enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // defining grid dimensions

  int rowSize = 10;
  int totalNumberofSquares = 100;

  //game settings
  bool gameHasStarted = false;
  final _nameController = TextEditingController();

  //user score
  int currentScore = 0;

  //snake position

  List<int> snakePos = [0, 1, 2];

  //snake direction
  var currentDirection = snake_Direction.RIGHT;

  // food
  int foodPos = 55;

  //highscore
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }
  

  Future getDocId() async {
    var database = await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("scores", descending: true)
        .limit(10);
    database.get().then(
          (value) => value.docs.forEach(
            (element) {
              highscore_DocIds.add(element.reference.id);
            },
          ),
        );
  }

  //startGame
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep snake moving
        moveSnake();

        //check if game over or not
        if (gameOver()) {
          timer.cancel();

          // display msg to user

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Game Over!!'),
                content: Column(
                  children: [
                    Text('Your Scores is: $currentScore'),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Enter Name'),
                    ),
                  ],
                ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      submitScore();
                      newGame();
                    },
                    color: Colors.pinkAccent,
                    child: const Text('Submit'),
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  void submitScore() {
    //get access to collection
    var database = FirebaseFirestore.instance;

    //add data to firebase
    database.collection('highscores').add({
      "name ": _nameController.text,
      "scores ": currentScore,
    });
  }

  Future newGame() async {
    // highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [0, 1, 2];
    });
    foodPos = 55;
    currentDirection = snake_Direction.RIGHT;
    gameHasStarted = false;
    currentScore = 0;
  }

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberofSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          // if snake at right wall need to re adjust

          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case snake_Direction.LEFT:
        {
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snake_Direction.UP:
        {
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberofSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snake_Direction.DOWN:
        {
          if (snakePos.last + rowSize > totalNumberofSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberofSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }
    //snake is eating food
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      // remove tail
      snakePos.removeAt(0);
    }
  }

  //game over
  bool gameOver() {
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    //screen resolution
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 400 ? 400 : screenWidth,
        child: Column(children: [
          //high score
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //user current score
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Current Score',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Text(
                        currentScore.toString(),
                        style:
                            const TextStyle(fontSize: 36, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                //high score

                Expanded(
                  child: gameHasStarted
                      ? Container()
                      : FutureBuilder(
                          future: letsGetDocIds,
                          builder: (context, snapshot) {
                            return ListView.builder(
                              itemCount: highscore_DocIds.length,
                              itemBuilder: (context, index) {
                                return HighScoreTile(
                                    documentid: highscore_DocIds[index]);
                              },
                            );
                          },
                        ),
                )
              ],
            ),
          ),

          //grid view
          Expanded(
            flex: 3,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 &&
                    currentDirection != snake_Direction.UP) {
                  currentDirection = snake_Direction.DOWN;
                } else if (details.delta.dy < 0 &&
                    currentDirection != snake_Direction.DOWN) {
                  currentDirection = snake_Direction.UP;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 &&
                    currentDirection != snake_Direction.LEFT) {
                  currentDirection = snake_Direction.RIGHT;
                } else if (details.delta.dx < 0 &&
                    currentDirection != snake_Direction.RIGHT) {
                  currentDirection = snake_Direction.LEFT;
                }
              },
              child: GridView.builder(
                  itemCount: totalNumberofSquares,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize),
                  itemBuilder: ((context, index) {
                    if (snakePos.contains(index)) {
                      return const SnakePixel();
                    } else if (foodPos == index) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  })),
            ),
          ),

          //high scores
          Expanded(
            child: Center(
              child: MaterialButton(
                color: gameHasStarted ? Colors.grey : Colors.pink,
                onPressed: gameHasStarted ? () {} : startGame,
                child: const Text('PLAY !'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
