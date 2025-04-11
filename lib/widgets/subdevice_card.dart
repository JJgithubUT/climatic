import 'dart:math';
import 'package:flutter/material.dart';
import '../models/subdevice_model.dart';

class SubdeviceCard extends StatelessWidget {
  final SubdeviceModel subdevice;

  const SubdeviceCard({super.key, required this.subdevice});

  // Calcula una duración de ciclo más larga en función del id (si es numérico) o fija.
  Duration getCycleDuration() {
    try {
      final intId = int.parse(subdevice.id);
      // Ciclo de 8 a 10 segundos.
      return Duration(seconds: 8 + (intId % 3));
    } catch (_) {
      return const Duration(seconds: 9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220, // Altura fija de la tarjeta.
      child: InkWell(
        onTap: () {
          // Evento vacío al tocar la tarjeta; aquí puedes agregar la acción deseada.
        },
        borderRadius: BorderRadius.circular(20),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo animado con la paleta de colores difuminada (efecto gaussiano)
              RgbBackgroundWidget(
                cycleDuration: getCycleDuration(),
              ),
              // Contenido de la tarjeta.
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      subdevice.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Código: ${subdevice.codigo}",
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget que pinta el fondo con un degradado angular animado.
class RgbBackgroundWidget extends StatefulWidget {
  final Duration cycleDuration;

  const RgbBackgroundWidget({Key? key, required this.cycleDuration}) : super(key: key);

  @override
  _RgbBackgroundWidgetState createState() => _RgbBackgroundWidgetState();
}

class _RgbBackgroundWidgetState extends State<RgbBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.cycleDuration)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter:
              _RgbBackgroundPainter(rotation: _controller.value * 360),
        );
      },
    );
  }
}

// CustomPainter que dibuja un fondo continuo usando un SweepGradient con un blur intenso,
// y sobrepone un centro con un RadialGradient para lograr que el centro de la paleta
// esté muy difuminado (efecto gaussiano).
class _RgbBackgroundPainter extends CustomPainter {
  final double rotation; // Rotación en grados.

  _RgbBackgroundPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Paleta de colores fija (puedes modificar estos tonos según tus necesidades).
    final List<Color> colors = [
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.blue, // Se repite para cerrar el ciclo.
    ];

    // Creamos el SweepGradient para toda la paleta.
    final sweepGradient = SweepGradient(
      colors: colors,
      stops: const [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
      transform: GradientRotation(rotation * pi / 180),
    );

    // Pintamos la paleta con un blur intensificado (efecto gaussiano).
    final paint = Paint()
      ..shader = sweepGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(center, radius, paint);

    // Sobreponemos un RadialGradient en el centro para que el área central sea más difuminada.
    final radialGradient = RadialGradient(
      colors: [
        Colors.white,
        Colors.white.withOpacity(0.0)
      ],
      stops: const [0.0, 1.0],
    );

    final radialPaint = Paint()
      ..shader = radialGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.5),
      )
      ..blendMode = BlendMode.softLight;
    
    canvas.drawCircle(center, radius * 0.5, radialPaint);
  }

  @override
  bool shouldRepaint(covariant _RgbBackgroundPainter oldDelegate) => true;
}
