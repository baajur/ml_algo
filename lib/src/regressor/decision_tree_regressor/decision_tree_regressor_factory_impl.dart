import 'package:ml_algo/src/regressor/decision_tree_regressor/decision_tree_regressor.dart';
import 'package:ml_algo/src/regressor/decision_tree_regressor/decision_tree_regressor_factory.dart';
import 'package:ml_algo/src/regressor/decision_tree_regressor/decision_tree_regressor_impl.dart';

class DecisionTreeRegressorFactoryImpl implements DecisionTreeRegressorFactory {
  const DecisionTreeRegressorFactoryImpl();

  @override
  DecisionTreeRegressor create() => DecisionTreeRegressorImpl();
}
