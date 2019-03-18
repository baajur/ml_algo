import 'package:ml_algo/src/data_preprocessing/categorical_encoder/encoder.dart';
import 'package:ml_algo/src/data_preprocessing/data_frame/labels_extractor/labels_extractor.dart';
import 'package:ml_algo/src/data_preprocessing/data_frame/value_converter/value_converter.dart';

class DataFrameLabelsExtractorImpl implements DataFrameLabelsExtractor {
  DataFrameLabelsExtractorImpl(this.records, this.readMask, this.labelIdx,
      this.valueConverter, this.encoders)
      : rowsNum = readMask.where((bool flag) => flag).length {
    if (readMask.length > records.length) {
      throw Exception(wrongReadMaskLengthMsg);
    }
    if (labelIdx >= records.first.length) {
      throw Exception(wrongLabelIndexMsg);
    }
  }

  static const String wrongReadMaskLengthMsg =
      'Rows read mask for label column should not be greater than the number '
      'of labels in the column!';

  static const String wrongLabelIndexMsg =
      'Labels column index should be less than actual columns number of the '
      'dataset!';

  final List<List<Object>> records;
  final List<bool> readMask;
  final int labelIdx;
  final int rowsNum;
  final Map<int, CategoricalDataEncoder> encoders;
  final DataFrameValueConverter valueConverter;

  @override
  List<List<double>> getLabels() {
    final result = List<List<double>>(rowsNum);
    int _i = 0;
    final categoricalDataExist = encoders != null &&
        encoders.containsKey(labelIdx);
    for (int row = 0; row < readMask.length; row++) {
      if (readMask[row] == true) {
        final dynamic rawValue = records[row][labelIdx];
        final convertedValue = categoricalDataExist
            ? encoders[labelIdx].encodeSingle(rawValue.toString())
                .toList(growable: false)
            : [valueConverter.convert(rawValue)];
        result[_i++] = convertedValue;
      }
    }
    return result;
  }
}
