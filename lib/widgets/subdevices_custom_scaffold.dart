import 'package:flutter/material.dart';

class SubdevicesCustomScaffold extends StatefulWidget {
  const SubdevicesCustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  State<SubdevicesCustomScaffold> createState() =>
      _SubdevicesCustomScaffoldState();
}

class _SubdevicesCustomScaffoldState extends State<SubdevicesCustomScaffold> {
  @override
  Widget build(BuildContext context) {
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
    );
  }
}
