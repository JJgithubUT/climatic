import 'package:climatic/models/history_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TemperatureGraph extends StatelessWidget {
  final List<HistoryModel> history;

  const TemperatureGraph({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos disponibles.',
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    final sortedHistory = List<HistoryModel>.from(history)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final allTemps =
        sortedHistory.expand((h) => [h.tempActual, h.tempObjetivo]).toList();
    final minTemp = allTemps.reduce((a, b) => a < b ? a : b);
    final maxTemp = allTemps.reduce((a, b) => a > b ? a : b);

    final spotsActual = <FlSpot>[];
    final spotsObjetivo = <FlSpot>[];

    for (int i = 0; i < sortedHistory.length; i++) {
      final h = sortedHistory[i];
      spotsActual.add(FlSpot(i.toDouble(), h.tempActual));
      spotsObjetivo.add(FlSpot(i.toDouble(), h.tempObjetivo));
    }

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.black,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval:
                            (sortedHistory.length / 6)
                                .ceilToDouble(), // mostrar cada X etiquetas
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedHistory.length) {
                            return const SizedBox.shrink();
                          }

                          final date = sortedHistory[index].fecha.toDate();
                          final formatted = DateFormat(
                            'dd/MM\nHH:mm',
                          ).format(date);

                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatted,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.white10, strokeWidth: 0.5),
                    getDrawingVerticalLine:
                        (value) =>
                            FlLine(color: Colors.white10, strokeWidth: 0.5),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spotsActual,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlue],
                      ),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: spotsObjetivo,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Colors.redAccent, Colors.red],
                      ),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  minY: minTemp - 1,
                  maxY: maxTemp + 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
