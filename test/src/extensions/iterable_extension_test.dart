import 'package:dson_adapter/src/extensions/iterable_extension.dart';
import 'package:test/test.dart';

void main() {
  test(
      'Given [Iterable] has a searched element, '
      'When [Iterable.firstWhereOrNull] is called, '
      'Then it should return the element', () async {
    const iterable = [1, 2, 3];
    const searchedElement = 3;

    final result =
        iterable.firstWhereOrNull((element) => element == searchedElement);

    expect(result, 3);
  });

  test(
      'Given [Iterable] does not have a searched element, '
      'When [Iterable.firstWhereOrNull] is called, '
      'Then it should return [null]', () async {
    const iterable = [1, 2, 3];
    const searchedElement = 4;

    final result =
        iterable.firstWhereOrNull((element) => element == searchedElement);

    expect(result, null);
  });
}
