import 'package:flutter/material.dart';
import 'package:climatic/screens/signup_screen.dart';
import 'package:climatic/widgets/custom_scaffold.dart';
import 'package:climatic/services/cloud_firestore_service.dart';
import 'package:climatic/services/validation_service.dart';

import '../theme/theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValidationService _validationService = ValidationService();

  @override
  void initState() {
    super.initState();
    autoLogUser(); // Llama al método que maneja el trabajo asincrónico
  }

  Future<void> autoLogUser() async {
    // ignore: avoid_print
    print('Estamos ahora en Login Screen');
    var localUser = await CloudFirestoreService().getLocalUser();

    if (localUser == null) {
      // ignore: avoid_print
      print('Usuario local nulo');
      return;
    }

    // ignore: avoid_print
    print(localUser['emailUsuario']);

    String? email = localUser['emailUsuario'];
    String? password = localUser['contraseniaUsuario'];

    if (email != null && password != null) {
      // Si hay datos de usuario guardados, intentar iniciar sesión automáticamente
      // ignore: use_build_context_synchronously
      await CloudFirestoreService().logIn(
        context: context,
        email: email,
        password: password,
      );
      _emailController.text = email;
      _passwordController.text = password;
    } else {
      // Si no se puede obtener email o contraseña, no se hace nada
      await CloudFirestoreService().showSnapMessage(
        // ignore: use_build_context_synchronously
        context: context,
        message: "No se pudo encontrar un usuario guardado.",
        duration: Duration(seconds: 4),
      );
    }
  }

  Future<void> _logIn() async {
    setState(() {});

    if ( _validationService.isValidEmail(_emailController.text) &&
        _validationService.isValidPassword(_passwordController.text) ) {
      try {
        await CloudFirestoreService().logIn(
          context: context,
          email: _emailController.text,
          password: _passwordController.text,
        );
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  void cleanFields() {
    _emailController.text = '';
    _passwordController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
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
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Bienvenido de nuevo',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
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
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        obscuringCharacter: '*',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Recuerdame',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Text(
                              'Contraseña olvidada?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignInKey.currentState!.validate() &&
                                rememberPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Procesando solicitud'),
                                ),
                              );

                              // ignore: avoid_print
                              print(
                                "Antes de _logIn(); en signin_screen.dart!!!!",
                              );

                              _logIn();

                              // ignore: avoid_print
                              print(
                                "Después de _logIn(); en signin_screen.dart!!!!",
                              );
                            } else if (!rememberPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, acepta el procesamiento de datos personales',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Sign up'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      /* Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Ingresar con',
                              style: TextStyle(color: Colors.black45),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.facebook),
                          Icon(Icons.facebook),
                          Icon(Icons.facebook),
                          Icon(Icons.facebook),
                        ],
                      ),
                      const SizedBox(height: 25.0), */
                      // don't have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No tienes una cuenta? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
