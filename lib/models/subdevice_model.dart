import 'package:cloud_firestore/cloud_firestore.dart';

class SubdeviceModel {
  final String id;
  late final String codigo;
  final String correo;
  late final String nombre;

  SubdeviceModel({
    required this.id,
    required this.codigo,
    required this.correo,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo_sub': codigo, 
      'correo_usu': correo,
      'nombre_sub': nombre,
    };
  }

  factory SubdeviceModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return SubdeviceModel(
      id: doc.id,
      codigo: doc['codigo_sub'],
      correo: doc['correo_usu'],
      nombre: doc['nombre_sub'],
    );
  }
}