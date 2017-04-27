import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:dart_ml/dart_ml.dart';
import 'package:csv/csv.dart' as csv;

main() async {
  csv.CsvCodec csvCodec = new csv.CsvCodec();
  Stream<List<int>> input = new File('example/advertising.csv').openRead();
  List<List<num>> fields = (await input.transform(UTF8.decoder)
      .transform(csvCodec.decoder).toList() as List<List<num>>)
      .sublist(1);

  List<double> extractFeatures(item) => item.sublist(0, 3)
      .map((num feature) => feature.toDouble())
      .toList();

  List<TypedVector> allFeatures = fields
      .map((List<num> item) => new TypedVector.from(extractFeatures(item)))
      .toList(growable: false);

  TypedVector allLabels = new TypedVector.from(fields.map((List<num> item) => item.last.toDouble()).toList());

  Map<DataCategory, List<VectorInterface>> splittedFeatures = DataTrainTestSplitter.splitMatrix(allFeatures, .6);
  Map<DataCategory, VectorInterface> splitedLabels = DataTrainTestSplitter.splitVector(allLabels, .6);

  List<TypedVector> trainFeatures = splittedFeatures[DataCategory.TRAIN];
  TypedVector trainLabels = splitedLabels[DataCategory.TRAIN];

  List<TypedVector> testFeatures = splittedFeatures[DataCategory.TEST];
  TypedVector testLabels = splitedLabels[DataCategory.TEST];

  RMSEEstimator rmseEstimator = new RMSEEstimator();
  MAPEEstimator mapeEstimator = new MAPEEstimator();

  SGDLinearRegressor sgdRegressor = new SGDLinearRegressor();
  BGDLinearRegressor batchGdRegressor = new BGDLinearRegressor();
  MBGDLinearRegressor mbgdRegressor = new MBGDLinearRegressor();

  int dimension = trainFeatures.first.length;

  batchGdRegressor.train(trainFeatures, trainLabels, new TypedVector(dimension));
  sgdRegressor.train(trainFeatures, trainLabels, new TypedVector(dimension));
  mbgdRegressor.train(trainFeatures, trainLabels, new TypedVector(dimension));

  print("SGD regressor weights: ${sgdRegressor.weights}");
  print("Batch GD regressor weights: ${batchGdRegressor.weights}");
  print("Mini batch GD regressor weights: ${mbgdRegressor.weights}\n");

  VectorInterface sgdPrediction = sgdRegressor.predict(testFeatures, new TypedVector(testFeatures.length));
  VectorInterface batchGdPrediction = batchGdRegressor.predict(testFeatures, new TypedVector(testFeatures.length));
  VectorInterface mbgdPrediction = mbgdRegressor.predict(testFeatures, new TypedVector(testFeatures.length));

  print("SGD regressor, rmse (test) is: ${rmseEstimator.calculateError(sgdPrediction, testLabels)}");
  print("SGD regressor, mape (test) is: ${mapeEstimator.calculateError(sgdPrediction, testLabels)}\n");

  print("Batch GD regressor, rmse (test) is: ${rmseEstimator.calculateError(batchGdPrediction, testLabels)}");
  print("Batch GD regressor, mape (test) is: ${mapeEstimator.calculateError(batchGdPrediction, testLabels)}\n");

  print("Mini Batch GD regressor, rmse (test) is: ${rmseEstimator.calculateError(mbgdPrediction, testLabels)}");
  print("Mini Batch GD regressor, mape (test) is: ${mapeEstimator.calculateError(mbgdPrediction, testLabels)}");
}
