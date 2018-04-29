import 'package:dart_ml/src/classifier/classifier.dart';
import 'package:dart_ml/src/cost_function/cost_function_factory.dart';
import 'package:dart_ml/src/math/randomizer/randomizer_factory.dart';
import 'package:dart_ml/src/optimizer/gradient.dart';
import 'package:dart_ml/src/optimizer/initial_weights_generator/initial_weights_generator_factory.dart';
import 'package:dart_ml/src/optimizer/learning_rate_generator/learning_rate_generator_factory.dart';

class LogisticRegressor extends Classifier {
  LogisticRegressor({
    int iterationLimit,
    double learningRate,
    double minWeightsUpdate,
    double lambda,
    int batchSize = 1
  }) : super(
    new GradientOptimizer(
      RandomizerFactory.Default(),
      CostFunctionFactory.LogLikelihood(),
      LearningRateGeneratorFactory.Simple(),
      InitialWeightsGeneratorFactory.ZeroWeights(),

      learningRate: learningRate,
      minCoefficientsUpdate: minWeightsUpdate,
      iterationLimit: iterationLimit,
      lambda: lambda,
      batchSize: batchSize
    )
  );
}