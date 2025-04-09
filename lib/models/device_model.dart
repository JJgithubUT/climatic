import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final String codigo;
  final String correo;
  final bool estado;
  final String nombre;

  DeviceModel({
    required this.id,
    required this.codigo,
    required this.correo,
    required this.estado,
    required this.nombre,
  });

  // Convertir un Dispositivo a un Mapa
  Map<String, dynamic> toMap() {
    return {
      'codigo_dis': codigo,
      'correo_usu': correo,
      'estado_dis': estado,
      'nombre_dis': nombre,
    };
  }

  factory DeviceModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return DeviceModel(
      id: doc.id,
      codigo: doc['codigo_dis'],
      correo: doc['correo_usu'],
      estado: doc['estado_dis'],
      nombre: doc['nombre_dis'],
    );
  }
}
