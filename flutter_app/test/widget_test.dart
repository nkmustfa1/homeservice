import 'package:flutter_test/flutter_test.dart';
import 'package:homeservice/core/utils/category_image_helper.dart';

void main() {
  test('returns the default service image for unknown categories', () {
    expect(
      getCategoryImage('unknown category'),
      'assets/images/services/default_image.png',
    );
  });
}
