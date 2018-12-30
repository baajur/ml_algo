import 'dart:async';

import 'package:ml_algo/ml_algo.dart';

Future<double> lassoRegression() async {
  final data = Float32x4CsvMLData.fromFile('datasets/advertising.csv', 4);
  final features = await data.features;
  final labels = await data.labels;
  final lassoRegressionModel = LassoRegressor(iterationLimit: 100, lambda: 6750.0);
  final validator = Float32x4CrossValidator.kFold();

  return validator.evaluate(lassoRegressionModel, features, labels, MetricType.mape);
}
