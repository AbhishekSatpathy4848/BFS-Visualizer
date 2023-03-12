class GraphNodeClass {
  bool isVisited = false;
  bool isExplored = false;
  int value;

  GraphNodeClass({required this.value});

  markVisited() {
    isVisited = true;
  }

  markExplored() {
    isExplored = true;
  }
}
