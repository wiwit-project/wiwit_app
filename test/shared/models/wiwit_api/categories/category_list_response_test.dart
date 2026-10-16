import 'package:flutter_test/flutter_test.dart';
import 'package:wiwit_app/shared/models/wiwit_api/categories/category_list_response.dart';

void main() {
  test('parses category items and pagination metadata', () {
    final response = CategoryListResponse.fromJson({
      'data': [
        {
          'id': 1,
          'name': 'Food',
          'description': 'Groceries and meals',
          'is_active': true,
          'transactions_count': 0,
          'created_at': '2026-07-20T14:36:15.000000Z',
          'updated_at': '2026-07-20T14:36:15.000000Z',
          'links': {},
        },
      ],
      'meta': {'page': 1, 'per_page': 20, 'total': 1, 'last_page': 1},
      'links': {},
    });

    expect(response.data.single.name, 'Food');
    expect(response.data.single.description, 'Groceries and meals');
    expect(response.meta.page, 1);
    expect(response.meta.perPage, 20);
    expect(response.meta.total, 1);
    expect(response.meta.lastPage, 1);
  });
}
