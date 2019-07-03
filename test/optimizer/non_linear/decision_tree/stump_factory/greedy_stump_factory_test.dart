import 'package:ml_algo/src/optimizer/non_linear/decision_tree/decision_tree_stump.dart';
import 'package:ml_algo/src/optimizer/non_linear/decision_tree/stump_factory/greedy_stump_factory.dart';
import 'package:ml_algo/src/optimizer/non_linear/decision_tree/stump_factory/samples_splitter/samples_splitter.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:xrange/zrange.dart';

import '../../../../test_utils/mocks.dart';

void main() {
  group('GreedyStumpFactory', () {
    group('(splitting by real number)', () {
      test('should sort observations (ASC-direction) by given column and '
          'create stump with minimal error on split', () {
        final inputObservations = Matrix.fromList([
          [10.0, 5.0],
          [-10.0, -20.0],
          [5.0, 20.0],
          [4.0, 34.0],
          [0.0, 10.0],
        ]);

        final outcomesRange = ZRange.singleton(1);

        final bestSplittingValue = 4.5;
        final splittingColumn = 0;

        final mockedWorstStump = DecisionTreeStump(null, null, null, [
          Matrix.fromList([[12.0, 22.0]]),
          Matrix.fromList([[19.0, 31.0]]),
        ]);

        final mockedWorseStump = DecisionTreeStump(null, null, null, [
          Matrix.fromList([[13.0, 24.0]]),
          Matrix.fromList([[29.0, 53.0]]),
        ]);

        final mockedGoodStump = DecisionTreeStump(null, null, null, [
          Matrix.fromList([[1.0, 2.0]]),
          Matrix.fromList([[9.0, 3.0]]),
        ]);

        final mockedBestStump = DecisionTreeStump(null, null, null, [
          Matrix.fromList([[100.0, 200.0]]),
          Matrix.fromList([[300.0, 400.0]]),
        ]);

        final mockedSplitDataToBeReturned = [
          {
            'splittingValue': -5.0,
            'stump': mockedGoodStump,
          },
          {
            'splittingValue': 2.0,
            'stump': mockedWorseStump,
          },
          {
            'splittingValue': bestSplittingValue,
            'stump': mockedBestStump,
          },
          {
            'splittingValue': 7.5,
            'stump': mockedWorstStump,
          },
        ];

        final assessor = SplitAssessorMock();

        when(assessor.getAggregatedError(mockedWorstStump.outputSamples,
            outcomesRange)).thenReturn(0.99);
        when(assessor.getAggregatedError(mockedWorseStump.outputSamples,
            outcomesRange)).thenReturn(0.8);
        when(assessor.getAggregatedError(mockedGoodStump.outputSamples,
            outcomesRange)).thenReturn(0.4);
        when(assessor.getAggregatedError(mockedBestStump.outputSamples,
            outcomesRange)).thenReturn(0.1);

        final splitter = createSplitter(mockedSplitDataToBeReturned);
        final stumpFactory = GreedyStumpFactory(assessor, splitter);
        final stump = stumpFactory.create(inputObservations,
            ZRange.singleton(splittingColumn), outcomesRange);

        for (final splitInfo in mockedSplitDataToBeReturned) {
          final splittingValue = splitInfo['splittingValue'] as double;
          verify(splitter.split(inputObservations, splittingColumn,
              splittingValue)).called(1);
        }

        expect(stump.outputSamples,
            equals(mockedBestStump.outputSamples));
      });
    });

    group('(splitting by categorical values)', () {
      test('should select stump, splitting the observations into parts by '
          'given column range', () {
        final observations = Matrix.fromList([
          [11, 22, 0, 0, 1, 30],
          [60, 23, 0, 0, 1, 20],
          [20, 25, 1, 0, 0, 10],
          [17, 66, 1, 0, 0, 70],
          [13, 99, 0, 1, 0, 30],
        ]);
        final splittingColumnRange = ZRange.closed(2, 4);
        final splittingValues = [
          Vector.fromList([0, 0, 1]),
          Vector.fromList([0, 1, 0]),
          Vector.fromList([1, 0, 0]),
        ];
        final selector = GreedyStumpFactory(null, null);
        final stump = selector.create(
          observations,
          splittingColumnRange,
          null,
          splittingValues,
        );
        expect(stump.outputSamples, equals([
          [
            [11, 22, 0, 0, 1, 30],
            [60, 23, 0, 0, 1, 20],
          ],
          [
            [13, 99, 0, 1, 0, 30],
          ],
          [
            [20, 25, 1, 0, 0, 10],
            [17, 66, 1, 0, 0, 70],
          ],
        ]));
      });

      test('should return just one node in stump that is equal to the given '
          'matrix if splitting value collection contains the only value and '
          'the observations contain just this value in the target column '
          'range', () {
        final observations = Matrix.fromList([
          [11, 22, 0, 0, 1, 30],
          [60, 23, 0, 0, 1, 20],
          [20, 25, 0, 0, 1, 10],
          [17, 66, 0, 0, 1, 70],
          [13, 99, 0, 0, 1, 30],
        ]);
        final splittingColumnRange = ZRange.closed(2, 4);
        final splittingValues = [
          Vector.fromList([0, 0, 1]),
        ];
        final stumpFactory = GreedyStumpFactory(null, null);
        final stump = stumpFactory.create(
          observations,
          splittingColumnRange,
          null,
          splittingValues,
        );
        expect(stump.outputSamples, equals([
          [
            [11, 22, 0, 0, 1, 30],
            [60, 23, 0, 0, 1, 20],
            [20, 25, 0, 0, 1, 10],
            [17, 66, 0, 0, 1, 70],
            [13, 99, 0, 0, 1, 30],
          ],
        ]));
      });

      test('should return just one node in stump that is just a part of the '
          'given matrix if splitting value collection contains the only value '
          'and the observations contain different values in the target column '
          'range', () {
        final observations = Matrix.fromList([
          [11, 22, 0, 0, 1, 30],
          [60, 23, 0, 0, 1, 20],
          [20, 25, 1, 0, 0, 10],
          [17, 66, 1, 0, 0, 70],
          [13, 99, 0, 1, 0, 30],
        ]);
        final splittingColumnRange = ZRange.closed(2, 4);
        final splittingValues = [
          Vector.fromList([0, 0, 1]),
        ];
        final stumpFactory = GreedyStumpFactory(null, null);
        final stump = stumpFactory.create(
          observations,
          splittingColumnRange,
          null,
          splittingValues,
        );
        expect(stump.outputSamples, equals([
          [
            [11, 22, 0, 0, 1, 30],
            [60, 23, 0, 0, 1, 20],
          ],
        ]));
      });

      test('should return an empty stum if splitting value collection is '
          'empty', () {
        final observations = Matrix.fromList([
          [11, 22, 0, 0, 1, 30],
          [60, 23, 0, 0, 1, 20],
          [20, 25, 1, 0, 0, 10],
          [17, 66, 1, 0, 0, 70],
          [13, 99, 0, 1, 0, 30],
        ]);
        final splittingColumnRange = ZRange.closed(2, 4);
        final splittingValues = <Vector>[];
        final stumpFactory = GreedyStumpFactory(null, null);
        final stump = stumpFactory.create(
          observations,
          splittingColumnRange,
          null,
          splittingValues,
        );
        expect(stump.outputSamples, equals(<Matrix>[]));
      });

      test('should return an empty stump if no one value from the splitting'
          'value collection is not contained in the target column range', () {
        final observations = Matrix.fromList([
          [11, 22, 0, 0, 1, 30],
          [60, 23, 0, 0, 1, 20],
          [20, 25, 1, 0, 0, 10],
          [17, 66, 1, 0, 0, 70],
          [13, 99, 0, 1, 0, 30],
        ]);
        final splittingColumnRange = ZRange.closed(2, 4);
        final splittingValues = [
          Vector.randomFilled(3),
          Vector.randomFilled(3),
          Vector.randomFilled(3),
        ];
        final stumpFactory = GreedyStumpFactory(null, null);
        final stump = stumpFactory.create(
          observations,
          splittingColumnRange,
          null,
          splittingValues,
        );
        expect(stump.outputSamples, equals(<Matrix>[]));
      });

      test('should not throw an error if at least one\'s length of the given '
          'splitting vectors does not match the length of the target column'
          'range', () {
        final observations = Matrix.fromList([
          [11, 22, 0, 0, 1, 30],
          [60, 23, 0, 0, 1, 20],
          [20, 25, 1, 0, 0, 10],
          [17, 66, 1, 0, 0, 70],
          [13, 99, 0, 1, 0, 30],
        ]);
        final splittingColumnRange = ZRange.closed(2, 4);
        final splittingValues = [
          Vector.fromList([0, 0, 1]),
          Vector.fromList([0, 1, 0]),
          Vector.fromList([1, 0, 0, 0]),
        ];
        final stumpFactory = GreedyStumpFactory(null, null);
        final stump = stumpFactory.create(
          observations,
          splittingColumnRange,
          null,
          splittingValues,
        );

        expect(stump.outputSamples, equals([
          [
            [11, 22, 0, 0, 1, 30],
            [60, 23, 0, 0, 1, 20],
          ],
          [
            [13, 99, 0, 1, 0, 30],
          ],
        ]));
      });

      test('should throw an error if unappropriate range is given (left '
          'boundary is less than 0)', () {
        final observations = Matrix.fromList([
          [11, 22, 0, 0, 1, 30],
          [60, 23, 0, 0, 1, 20],
          [20, 25, 1, 0, 0, 10],
          [17, 66, 1, 0, 0, 70],
          [13, 99, 0, 1, 0, 30],
        ]);
        final splittingColumnRange = ZRange.closed(-2, 4);
        final splittingValues = [
          Vector.fromList([0, 0, 1]),
          Vector.fromList([0, 1, 0]),
        ];
        final stumpFactory = GreedyStumpFactory(null, null);
        final actual = () => stumpFactory.create(
          observations,
          splittingColumnRange,
          null,
          splittingValues,
        );
        expect(actual, throwsException);
      });

      test('should throw an error if unappropriate range is given (right '
          'boundary is greater than the observations columns number)', () {
        final observations = Matrix.fromList([
          [11, 22, 0, 0, 1, 30],
          [60, 23, 0, 0, 1, 20],
          [20, 25, 1, 0, 0, 10],
          [17, 66, 1, 0, 0, 70],
          [13, 99, 0, 1, 0, 30],
        ]);
        final splittingColumnRange = ZRange.closed(0, 10);
        final splittingValues = [
          Vector.fromList([0, 0, 1]),
          Vector.fromList([0, 1, 0]),
        ];
        final selector = GreedyStumpFactory(null, null);
        final actual = () => selector.create(
          observations,
          splittingColumnRange,
          null,
          splittingValues,
        );
        expect(actual, throwsException);
      });
    });
  });
}

SamplesSplitter createSplitter(List<Map<String, dynamic>> mockedData) {
  final splitter = ObservationsSplitterMock();
  for (final splitInfo in mockedData) {
    final splittingValue = splitInfo['splittingValue'] as double;
    when(splitter.split(any, any, splittingValue)).thenAnswer((_) {
      final stump = splitInfo['stump'] as DecisionTreeStump;
      return stump.outputSamples.toList();
    });
  }
  return splitter;
}
