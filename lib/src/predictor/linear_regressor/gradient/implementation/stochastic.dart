import 'package:dart_ml/src/di/injector.dart';
import 'package:dart_ml/src/estimator/estimator_type.dart';
import 'package:dart_ml/src/optimizer/gradient/interface/stochastic.dart';
import 'package:dart_ml/src/optimizer/regularization/regularization.dart';

import 'base.dart';

class SGDRegressor extends GradientLinearRegressor {
  SGDRegressor({double learningRate = 1e-5,
                 double minWeightsDistance = 1e-8,
                 int iterationLimit = 10000,
                 EstimatorType estimatorType = EstimatorType.RMSE,
                 Regularization regularization = Regularization.L2,
                 alpha = .00001})
      : super(
      (injector.get(SGDOptimizer) as SGDOptimizer)
        ..configure(learningRate, minWeightsDistance, iterationLimit, regularization, alpha: alpha),
      estimatorType: estimatorType);
}