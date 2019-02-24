import 'dart:typed_data';

import 'package:ml_algo/src/cost_function/cost_function.dart';
import 'package:ml_algo/src/default_parameter_values.dart';
import 'package:ml_algo/src/score_to_prob_mapper/score_to_prob_mapper.dart';
import 'package:ml_algo/src/score_to_prob_mapper/score_to_prob_mapper_factory.dart';
import 'package:ml_algo/src/score_to_prob_mapper/score_to_prob_mapper_factory_impl.dart';
import 'package:ml_algo/src/score_to_prob_mapper/score_to_prob_mapper_type.dart';
import 'package:ml_linalg/linalg.dart';

class LogLikelihoodCost implements CostFunction {
  LogLikelihoodCost(
      ScoreToProbMapperType scoreToProbMapperType, {
        Type dtype = DefaultParameterValues.dtype,
        ScoreToProbMapperFactory scoreToProbMapperFactory =
        const ScoreToProbMapperFactoryImpl(),
      }) : scoreToProbMapper =
  scoreToProbMapperFactory.fromType(scoreToProbMapperType, dtype);

  final ScoreToProbMapper scoreToProbMapper;

  @override
  double getCost(double score, double yOrig) {
    throw UnimplementedError();
  }

  @override
  MLMatrix getGradient(MLMatrix x, MLMatrix w, MLMatrix y) =>
    x.transpose() * (y - scoreToProbMapper.linkScoresToProbs(x * w));

  @override
  MLVector getSubDerivative(int wIdx, MLMatrix x, MLMatrix w, MLMatrix y) =>
      throw UnimplementedError();
}
