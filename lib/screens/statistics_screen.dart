import 'package:climatic/models/device_model.dart';
import 'package:climatic/widgets/statistics_custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:climatic/widgets/graph.dart';
import 'package:climatic/models/history_model.dart';
import 'package:climatic/services/cloud_firestore_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _deviceCode = "esp32trycsrp133";

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(hours: 12));
    _loadDeviceCode();
  }

  Future<void> _loadDeviceCode() async {
    final code = await _getRemoteCode();
    if (code != null && code.isNotEmpty) {
      setState(() {
        _deviceCode = code;
      });
      print('Código encontrado para STATISTICSSSS: $code');
    }
  }

  Future<String?> _getRemoteCode() async {
    final DeviceModel? dispositivo = await CloudFirestoreService().getDevice(
      context,
    );

    if (dispositivo != null) {
      return dispositivo.codigo;
      // ignore: dead_code, avoid_print
      print('Código encontrado para STATISTICSSSS: ${dispositivo.codigo}');
    }

    return '';
  }

  Future<List<HistoryModel>> _getStatistics(
    DateTime start,
    DateTime end,
    String codigo,
  ) {
    return CloudFirestoreService().getHistoryForPeriodAndCode(
      start,
      end,
      codigo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatisticsCustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FutureBuilder<List<HistoryModel>>(
                        future: _getStatistics(
                          _startDate,
                          _endDate,
                          _deviceCode,
                        ),
                        builder: (context, snapshot) {
                          if (_deviceCode == '') {
                            return const Center(
                              child: Text('Código no insertado'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          }

                          final history = snapshot.data ?? [];

                          if (history.isEmpty) {
                            return const Center(
                              child: Text("No hay datos disponibles."),
                            );
                          }

                          return TemperatureGraph(history: history);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );

    /* return Scaffold(
      appBar: AppBar(title: const Text("Graficadora")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<HistoryModel>>(
          future: _getStatistics(_startDate, _endDate, _deviceCode),
          builder: (context, snapshot) {
            if (_deviceCode == '') {
              return const Center(child: Text('Código no insertado'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final history = snapshot.data ?? [];

            if (history.isEmpty) {
              return const Center(child: Text("No hay datos disponibles."));
            }

            return TemperatureGraph(history: history);
          },
        ),
      ),
    ); */
  }
}
