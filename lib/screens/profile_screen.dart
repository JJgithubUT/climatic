import 'package:climatic/models/user_model.dart';
import 'package:climatic/services/cloud_firestore_service.dart';
import 'package:climatic/services/validation_service.dart';
import 'package:climatic/theme/theme.dart';
import 'package:climatic/widgets/profile_custom_scaffold.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  // ignore: prefer_final_fields
  String _nombreUsuarioTitulo = '';
  bool _obscureText = true;
  UserModel? _user;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValidationService _validationService = ValidationService();

  @override
  void initState() {
    super.initState();
    _getRemoteUser();
  }

  Future<void> _getRemoteUser() async {
    _user = await CloudFirestoreService().getRemoteUser();

    if (_user != null) {
      _idController.text = _user?.id ?? '';
      _nameController.text = _user?.nombre ?? '';
      _emailController.text = _user?.email ?? '';
      _passwordController.text = _user?.contrasenia ?? '';
      setState(() {
        _nombreUsuarioTitulo = _nameController.text;
      });
    }
  }

  Future<void> _updateUser() async {
    try {
      // Lógica de la actualización
      if (_nameController.text != '' &&
          _emailController.text != '' &&
          _passwordController.text != '' &&
          ValidationService().isValidName(_nameController.text) &&
          ValidationService().isValidEmail(_emailController.text) &&
          ValidationService().isValidPassword(_passwordController.text)) {
        // Si los datos a enviar no son nulos, continuar
        final userToUpdate = UserModel(
          id: _user!.id,
          nombre: _nameController.text,
          email: _emailController.text,
          contrasenia: _passwordController.text,
        );

        await CloudFirestoreService().updateUser(userToUpdate, context);
      } else {
        _showSnackBar('Campos no validos.');
      }
    } catch (e) {
      setState(() {});
      _showSnackBar('Error al actualizar el usuario.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /* Future<void> _logOut() async {
    CloudFirestoreService().logOut(context);
  } */

  @override
  Widget build(BuildContext context) {
    return ProfileCustomScaffold(
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
              child: SingleChildScrollView(

                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          _nombreUsuarioTitulo.isNotEmpty
                              ? "¡Hola, $_nombreUsuarioTitulo!"
                              : "Bienvenido a Climatic",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            color: lightColorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      // full name
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa un nombre completo';
                          }
                          if (!_validationService.isValidName(
                            _nameController.text,
                          )) {
                            return 'Nombre menor a 10 o mayor 50 caracteres';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          hintText: 'Ingresa tu nombre completo',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      // email
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa un correo';
                          }
                          if (!_validationService.isValidEmail(
                            _emailController.text,
                          )) {
                            return 'Correo no válido';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Ingresa tu correo',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      // password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        obscuringCharacter: '*',
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa una contraseña';
                          }
                          if (!_validationService.isValidPassword(
                            _passwordController.text,
                          )) {
                            return 'Contraseña no válida';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Ingresa tu contraseña',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Procesando solicitud'),
                                ),
                              );

                              _updateUser();
                            }
                          },
                          child: const Text('Actualizar mi usuario'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    /* return ProfileCustomScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          padding: const EdgeInsets.only(top: 80, bottom: 30),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF59A5D8).withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    _nombreUsuarioTitulo.isNotEmpty
                        ? "¡Hola, $_nombreUsuarioTitulo!"
                        : "Bienvenido a Climatic",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF91E5F6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Color(0xFF84D2F6)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color(0xFF84D2F6)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Color(0xFF84D2F6)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color(0xFF386FA4),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF386FA4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    onPressed: _updateUser,
                    child:
                        const Text("Guardar", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF133C55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThermostatusScreen(),
                        ),
                      );
                    },
                    child:
                        const Text("Cancelar", style: TextStyle(color: Colors.white)),
                  ),
                  if (_errorMessage != null) const SizedBox(height: 10),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ); */
  }
}
