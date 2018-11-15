import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_ml/src/cost_function/cost_function.dart';
import 'package:dart_ml/src/optimizer/initial_weights_generator/initial_weights_generator.dart';
import 'package:dart_ml/src/optimizer/optimizer.dart';
import 'package:linalg/vector.dart';

class CoordinateOptimizer implements Optimizer<Float32x4, Float32x4List, Float32List> {
  final InitialWeightsGenerator _initialCoefficientsGenerator;
  final CostFunction _costFn;

  //hyper parameters declaration
  final double _coefficientDiffThreshold;
  final int _iterationLimit;
  final double _lambda;
  //hyper parameters declaration end

  SIMDVector _normalizer;

  CoordinateOptimizer(
    this._initialCoefficientsGenerator,
    this._costFn,
    {
      double minCoefficientsDiff,
      int iterationLimit,
      double lambda
    }
  ) :
    _iterationLimit = iterationLimit ?? 1000,
    _coefficientDiffThreshold = minCoefficientsDiff,
    _lambda = lambda ?? 0.0;

  @override
  SIMDVector<Float32x4List, Float32List, Float32x4> findExtrema(
    List<SIMDVector<Float32x4List, Float32List, Float32x4>> points,
    SIMDVector<Float32x4List, Float32List, Float32x4> labels,
    {
      SIMDVector<Float32x4List, Float32List, Float32x4> initialWeights,
      bool isMinimizingObjective = true,
      bool arePointsNormalized = false
    }
  ) {
    final numOfDimensions = points.first.length;
    _normalizer = arePointsNormalized
      ? Float32x4VectorFactory.filled(numOfDimensions, 1.0)
      : points.reduce((combine, vector) => (combine + vector * vector));

    SIMDVector<Float32x4List, Float32List, Float32x4> coefficients =
        initialWeights ?? _initialCoefficientsGenerator.generate(points.first.length);
    final changes = List<double>.filled(numOfDimensions, double.infinity);
    int iteration = 0;

    while (!_isConverged(changes, iteration)) {
      final updatedCoefficients = List<double>.filled(coefficients.length, 0.0, growable: false);

      for (int j = 0; j < coefficients.length; j++) {
        final oldWeight = updatedCoefficients[j];
        final newWeight = _coordinateDescentStep(j, points, labels, coefficients);
        changes[j] = (oldWeight - newWeight).abs();
        updatedCoefficients[j] = newWeight;
        coefficients = Float32x4VectorFactory.from(updatedCoefficients);
      }

      iteration++;
    }

    return coefficients;
  }

  bool _isConverged(List<double> changes, int iterationCount) =>
      _coefficientDiffThreshold != null &&
      changes.reduce((double maxValue, double value) => math.max<double>(maxValue ?? 0.0, value)) <= _coefficientDiffThreshold ||
      iterationCount >= _iterationLimit;

  double _coordinateDescentStep(
    int coefficientNum,
    List<SIMDVector<Float32x4List, Float32List, Float32x4>> points,
    SIMDVector<Float32x4List, Float32List, Float32x4> labels,
    SIMDVector<Float32x4List, Float32List, Float32x4> coefficients
  ) {
    final currentCoefficient = coefficients[coefficientNum];
    double updatedCoefficient = currentCoefficient;

    for (int rowNum = 0; rowNum < points.length; rowNum++) {
      final point = points[rowNum];
      final output = labels[rowNum];
      updatedCoefficient += _costFn.getSparseSolutionPartial(coefficientNum, point, coefficients, output);
    }

    return _regularize(updatedCoefficient, _lambda, coefficientNum);
  }

  double _regularize(double coefficient, double lambda, int coefNum) {
    if (lambda == 0.0) {
      return coefficient;
    }

    final threshold = lambda / 2;
    double regularized;

    if (coefficient > threshold) {
      regularized = (coefficient - threshold) / _normalizer[coefNum];
    } else if (coefficient < -threshold) {
      regularized = (coefficient + threshold) / _normalizer[coefNum];
    } else {
      regularized = 0.0;
    }

    return regularized;
  }
}