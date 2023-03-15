class GraphNodeClass {
  bool isVisited;
  bool isExplored;
  int? value;

  GraphNodeClass({this.value,required this.isVisited,required this.isExplored});

  markVisited() {
    isVisited = true;
  }

  markExplored() {
    isExplored = true;
  }
}
