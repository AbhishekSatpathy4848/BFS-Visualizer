import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'graph_cubit_state.dart';

class GraphCubitCubit extends Cubit<GraphCubitState> {
  GraphCubitCubit() : super(GraphCubitInitial());
  
}
