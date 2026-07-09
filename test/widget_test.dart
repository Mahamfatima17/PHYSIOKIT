import 'package:flutter_test/flutter_test.dart';
import 'package:physiokit/models/special_test.dart';

void main() {
  test('SpecialTest model mapping test', () {
    final testMap = {
      'id': 1,
      'name': 'Test Test',
      'category': 'Musculoskeletal',
      'region': 'Knee',
      'purpose': 'Verify tests',
      'procedure': 'Do steps',
      'positive_sign': 'Pain',
    };

    final specialTest = SpecialTest.fromMap(testMap);
    expect(specialTest.id, 1);
    expect(specialTest.name, 'Test Test');
    expect(specialTest.category, 'Musculoskeletal');
    expect(specialTest.region, 'Knee');
    expect(specialTest.purpose, 'Verify tests');
    expect(specialTest.procedure, 'Do steps');
    expect(specialTest.positiveSign, 'Pain');
  });
}
