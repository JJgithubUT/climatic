import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final Timestamp fecha;
  final double tempActual;
  final double tempObjetivo;

  HistoryModel({
    required this.fecha,
    required this.tempActual,
    required this.tempObjetivo,
  });

  factory HistoryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryModel(
      fecha: data['fecha_his'] as Timestamp? ?? Timestamp.now(),
      tempActual: (data['temp_actual_his'] as num).toDouble(),
      tempObjetivo: (data['temp_objetivo_his'] as num).toDouble(),
    );
  }
}
