import 'package:ml_algo/src/score_to_prob_mapper/score_to_prob_mapper_factory.dart';
import 'package:ml_algo/src/score_to_prob_mapper/score_to_prob_mapper_type.dart';
import 'package:ml_algo/src/score_to_prob_mapper/logit_mapper.dart';
import 'package:ml_algo/src/score_to_prob_mapper/score_to_prob_mapper.dart';

class ScoreToProbMapperFactoryImpl implements ScoreToProbMapperFactory {
  const ScoreToProbMapperFactoryImpl();

  @override
  ScoreToProbMapper fromType(ScoreToProbMapperType type, Type dtype) {
    switch (type) {
      case ScoreToProbMapperType.logit:
        return LogitMapper(dtype);
      default:
        throw UnsupportedError('Unsupported link function type - $type');
    }
  }
}