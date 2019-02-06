import 'dart:typed_data';

import 'package:ml_algo/learning_rate_type.dart';
import 'package:ml_algo/src/classifier/labels_distribution_calculator/labels_probability_calculator.dart';
import 'package:ml_algo/src/classifier/labels_distribution_calculator/labels_probability_calculator_factory.dart';
import 'package:ml_algo/src/classifier/labels_processor/labels_processor.dart';
import 'package:ml_algo/src/classifier/labels_processor/labels_processor_factory.dart';
import 'package:ml_algo/src/classifier/logistic_regressor.dart';
import 'package:ml_algo/src/data_preprocessing/intercept_preprocessor/intercept_preprocessor.dart';
import 'package:ml_algo/src/data_preprocessing/intercept_preprocessor/intercept_preprocessor_factory.dart';
import 'package:ml_algo/src/link_function/link_function_type.dart';
import 'package:ml_algo/src/optimizer/initial_weights_generator/initial_weights_type.dart';
import 'package:ml_algo/src/optimizer/optimizer.dart';
import 'package:ml_algo/src/optimizer/optimizer_factory.dart';

import '../test_utils/mocks.dart';

LabelsProcessor labelsProcessorMock;
LabelsProcessorFactory labelsProcessorFactoryMock;
InterceptPreprocessor interceptPreprocessorMock;
InterceptPreprocessorFactory interceptPreprocessorFactoryMock;
LabelsProbabilityCalculator probabilityCalculatorMock;
LabelsProbabilityCalculatorFactory probabilityCalculatorFactoryMock;
Optimizer optimizerMock;
OptimizerFactory optimizerFactoryMock;

void setUpLabelsProcessorFactory() {
  labelsProcessorMock = LabelsProcessorMock();
  labelsProcessorFactoryMock = createLabelsProcessorFactoryMock(processors: {Float32x4: labelsProcessorMock});
}

void setUpInterceptPreprocessorFactory() {
  interceptPreprocessorMock = InterceptPreprocessorMock();
  interceptPreprocessorFactoryMock = createInterceptPreprocessorFactoryMock(
      preprocessor: interceptPreprocessorMock);
}

void setUpProbabilityCalculatorFactory() {
  probabilityCalculatorMock = LabelsProbabilityCalculatorMock();
  probabilityCalculatorFactoryMock = createLabelsProbabilityCalculatorFactoryMock(
    linkType: LinkFunctionType.logit,
    dtype: Float32x4,
    calculator: probabilityCalculatorMock,
  );
}

void setUpOptimizerFactory() {
  optimizerMock = OptimizerMock();
  optimizerFactoryMock = createOptimizerFactoryMock(gradient: optimizerMock);
}

LogisticRegressor createRegressor({
  int iterationLimit = 100,
  double learningRate = 0.01,
  double minWeightsUpdate = 0.001,
  double lambda = 0.1,
  int randomSeed = 123,
}) =>
  LogisticRegressor(
      learningRateType: LearningRateType.constant,
      initialWeightsType: InitialWeightsType.zeroes,
      iterationLimit: iterationLimit,
      learningRate: learningRate,
      minWeightsUpdate: minWeightsUpdate,
      lambda: lambda,
      labelsProcessorFactory: labelsProcessorFactoryMock,
      interceptPreprocessorFactory: interceptPreprocessorFactoryMock,
      linkFunctionType: LinkFunctionType.logit,
      probabilityCalculatorFactory: probabilityCalculatorFactoryMock,
      optimizerFactory: optimizerFactoryMock,
      randomSeed: randomSeed,
  );
