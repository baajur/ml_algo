import 'package:ml_algo/src/metric/metric.dart';
import 'package:ml_linalg/linalg.dart';

abstract class RegressionMetric<E> implements Metric<E> {
  @override
  double getError(MLVector<E> predictedLabels, MLVector<E> origLabels);
}
