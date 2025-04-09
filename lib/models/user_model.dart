import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nombre;
  final String contrasenia;
  final String email;

  UserModel({
    required this.id,
    required this.nombre,
    required this.contrasenia,
    required this.email,
  });

  // Convertir un Usuario a un Mapa
  Map<String, dynamic> toMap() {
    return {
      'nombre_usu': nombre,
      'contrasenia_usu': contrasenia,
      'email_usu': email,
    };
  }

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return UserModel(
      id: doc.id,
      nombre: doc['nombre_usu'],
      contrasenia: doc['contrasenia_usu'],
      email: doc['email_usu']
    );
  }

}