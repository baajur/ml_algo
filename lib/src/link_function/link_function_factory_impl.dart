import 'package:ml_algo/src/link_function/link_function.dart';
import 'package:ml_algo/src/link_function/link_function_factory.dart';
import 'package:ml_algo/src/link_function/link_function_type.dart';
import 'package:ml_algo/src/link_function/logit_link_function.dart';

class LinkFunctionFactoryImpl implements LinkFunctionFactory {
  const LinkFunctionFactoryImpl();

  @override
  LinkFunction fromType(LinkFunctionType type) {
    switch (type) {
      case LinkFunctionType.logit:
        return LogitLinkFunction();
      default:
        throw UnsupportedError('Unsupported link function type - $type');
    }
  }
}