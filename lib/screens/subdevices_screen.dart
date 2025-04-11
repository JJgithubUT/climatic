import 'package:flutter/material.dart';
import '../models/subdevice_model.dart';
import '../widgets/subdevice_card.dart';
import 'package:climatic/services/cloud_firestore_service.dart';

class SubdevicesScreen extends StatefulWidget {
  const SubdevicesScreen({super.key});

  @override
  State<SubdevicesScreen> createState() => _SubdevicesScreenState();
}

class _SubdevicesScreenState extends State<SubdevicesScreen> {
  List<SubdeviceModel> subdevices = [];
  bool isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.4);
    loadSubdevices();
  }

  Future<void> loadSubdevices() async {
    setState(() {
      isLoading = true; // Set loading state to true initially
    });

    try {
      final stream = await CloudFirestoreService().getSubdevices(context);
      if (stream != null) {
        stream.listen((subdevicesList) {
          setState(() {
            subdevices = subdevicesList; // Update the state with fetched subdevices
            isLoading = false; // Set loading state to false once data is fetched
          });
        });
      } else {
        setState(() {
          isLoading = false; // Set loading to false if no stream is returned
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Set loading to false in case of an error
      });
      CloudFirestoreService().showSnapMessage(
        context: context,
        message: 'Error al cargar dispositivos: ${e.toString()}',
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subdispositivos")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: subdevices.length,
              itemBuilder: (context, index) {
                final subdevice = subdevices[index]; // Obtener el subdispositivo

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                    }

                    final double scale = (1 - (value.abs() * 0.4)).clamp(0.8, 1.2);
                    final double verticalTranslation = (1 - scale) * 50;
                    final double horizontalTranslation = (value.abs() * -40);

                    return GestureDetector(
                      
                      child: Transform.translate(
                        offset: Offset(horizontalTranslation, verticalTranslation),
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: scale.clamp(0.6, 1.0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SubdeviceCard(
                                subdevice: subdevice,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
