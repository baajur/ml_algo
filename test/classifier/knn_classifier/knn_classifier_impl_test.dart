import 'package:ml_algo/src/classifier/knn_classifier/knn_classifier_impl.dart';
import 'package:ml_algo/src/knn_solver/neigbour.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mocks.dart';

void main() {
  group('KnnClassifierImpl', () {
    group('constructor', () {
      final solverMock = KnnSolverMock();
      final kernelMock = KernelMock();

      tearDown(() {
        reset(solverMock);
        reset(kernelMock);
      });

      test('should throw an exception if no class labels are provided', () {
        final classLabels = <num>[];
        final actual = () => KnnClassifierImpl(
          'target',
          classLabels,
          kernelMock,
          solverMock,
          DType.float32,
        );

        expect(actual, throwsException);
      });
    });

    group('predict method', () {
      final solverMock = KnnSolverMock();
      final kernelMock = KernelMock();

      setUp(() => when(kernelMock.getWeightByDistance(any, any)).thenReturn(1));

      tearDown(() {
        reset(solverMock);
        reset(kernelMock);
      });

      test('should throw an exception if no features are provided', () {
        final classifier = KnnClassifierImpl(
          'target',
          [1],
          kernelMock,
          solverMock,
          DType.float32,
        );

        final features = DataFrame.fromMatrix(Matrix.empty());

        expect(() => classifier.predict(features), throwsException);
      });

      test('should return a dataframe with just one column, consisting of '
          'weighted majority-based outcomes of closest observations of provided '
          'features', () {
        final classLabels = [1, 2, 3];
        final classifier = KnnClassifierImpl(
          'target',
          classLabels,
          kernelMock,
          solverMock,
          DType.float32,
        );

        final testFeatureMatrix = Matrix.fromList(
          [
            [10, 10, 10, 10],
            [20, 20, 20, 20],
            [30, 30, 30, 30],
          ],
        );

        final testFeatures = DataFrame.fromMatrix(testFeatureMatrix);

        final mockedNeighbours = [
          [
            Neighbour(1, Vector.fromList([1])),
            Neighbour(20, Vector.fromList([2])),
            Neighbour(21, Vector.fromList([1])),
          ],
          [
            Neighbour(33, Vector.fromList([1])),
            Neighbour(44, Vector.fromList([3])),
            Neighbour(93, Vector.fromList([3])),
          ],
          [
            Neighbour(-1, Vector.fromList([2])),
            Neighbour(-30, Vector.fromList([2])),
            Neighbour(-40, Vector.fromList([1])),
          ],
        ];

        when(kernelMock.getWeightByDistance(1)).thenReturn(10);
        when(kernelMock.getWeightByDistance(20)).thenReturn(15);
        when(kernelMock.getWeightByDistance(21)).thenReturn(10);

        when(kernelMock.getWeightByDistance(33)).thenReturn(11);
        when(kernelMock.getWeightByDistance(44)).thenReturn(15);
        when(kernelMock.getWeightByDistance(93)).thenReturn(15);

        when(kernelMock.getWeightByDistance(-1)).thenReturn(5);
        when(kernelMock.getWeightByDistance(-30)).thenReturn(5);
        when(kernelMock.getWeightByDistance(-40)).thenReturn(1);

        when(solverMock.findKNeighbours(testFeatureMatrix))
            .thenReturn(mockedNeighbours);

        final actual = classifier.predict(testFeatures);

        final expectedOutcomes = [
          [1],
          [3],
          [2],
        ];

        expect(actual.rows, equals(expectedOutcomes));
      });

      test('should return a dataframe, consisting of just one column with '
          'a proper name', () {
        final classLabels = [1, 2];

        final classifier = KnnClassifierImpl(
          'target',
          classLabels,
          kernelMock,
          solverMock,
          DType.float32,
        );

        final testFeatureMatrix = Matrix.fromList(
          [
            [10, 10, 10, 10],
          ],
        );

        final testFeatures = DataFrame.fromMatrix(testFeatureMatrix);

        final mockedNeighbours = [
          [
            Neighbour(1, Vector.fromList([1])),
            Neighbour(20, Vector.fromList([2])),
            Neighbour(21, Vector.fromList([1])),
          ],
        ];

        when(solverMock.findKNeighbours(testFeatureMatrix))
            .thenReturn(mockedNeighbours);

        final actual = classifier.predict(testFeatures);

        expect(actual.header, equals(['target']));
      });

      test('should return a label of first neighbour among found k neighbours '
          'if there is no major class', () {
        final classLabels = [1, 2, 3];
        final classifier = KnnClassifierImpl(
          'target',
          classLabels,
          kernelMock,
          solverMock,
          DType.float32,
        );

        final testFeatureMatrix = Matrix.fromList(
          [
            [10, 10, 10, 10],
          ],
        );

        final testFeatures = DataFrame.fromMatrix(testFeatureMatrix);

        final mockedNeighbours = [
          [
            Neighbour(-1, Vector.fromList([3])),
            Neighbour(-30, Vector.fromList([2])),
            Neighbour(-40, Vector.fromList([1])),
          ],
        ];

        when(solverMock.findKNeighbours(testFeatureMatrix))
            .thenReturn(mockedNeighbours);

        final actual = classifier.predict(testFeatures);

        final expectedOutcomes = [
          [3],
        ];

        expect(actual.rows, equals(expectedOutcomes));
      });

      test('should return a label of neighbours with bigger weights even if '
          'they are not the majority', () {
        final classLabels = [1, 2, 3];
        final classifier = KnnClassifierImpl(
          'target',
          classLabels,
          kernelMock,
          solverMock,
          DType.float32,
        );

        final testFeatureMatrix = Matrix.fromList(
          [
            [10, 10, 10, 10],
          ],
        );

        final testFeatures = DataFrame.fromMatrix(testFeatureMatrix);

        final mockedNeighbours = [
          [
            Neighbour(0, Vector.fromList([1])),
            Neighbour(2, Vector.fromList([2])),
            Neighbour(3, Vector.fromList([1])),
          ],
        ];

        when(kernelMock.getWeightByDistance(0)).thenReturn(1);
        when(kernelMock.getWeightByDistance(2)).thenReturn(100);
        when(kernelMock.getWeightByDistance(3)).thenReturn(5);

        when(solverMock.findKNeighbours(testFeatureMatrix))
            .thenReturn(mockedNeighbours);

        final actual = classifier.predict(testFeatures);

        final expectedOutcomes = [
          [2],
        ];

        expect(actual.rows, equals(expectedOutcomes));
      });
    });
  });
}
