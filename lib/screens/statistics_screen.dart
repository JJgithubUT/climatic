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
    }

    return '';
  }

  // Método que espera a que los datos sean recuperados
Future<List<HistoryModel>> _getStatistics(
    DateTime start,
    DateTime end,
    String codigo,
  ) async {
    // Llamar al servicio y esperar la respuesta
    List<HistoryModel> history = await CloudFirestoreService().getHistoryForPeriodAndCode(
      start,
      end,
      codigo,
    );
    return history;
  }


  // Método para formatear la fecha
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );
      if (time != null) {
        final newDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        if (newDateTime != _startDate) {
          // Solo actualizar si la fecha cambió
          setState(() {
            _startDate = newDateTime;
          });
        }
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate),
      );
      if (time != null) {
        final newDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        if (newDateTime != _endDate) {
          // Solo actualizar si la fecha cambió
          setState(() {
            _endDate = newDateTime;
          });
        }
      }
    }
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
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Botones para seleccionar fechas
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => _selectStartDate(context),
                              child: Text("Desde: ${_formatDate(_startDate)}"),
                            ),
                            ElevatedButton(
                              onPressed: () => _selectEndDate(context),
                              child: Text("Hasta: ${_formatDate(_endDate)}"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Forzar recarga de FutureBuilder
                      },
                      child: const Text("Actualizar Gráfica"),
                    ),
                    const Expanded(flex: 1, child: SizedBox(height: 10)),
                    // Gráfico de temperatura
                    Expanded(
                      flex: 7,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
