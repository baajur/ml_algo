import 'package:dart_ml/src/data_splitter/implementation/k_fold_splitter.dart';
import 'package:dart_ml/src/data_splitter/implementation/leave_p_out_splitter.dart';

import 'package:test/test.dart';
import 'package:matcher/matcher.dart';

void main() {
  group('Splitters test:\n', () {
    test('K fold splitter test', () {
      KFoldSplitterImpl splitter = new KFoldSplitterImpl();

      expect(splitter.split(12), equals([[0,1,2],[3,4,5],[6,7],[8,9],[10,11]]));

      splitter.configure(numberOfFolds: 4);
      expect(splitter.split(12), equals([[0,1,2],[3,4,5],[6,7,8],[9,10,11]]));

      splitter.configure(numberOfFolds: 3);
      expect(splitter.split(12), equals([[0,1,2,3],[4,5,6,7],[8,9,10,11]]));

      splitter.configure(numberOfFolds: 1);
      expect(splitter.split(12), equals([[0,1,2,3,4,5,6,7,8,9,10,11]]));

      splitter.configure(numberOfFolds: 12);
      expect(splitter.split(12), equals([[0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]]));

      splitter.configure(numberOfFolds: 5);
      expect(splitter.split(37), equals([[0,1,2,3,4,5,6,7],[8,9,10,11,12,13,14,15],[16,17,18,19,20,21,22],
        [23,24,25,26,27,28,29],[30,31,32,33,34,35,36]]));

      splitter.configure(numberOfFolds: 3);
      expect(() => splitter.split(0), throwsRangeError);

      splitter.configure(numberOfFolds: 9);
      expect(() => splitter.split(8), throwsRangeError);
    });

    test('Leave P out splitter test... ', () {
      LeavePOutSplitterImpl splitter = new LeavePOutSplitterImpl();

      expect(splitter.split(4).toSet(), equals([[0,1], [0,2], [0,3], [1,2], [1,3], [2,3]].toSet()));
      expect(splitter.split(5).toSet(), equals([[0,1], [0,2], [0,3], [0,4], [1,2], [1,3], [1,4], [2,3], [2,4],
        [3,4]].toSet()));

      splitter.configure(p: 1);
      expect(splitter.split(5).toSet(), equals([[0],[1],[2],[3],[4]]));

      splitter.configure(p: 3);
      expect(splitter.split(4).toSet(), equals([[0,1,2], [0,1,3], [0,2,3], [1,2,3]].toSet()));
      expect(splitter.split(5).toSet(), equals([[0,1,2], [0,1,3], [0,1,4], [0,2,3], [0,2,4], [0,3,4], [1,2,3], [1,2,4],
        [1,3,4], [2,3,4]].toSet()));

      expect(() => splitter.configure(p: 0), throwsUnsupportedError);
    });
  });
}