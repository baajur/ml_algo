import 'package:dart_ml/src/math/vector/vector.dart';
import 'package:dart_ml/src/predictor/interface/predictor.dart';
import 'package:dart_ml/src/estimator/estimator.dart';
import 'package:dart_ml/src/data_splitter/interface/splitter.dart';
import 'package:dart_ml/src/di/injector.dart';
import 'package:dart_ml/src/data_splitter/interface/k_fold_splitter.dart';
import 'package:dart_ml/src/data_splitter/interface/leave_p_out_splitter.dart';
import 'cross_validator.dart';

class CrossValidator implements ICrossValidator {
  final Splitter _splitter;

  factory CrossValidator.KFold({int numberOfFolds = 5}) =>
      new CrossValidator._internal((injector.get(KFoldSplitter) as KFoldSplitter)
                                     ..configure(numberOfFolds: numberOfFolds));

  factory CrossValidator.LPO({int p = 5}) =>
      new CrossValidator._internal((injector.get(LeavePOutSplitter) as LeavePOutSplitter)
                                     ..configure(p: p));

  CrossValidator._internal(this._splitter);

  Vector validate(Predictor predictor, List<Vector> features, Vector labels, {Estimator estimator}) {
    if (features.length != labels.length) {
      throw new Exception('Number of features objects must be equal to the number of labels!');
    }

    Iterable<Iterable<int>> allIndices = _splitter.split(features.length);
    List<double> scores = new List<double>(allIndices.length);
    int scoreCounter = 0;

    for (Iterable<int> testIndices in allIndices) {
      List<Vector> trainFeatures = new List<Vector>(features.length - testIndices.length);
      Vector trainLabels = new Vector.zero(features.length - testIndices.length);
      List<Vector> testFeatures = new List<Vector>(testIndices.length);
      Vector testLabels = new Vector.zero(testIndices.length);

      int trainSamplesCounter = 0;
      int testSamplesCounter = 0;

      for (int index = 0; index < features.length; index++) {
        if (testIndices.contains(index)) {
          testFeatures[testSamplesCounter] = features[index];
          testLabels[testSamplesCounter] = labels[index];
          testSamplesCounter++;
        } else {
          trainFeatures[trainSamplesCounter] = features[index];
          trainLabels[trainSamplesCounter] = labels[index];
          trainSamplesCounter++;
        }
      }

      predictor.train(trainFeatures, trainLabels);

      scores[scoreCounter++] = predictor.test(testFeatures, testLabels, estimator: estimator);
    }

    return new Vector.from(scores);
  }
}