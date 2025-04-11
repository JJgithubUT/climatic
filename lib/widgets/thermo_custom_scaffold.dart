import 'package:climatic/screens/profile_screen.dart';
import 'package:climatic/screens/statistics_screen.dart';
import 'package:climatic/screens/thermostatus_screen.dart';
import 'package:climatic/services/conectivity_service.dart';
import 'package:climatic/widgets/custom_transitions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ThermoCustomScaffold extends StatefulWidget {
  const ThermoCustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  State<ThermoCustomScaffold> createState() => _ThermoCustomScaffoldState();
}

class _ThermoCustomScaffoldState extends State<ThermoCustomScaffold>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  var _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _initConnectivity();
    _connectivityService.connectivityStream.listen((resultList) {
      // Aquí tomamos el primer valor de la lista
      final ConnectivityResult result =
          resultList.isNotEmpty ? resultList[0] : ConnectivityResult.none;
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });

    // Configuración de la animación
    _controller = AnimationController(
      duration: const Duration(seconds: 20), // Duración de toda la secuencia
      vsync: this,
    )..repeat(reverse: false); // Animación infinita

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: Color.fromARGB(255, 14, 28, 50), // Inicio
          end: Colors.purple, // Transición a morado
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.purple, // Morado
          end: Colors.orange, // Transición a naranja
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.orange, // Naranja
          end: Colors.blue, // Transición a azul
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.blue, // Azul
          end: Colors.green, // Transición a verde
        ),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.green, // Verde
          end: Color.fromARGB(255, 14, 28, 50), // Regresa al color inicial
        ),
        weight: 1.0,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    bool isConnected = await _connectivityService.checkConnection();
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading:
                false, // 🔥 Esto elimina el botón de regresar
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 16.0,
                ), // Ajusta el valor según tu preferencia
                child: Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              Image.asset(
                'assets/images/dark_theme.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              SafeArea(child: widget.child!),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: _colorAnimation.value, // Fondo animado RGB
            selectedItemColor: Colors.white, // Íconos seleccionados en blanco
            unselectedItemColor:
                Colors.white70, // Íconos no seleccionados con opacidad
            currentIndex: _selectedIndex,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.thermostat),
                label: 'Termostato',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Historial',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Cuenta',
              ),
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                Navigator.of(context).pushReplacement(
                  slideFromLeftRoute(const ThermostatusScreen()),
                );
              } else if (index == 1) {
                Navigator.of(context).pushReplacement(
                  slideFromRightRoute(const StatisticsScreen()),
                );
              } else if (index == 2) {
                Navigator.of(context).pushReplacement(
                  slideFromRightRoute(const ProfileScreen()),
                );
              }
            },
          ),
        );
      },
    );
  }
}
