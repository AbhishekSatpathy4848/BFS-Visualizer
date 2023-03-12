import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'dart:core';
import 'package:motion_toast/motion_toast.dart';

import 'package:bfs_visualiser/Graph_Node_widget.dart';
import 'package:bfs_visualiser/graph_node_class.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int totalNodes = 50;
  List<GraphNodeClass> graph = [];
  List<Point> coordinates = [];
  Map<int, List<GraphNodeClass>> adjList = {};
  int currentNode = 0;
  GraphNodeClass? lastDoubleTapGraph;
  bool startVisualisation = false;
  TextEditingController? startNodeTextController;
  final formKey = GlobalKey<FormState>();
  ValueNotifier<String> disconnectedGraphNotifier = ValueNotifier("");

  initCoordinates() {
    int count = 0;
    while (count != totalNodes) {
      int x = Random().nextInt(window.physicalSize.width ~/ 2.2);
      int y = Random().nextInt(window.physicalSize.height ~/ 2.5);
      // print("${window.physicalSize.width.toInt()} ${window.physicalSize.height.toInt()}");
      // for (Point coordinate in coordinates) {
      //   if ((coordinate.distanceTo(Point(x, y))).abs() < 50) {
      //     coordinates.add(Point(x, y));
      //     count++;
      //   }
      // }
      if (!coordinates.contains(Point(x, y))) {
        // print("$x $y");
        coordinates.add(Point(x, y));
        count++;
      }
    }
  }

  @override
  void initState() {
    startNodeTextController = TextEditingController();
    initCoordinates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          floatingActionButton: Row(
            children: [
              Builder(builder: (context) {
                return Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: FloatingActionButton.extended(
                    label: const Text("Start Visualisation"),
                    hoverColor: Colors.green,
                    onPressed: () {
                      showModalBottomSheet(
                              clipBehavior: Clip.hardEdge,
                              isDismissible: true,
                              context: context,
                              builder: ((context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Enter the starting node",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Form(
                                        key: formKey,
                                        autovalidateMode:
                                            AutovalidateMode.always,
                                        child: TextFormField(
                                          controller: startNodeTextController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Enter a value";
                                            }
                                            if (!RegExp(r'^[0-9]+$')
                                                .hasMatch(value)) {
                                              return "Please enter a number";
                                            }
                                            if (currentNode == 0) {
                                              return "Please add some Nodes to the canvas";
                                            }
                                            if (int.parse(value) >=
                                                currentNode) {
                                              return "Entered value should lie between 0 and ${currentNode - 1}";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              Navigator.of(context).pop();
                                              startVisualisation = true;
                                              bfs(int.parse(
                                                  startNodeTextController!
                                                      .text));
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Center(
                                                child: Text(
                                              "Start",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15),
                                            )),
                                          ))
                                    ],
                                  ),
                                );
                              }))
                          .whenComplete(() => startNodeTextController!.clear());
                    },
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ValueListenableBuilder(
                    valueListenable: disconnectedGraphNotifier,
                    builder: ((context, value, child) {
                      return Text(value,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16));
                    })),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      graph = [];
                      adjList = {};
                      currentNode = 0;
                      lastDoubleTapGraph = null;
                      startVisualisation = false;
                      disconnectedGraphNotifier.value = "";
                      initCoordinates();
                    });
                  },
                  label: const Text("Reset"),
                ),
              ),
              !startVisualisation
                  ? FloatingActionButton(
                      child: const Icon(Icons.add),
                      onPressed: () {
                        if (currentNode >= totalNodes) {
                          disconnectedGraphNotifier.value =
                              "Only a maximum of $totalNodes node(s) can be spawned!!";
                          return;
                        }
                        setState(() {
                          graph.add(GraphNodeClass(value: currentNode));
                          currentNode++;
                        });
                      },
                    )
                  : SizedBox(
                      height: 0,
                      width: 0,
                      child: FloatingActionButton(onPressed: () {})),
            ],
          ),
          appBar: AppBar(
            title: const Text('BFS Visualiser'),
          ),
          body: Builder(builder: (context) {
            return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: CustomPaint(
                  painter:
                      LinePainter(adjList: adjList, coordinates: coordinates),
                  child: Stack(
                      children: graph
                          .map((e) => Positioned(
                                top: coordinates[e.value].y.toDouble(),
                                left: coordinates[e.value].x.toDouble(),
                                child: GestureDetector(
                                    onTap: () {
                                      if (!startVisualisation){
                                      if (lastDoubleTapGraph == null) {
                                        lastDoubleTapGraph = e;
                                        // print("tapped");
                                      } else {
                                        if (e.value != lastDoubleTapGraph!.value) {
                                          setState(() {
                                            if (adjList.containsKey(
                                                lastDoubleTapGraph!.value)) {
                                              adjList[lastDoubleTapGraph!
                                                      .value]!
                                                  .add(e);
                                            } else {
                                              adjList[lastDoubleTapGraph!
                                                  .value] = [e];
                                            }
                                            if (adjList.containsKey(e.value)) {
                                              {
                                                adjList[e.value]!
                                                    .add(lastDoubleTapGraph!);
                                              }
                                            } else {
                                              adjList[e.value] = [
                                                lastDoubleTapGraph!
                                              ];
                                            }
                                            lastDoubleTapGraph = null;
                                            // print("Tapped 2");
                                            // print("$adjList");
                                          });
                                        }
                                      }
                                    }
                                    },
                                    child: GraphNode(graph: e)),
                              ))
                          .toList()),
                ));
          })),
    );
  }

  //BFS Algorithm
  
  // ignore: non_constant_identifier_names
  Future<void> bfs_connected(Queue<int> q) async {
    while (q.isNotEmpty) {
      int front = q.removeFirst();
      // print("${adjList[front]}");
      if (adjList.containsKey(front)) {
        for (GraphNodeClass visitingNode in adjList[front]!) {
          if (!graph[visitingNode.value].isVisited) {
            setState(() {
              graph[visitingNode.value].markVisited();
            });
            q.add(visitingNode.value);
            await Future.delayed(const Duration(seconds: 1));
            // print("${visitingNode.value} visited \n");
          }
        }
      }
      setState(() {
        graph[front].markExplored();
      });
      await Future.delayed(const Duration(seconds: 1));
      // print("${front} explored \n");
    }
  }

  Future<void> bfs(int start) async {
    Queue<int> q = Queue();

    setState(() {
      graph[graph.indexWhere((element) => element.value == start)]
          .markVisited();
    });

    await Future.delayed(const Duration(seconds: 1));

    q.add(start);
    await bfs_connected(q);

    for (var element in graph) {
      if (element.isExplored == false) {
        disconnectedGraphNotifier.value =
            "Disconnected graph has been detected!! Starting BFS on it from position ${element.value}";
        await Future.delayed(const Duration(seconds: 2));
        await bfs(element.value);
      }
    }
  }
}

class LinePainter extends CustomPainter {
  final Map<int, List<GraphNodeClass>> adjList;
  final List<Point> coordinates;
  LinePainter({required this.adjList, required this.coordinates});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    adjList.forEach((e_1, e_2) {
      for (var element in e_2) {
        canvas.drawLine(
            Offset(coordinates[e_1].x.toDouble() + 20,
                coordinates[e_1].y.toDouble() + 20),
            Offset(coordinates[element.value].x.toDouble() + 20,
                coordinates[element.value].y.toDouble() + 20),
            paint);
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
