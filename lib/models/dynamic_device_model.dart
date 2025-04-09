import 'package:cloud_firestore/cloud_firestore.dart';

class DynamicDeviceModel {
  final double tempActual;
  final double tempObjetivo;

  DynamicDeviceModel({
    required this.tempActual,
    required this.tempObjetivo,
  });

  Map<String, dynamic> toMap() {
    return {
      'temp_actual_dis': tempActual,
      'temp_objetivo_dis': tempObjetivo,
    };
  }

  factory DynamicDeviceModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return DynamicDeviceModel(
      tempActual: (doc['temp_actual_dis'] as num).toDouble(),
      tempObjetivo: (doc['temp_objetivo_dis'] as num).toDouble(),
    );
  }
}
