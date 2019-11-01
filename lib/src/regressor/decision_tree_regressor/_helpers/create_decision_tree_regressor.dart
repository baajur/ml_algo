import 'package:ml_algo/src/di/dependencies.dart';
import 'package:ml_algo/src/regressor/decision_tree_regressor/decision_tree_regressor.dart';
import 'package:ml_algo/src/regressor/decision_tree_regressor/decision_tree_regressor_factory.dart';

DecisionTreeRegressor createDecisionTreeRegressor() {
  final regressorFactory = dependencies
      .getDependency<DecisionTreeRegressorFactory>();

  return regressorFactory.create();
}
