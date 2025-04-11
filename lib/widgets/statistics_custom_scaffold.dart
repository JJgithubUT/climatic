import 'package:climatic/screens/profile_screen.dart';
import 'package:climatic/screens/statistics_screen.dart';
import 'package:climatic/screens/thermostatus_screen.dart';
import 'package:climatic/widgets/custom_transitions.dart';
import 'package:flutter/material.dart';

class StatisticsCustomScaffold extends StatefulWidget {
  const StatisticsCustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  State<StatisticsCustomScaffold> createState() =>
      _StatisticsCustomScaffoldState();
}

class _StatisticsCustomScaffoldState extends State<StatisticsCustomScaffold>
    with SingleTickerProviderStateMixin {
  var _selectedIndex = 1;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

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
                  slideFromLeftRoute(const StatisticsScreen()),
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
