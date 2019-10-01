import 'package:ml_algo/src/algorithms/knn/kernel.dart';
import 'package:ml_algo/src/algorithms/knn/kernel_function_factory.dart';
import 'package:ml_algo/src/algorithms/knn/kernel_function_factory_impl.dart';
import 'package:ml_algo/src/algorithms/knn/kernel_type.dart';
import 'package:ml_algo/src/algorithms/knn/knn.dart';
import 'package:ml_algo/src/predictor/assessable_predictor_mixin.dart';
import 'package:ml_algo/src/regressor/parameterless_regressor.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_linalg/distance.dart';
import 'package:ml_linalg/dtype.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

class KNNRegressorImpl with AssessablePredictorMixin
    implements ParameterlessRegressor {

  KNNRegressorImpl(
      this._trainingFeatures,
      this._trainingOutcomes,
      this._targetName, {
        int k,
        Distance distance = Distance.euclidean,
        FindKnnFn solverFn = findKNeighbours,
        Kernel kernel = Kernel.uniform,
        DType dtype = DType.float32,

        KernelFunctionFactory kernelFnFactory =
          const KernelFunctionFactoryImpl(),
      }) :
        _k = k,
        _distanceType = distance,
        _solverFn = solverFn,
        _dtype = dtype,
        _kernelFn = kernelFnFactory.createByType(kernel) {
    if (_trainingFeatures.rowsNum != _trainingOutcomes.rowsNum) {
      throw Exception('Number of observations and number of outcomes have to be'
          'equal');
    }
    if (_k > _trainingFeatures.rowsNum) {
      throw Exception('Parameter k should be less than or equal to the number '
          'of training observations');
    }
  }

  final Matrix _trainingFeatures;
  final Matrix _trainingOutcomes;
  final String _targetName;
  final Distance _distanceType;
  final int _k;
  final FindKnnFn _solverFn;
  final KernelFn _kernelFn;
  final DType _dtype;

  Vector get _zeroVector => _cachedZeroVector ??= Vector.zero(
      _trainingOutcomes.columnsNum, dtype: _dtype);
  Vector _cachedZeroVector;

  @override
  DataFrame predict(Matrix observations) {
    final prediction = Matrix.fromRows(
        _generateOutcomes(observations)
            .toList(growable: false),
        dtype: _dtype,
    );

    return DataFrame.fromMatrix(
      prediction,
      header: [_targetName],
    );
  }

  Iterable<Vector> _generateOutcomes(Matrix observations) sync* {
    for (final kNeighbours in _solverFn(_k, _trainingFeatures, _trainingOutcomes,
        observations, distance: _distanceType)) {
      yield kNeighbours
          .fold<Vector>(_zeroVector,
              (sum, pair) => sum + pair.label * _kernelFn(pair.distance)) / _k;
    }
  }
}
