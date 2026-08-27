import 'package:flutter_test/flutter_test.dart';
import 'package:link_app/services/receipt_parser.dart';

void main() {
  test('parses common receipt fields and line items', () {
    final result = ReceiptParser.parse('''
      MARKET ABC
      Tarih: 27.08.2026 14:32
      Fiş No: A12345
      Kahve 45,90
      Genel Toplam: 45,90
      KDV: 7,65
    ''');

    expect(result['date'], '27.08.2026');
    expect(result['time'], '14:32');
    expect(result['receiptNumber'], 'A12345');
    expect(result['total'], '45.90');
    expect(result['tax'], '7.65');
    expect(result['items'], hasLength(1));
    expect(result['items'][0]['name'], 'Kahve');
  });
}
