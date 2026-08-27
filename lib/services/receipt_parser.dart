class ReceiptParser {
  static Map<String, dynamic> parse(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final result = <String, dynamic>{
      'rawText': text,
      'total': _findAmount(
        lines,
        RegExp(r'(genel\s+toplam|toplam|ödenecek|odenecek|tutar)'),
      ),
      'subtotal': _findAmount(
        lines,
        RegExp(r'(ara\s+toplam|alt\s+toplam|subtotal)'),
      ),
      'tax': _findAmount(lines, RegExp(r'(kdv|v\.a\.t\.?|vat|vergi)')),
      'date': _findDate(text),
      'time': _findTime(text),
      'receiptNumber': _findReceiptNumber(lines),
      'items': _findItems(lines),
    };

    result.removeWhere((key, value) {
      if (key == 'items') return value is List && value.isEmpty;
      return value == null || value == '';
    });
    return result;
  }

  static String? _findAmount(List<String> lines, RegExp label) {
    for (final line in lines) {
      if (label.hasMatch(line.toLowerCase())) {
        final amounts = _amounts(line);
        if (amounts.isNotEmpty) return amounts.last;
      }
    }
    return null;
  }

  static List<String> _amounts(String line) {
    return RegExp(r'(?<!\d)(\d{1,6}(?:[.,]\d{2})?)(?!\d)')
        .allMatches(line)
        .map((match) => _normalizeAmount(match.group(1)!))
        .toList();
  }

  static String _normalizeAmount(String value) {
    return value.replaceAll(',', '.');
  }

  static String? _findDate(String text) {
    final match = RegExp(r'\b(\d{1,2}[./-]\d{1,2}[./-](?:\d{2}|\d{4}))\b')
        .firstMatch(text);
    return match?.group(1);
  }

  static String? _findTime(String text) {
    final match = RegExp(r'\b([01]?\d|2[0-3])[:.]([0-5]\d)\b').firstMatch(text);
    return match == null ? null : '${match.group(1)}:${match.group(2)}';
  }

  static String? _findReceiptNumber(List<String> lines) {
    final label = RegExp(
      r'(fiş\s*no|fis\s*no|receipt\s*no|belge\s*no|işlem\s*no)',
    );
    for (final line in lines) {
      if (label.hasMatch(line.toLowerCase())) {
        final match = RegExp(
          r'([A-Z0-9][A-Z0-9\-/]{3,})',
          caseSensitive: false,
        ).firstMatch(line);
        if (match != null) return match.group(1);
      }
    }
    return null;
  }

  static List<Map<String, String>> _findItems(List<String> lines) {
    final excluded = RegExp(
      r'(toplam|ödenecek|odenecek|kdv|vergi|tarih|date|saat|time|fiş|fis|receipt|no\b|ara\s+toplam|subtotal|nakit|kart|para\s+üstü|change)',
    );
    final amountAtEnd = RegExp(r'^(.*?)(\d{1,6}[.,]\d{2})\s*$');
    final items = <Map<String, String>>[];

    for (final line in lines) {
      if (excluded.hasMatch(line.toLowerCase())) continue;
      final match = amountAtEnd.firstMatch(line);
      if (match == null) continue;
      final name = match
          .group(1)!
          .replaceAll(RegExp(r'^[\d\s*xX]+'), '')
          .trim();
      if (name.length < 2 || name.length > 80) continue;
      items.add({'name': name, 'amount': _normalizeAmount(match.group(2)!)});
    }
    return items.take(30).toList();
  }
}
