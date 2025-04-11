// Device Model
//import 'dart:math';

import 'package:climatic/models/device_model.dart';
// Dynamic device Model
import 'package:climatic/models/dynamic_device_model.dart';
import 'package:climatic/models/history_model.dart';
import 'package:climatic/screens/signin_screen.dart';
import 'package:climatic/screens/welcome_screen.dart';
// Librerías para encriptar
import 'package:climatic/services/cifrado_service.dart';
//import 'package:bcrypt/bcrypt.dart';
// Librerías normales
import 'package:flutter/material.dart';
// Cloud service
import 'package:cloud_firestore/cloud_firestore.dart';
// Clase usuario
import 'package:climatic/models/user_model.dart';
// Autenticación de firebase
import 'package:firebase_auth/firebase_auth.dart';
// Almacenamiento local
import 'package:shared_preferences/shared_preferences.dart';
// Realtime Database
import 'package:firebase_database/firebase_database.dart';
// Screen de termostato
import 'package:climatic/screens/thermostatus_screen.dart';

class CloudFirestoreService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CloudFirestoreService _instance =
      CloudFirestoreService._internal();

  final FirebaseFirestore _cloudFireStore = FirebaseFirestore.instance;

  factory CloudFirestoreService() {
    return _instance;
  }

  CloudFirestoreService._internal();

  /// -----------------
  ///// Funciones complementarias /////
  /// -----------------

  Future<void> saveLocalUser({
    required String email,
    required String password,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('emailUsuario', email);
    prefs.setString('contraseniaUsuario', password);
  }

  Future<Map<String, String>?> getLocalUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('emailUsuario');
    final contrasenia = prefs.getString('contraseniaUsuario');

    if (contrasenia == null || email == null) {
      return null;
    }

    // ignore: avoid_print
    print('Usuario local: $email, $contrasenia');

    // Devolver mapa del usuario local encontrado
    return {'emailUsuario': email, 'contraseniaUsuario': contrasenia};
  }

  /* Future<void> saveLocalDeviceId(String idDevice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('idDevice', idDevice);
    // ignore: avoid_print
    print('Código del dispositivo guardado: $idDevice');
  }

  Future<String?> getLocalDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idDevice = prefs.getString('idDevice');

    if (idDevice == null) {
      // ignore: avoid_print
      print('No se encontró código de dispositivo.');
      return null;
    }

    // ignore: avoid_print
    print('Código del dispositivo recuperado: $idDevice');
    return idDevice;
  } */

  Future<void> cleanLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.clear();
      // ignore: avoid_print
      print('Datos locales eliminados correctamente.');
    } catch (e) {
      // ignore: avoid_print
      print('Error al limpiar los datos locales: $e');
    }
  }

  Future<UserModel?> getRemoteUser() async {
    var localUser = await getLocalUser();
    if (localUser == null) {
      // ignore: avoid_print
      print('.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.--');
      // ignore: avoid_print
      print('No hay usuario local guardado.');
      // ignore: avoid_print
      print('.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.');
      return null;
    }

    try {
      final querySnapshot =
          await _cloudFireStore
              .collection('usuarios')
              .where('email_usu', isEqualTo: localUser['emailUsuario'])
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        // ignore: avoid_print
        print('.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.');
        // ignore: avoid_print
        print('Usuario remoto no encontrado.');
        // ignore: avoid_print
        print('.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.');
        return null;
      }

      final userData = querySnapshot.docs.first.data();

      return UserModel(
        id: querySnapshot.docs.first.id,
        nombre: userData['nombre_usu']?.toString() ?? '',
        email: userData['email_usu']?.toString() ?? '',
        contrasenia: AESHelper.decryptPassword(
          userData['contrasenia_usu']!.toString(),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.');
      // ignore: avoid_print
      print('Error al obtener usuario remoto: $e');
      // ignore: avoid_print
      print('.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.');
      return null;
    }
  }

  Future<void> showSnapMessage({
    required BuildContext context,
    required String message,
    required Duration duration,
    Color color = Colors.redAccent,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration,
      ),
    );
  }

  /// -----------------
  ///// Servicios /////
  /// -----------------

  ///// Dispositivos /////

  Future<void> insertDevice(DeviceModel device) async {
    await _cloudFireStore.collection('dispositivos').add(device.toMap());
  }

  Future<DeviceModel?> getDevice(BuildContext context) async {
    var localUser = await getLocalUser();

    if (localUser == null) {
      // ignore: avoid_print
      print('No se encontró la id del dispositivo local.');
      return null;
    }

    // ignore: avoid_print
    print("Buscando usuario con el correo");

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('dispositivos')
              .where('correo_usu', isEqualTo: localUser['emailUsuario'])
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        // ignore: avoid_print
        print("No se encontró ningún dispositivo.");
        return null;
      }

      final deviceData = querySnapshot.docs.first.data();

      final gDvice = DeviceModel(
        id: querySnapshot.docs.first.id,
        codigo: deviceData['codigo_dis'] as String? ?? '',
        correo: deviceData['correo_usu'] as String? ?? '',
        estado: (deviceData['estado_dis'] as bool?) ?? false,
        nombre: deviceData['nombre_dis'] as String? ?? 'Desconocido',
      );

      // ignore: avoid_print
      print(
        'getDevice() || ${gDvice.id} / ${gDvice.codigo} / ${gDvice.correo} / ${gDvice.estado} / ${gDvice.nombre} /',
      );

      return DeviceModel(
        id: querySnapshot.docs.first.id,
        codigo: deviceData['codigo_dis'] as String? ?? '',
        correo: deviceData['correo_usu'] as String? ?? '',
        estado: (deviceData['estado_dis'] as bool?) ?? false,
        nombre: deviceData['nombre_dis'] as String? ?? 'Desconocido',
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener el dispositivo: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener dispositivo: $e'),
            duration: Duration(seconds: 5),
          ),
        );
      }

      return null;
    }
  }

  Future<void> updateDevice({
    required DeviceModel device,
    required BuildContext context,
  }) async {
    try {
      await _cloudFireStore.collection('dispositivos').doc(device.id).update({
        'codigo_dis': device.codigo,
        'nombre_dis': device.nombre,
      });
    } catch (e) {
      // ignore: avoid_print
      print('CloudService || updateDevice(): Error: ${e.toString()}');
      showSnapMessage(
        // ignore: use_build_context_synchronously
        context: context,
        message: 'Error al actualizar dispositivo: ${e.toString()}',
        duration: Duration(seconds: 5),
      );
    }
  }

  // No se elimina ninguna dispositivo, solo se pueden seguir asignando

  // El insertar dispositivo en tiempo real ocurre desde el dispositivo IOT,no se eliminan.
  //Se conecta el dispositivo del usuario a los ya existentes de la firestore realtime database

  Stream<DynamicDeviceModel?> getDynamicDevice(String deviceCode) {
    return _dbRef.child(deviceCode).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return DynamicDeviceModel(
          tempActual: (data['temp_actual_dis'] as num).toDouble(),
          tempObjetivo: (data['temp_objetivo_dis'] as num).toDouble(),
        );
      } else {
        return null; // Si no hay datos, retorna null
      }
    });
  }

  Future<void> updateDynamicDevice(
    String deviceCode,
    double tempObjetivo,
    BuildContext context,
  ) async {
    try {
      await _dbRef.child(deviceCode).update({
        'temp_objetivo_dis': tempObjetivo,
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error al actualizar el dispositivo dinámico: $e');
      showSnapMessage(
        // ignore: use_build_context_synchronously
        context: context,
        message: 'Error al actualizar el dispositivo dinámico: $e',
        duration: Duration(seconds: 5),
      );
    }
  }

  ///// Usuarios /////

  Future<void> signUp({
    required BuildContext context,
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      // Encriptar contraseña solo para guardar en Firestore (NO para Firebase Auth)
      String hashedPassword = AESHelper.encryptPassword(password);

      // Crear usuario en Firebase Authentication (con contraseña sin encriptar)
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          print('Enviando correo de verificación a: ${user.email}');
          await user.sendEmailVerification();
          print('Correo de verificación enviado.');
        }

        // Crear objeto de usuario
        UserModel newUser = UserModel(
          id: user.uid,
          nombre: nombre,
          contrasenia: hashedPassword, // Aquí sí va cifrada
          email: email,
        );

        // Guardar usuario en Firestore
        await _cloudFireStore.collection('usuarios').add(newUser.toMap());

        // Guardar dispositivo
        await insertDevice(
          DeviceModel(
            id: '',
            codigo: '',
            correo: email,
            estado: false,
            nombre: '',
          ),
        );

        if (context.mounted) {
          await showSnapMessage(
            context: context,
            message:
                "Usuario registrado con éxito. Verifique su correo electrónico.",
            duration: Duration(seconds: 10),
            color: Colors.green,
          );
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = '';
      if (e.code == 'weak-password') {
        msg = 'La contraseña proporcionada es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'Ya existe una cuenta con ese correo.';
        if (context.mounted) Navigator.pop(context);
      } else {
        msg = 'Error: ${e.message}';
      }
      if (context.mounted) {
        await showSnapMessage(
          context: context,
          message: msg,
          duration: Duration(seconds: 10),
        );
      }
    }
  }

  Future<void> logIn({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Usar contraseña sin encriptar para login en Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          await showSnapMessage(
            context: context,
            message: "Por favor, verifica tu correo antes de iniciar sesión.",
            duration: Duration(seconds: 5),
            color: Colors.orange,
          );
          return;
        }

        // Obtener los datos del usuario desde Firestore
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await _cloudFireStore
                .collection('usuarios')
                .where('email_usu', isEqualTo: email)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          UserModel loggedUser = UserModel.fromDocumentSnapshot(
            querySnapshot.docs.first,
          );

          await showSnapMessage(
            context: context,
            message: "Bienvenido, ${loggedUser.nombre}!",
            duration: Duration(seconds: 3),
            color: Colors.green,
          );

          print(
            '/////////id del usuario en el logIn para guardar: ${loggedUser.id}',
          );

          saveLocalUser(
            email: email,
            password: password,
          ); // guardar local sin cifrar

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ThermostatusScreen()),
          );
        } else {
          await showSnapMessage(
            context: context,
            message: "Error: No se encontraron datos del usuario.",
            duration: Duration(seconds: 5),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = '';
      if (e.code == 'user-not-found') {
        msg = 'No existe una cuenta con este correo.';
      } else if (e.code == 'wrong-password') {
        msg = 'Contraseña incorrecta.';
      } else {
        msg = 'Error: ${e.message}';
      }

      await showSnapMessage(
        context: context,
        message: msg,
        duration: Duration(seconds: 5),
      );
    }
  }

  Future<void> logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Cerrar sesión en Firebase Auth
      CloudFirestoreService().cleanLocalStorage(); // Limpiar usuario local

      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (Route<dynamic> route) => false,
      );

      // ignore: avoid_print
      print("Usuario cerró sesión correctamente.");
      showSnapMessage(
        // ignore: use_build_context_synchronously
        context: context,
        message: "Usuario cerró sesión correctamente.",
        duration: Duration(seconds: 5),
        color: Colors.yellow,
      );
    } catch (e) {
      // ignore: avoid_print
      print("Error al cerrar sesión: $e");
      showSnapMessage(
        // ignore: use_build_context_synchronously
        context: context,
        message: "Error al cerrar sesión: $e",
        duration: Duration(seconds: 5),
      );
    }
  }

  Future<void> updateUser(UserModel user, BuildContext context) async {
    try {
      // Encriptación de la nueva contraseña
      String hashedPassword = AESHelper.encryptPassword(user.contrasenia);

      // Actualizar el usuario en Firebase Authentication
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Actualizar la contraseña en Firebase Authentication si es necesario
        await firebaseUser.updatePassword(user.contrasenia);

        // ignore: avoid_print
        print('updateUser() || id: ${user.id}');

        // Actualizar datos del usuario en Firestore
        await _cloudFireStore.collection('usuarios').doc(user.id).update({
          'nombre_usu': user.nombre,
          'contrasenia_usu':
              hashedPassword, // Actualizar la contraseña encriptada
        });

        // Mostrar mensaje de éxito
        // ignore: avoid_print
        print('//// Usuario actualizado con éxito.');
        showSnapMessage(
          // ignore: use_build_context_synchronously
          context: context,
          message: "Usuario actualizado con éxito.",
          duration: Duration(seconds: 5),
          color: Colors.green,
        );

        // Navegar l termostato
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => ThermostatusScreen()),
        );
      } else {
        throw Exception('Usuario no autenticado.');
      }
    } catch (e) {
      // Manejo de errores
      // ignore: avoid_print
      print('//// Error al actualizar el usuario: $e');
      showSnapMessage(
        // ignore: use_build_context_synchronously
        context: context,
        message: "Error al actualizar el usuario: $e",
        duration: Duration(seconds: 10),
      );
    }
  }

  ///// ListDevices /////

  /// Consulta los registros de la colección "historial" que se encuentren entre [start] y [end]
  /// y correspondan al código del dispositivo [codigo].
  /// La consulta ordena los datos en base a `fecha_his` en orden ascendente.
  Future<List<HistoryModel>> getHistoryForPeriodAndCode(
    DateTime start,
    DateTime end,
    String codigo,
  ) async {
    // Convertimos las fechas a Timestamps para la consulta en Firestore
    final startTimestamp = Timestamp.fromDate(start);
    final endTimestamp = Timestamp.fromDate(end);

    QuerySnapshot snapshot =
        await _cloudFireStore
            .collection('historial')
            .where(
              'codigo_his',
              isEqualTo: codigo,
            ) // Filtramos por código del dispositivo
            .where('fecha_his', isGreaterThanOrEqualTo: startTimestamp)
            .where('fecha_his', isLessThanOrEqualTo: endTimestamp)
            .orderBy('fecha_his', descending: false) // Ordenamos por fecha
            .get();

    // Mapear cada documento al modelo HistoryModel
    return snapshot.docs.map((doc) => HistoryModel.fromDocument(doc)).toList();
  }
  
}
