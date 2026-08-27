import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> links;

  const StatisticsScreen({super.key, required this.links});

  double _amount(Map<String, dynamic> link) {
    final value = link['receiptData'] is Map
        ? (link['receiptData'] as Map)['total']
        : null;
    return double.tryParse('$value'.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final total = links.fold<double>(0, (sum, link) => sum + _amount(link));
    final bars = links.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [BarChartRodData(toY: _amount(entry.value), width: 14)],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Harcama İstatistikleri')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toplam harcama',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${total.toStringAsFixed(2)} TL',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 28),
            Expanded(
              child: bars.isEmpty
                  ? const Center(
                      child: Text('İstatistik için kayıt bulunmuyor.'),
                    )
                  : BarChart(
                      BarChartData(
                        barGroups: bars,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
