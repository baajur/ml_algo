import 'package:ml_algo/src/decision_tree_solver/decision_tree_node.dart';
import 'package:ml_algo/src/decision_tree_solver/splitter/nominal_splitter/nominal_splitter.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

class NominalDecisionTreeSplitterImpl implements NominalDecisionTreeSplitter {
  const NominalDecisionTreeSplitterImpl();

  @override
  Map<DecisionTreeNode, Matrix> split(Matrix samples, int splittingIdx,
      List<num> uniqueValues) =>
      Map.fromEntries(uniqueValues.map((value) {
        final splittingClause =
            (Vector sample) => sample[splittingIdx] == value;

        final foundRows = samples.rows.where(splittingClause)
            .toList(growable: false);

        final node = DecisionTreeNode(splittingClause, value,
            splittingIdx, null, null);

        return MapEntry(node, Matrix.fromRows(foundRows));
      }).where((entry) => entry.value.rowsNum > 0),
  );
}