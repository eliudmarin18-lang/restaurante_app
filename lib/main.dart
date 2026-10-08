import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/temas.dart';
import 'firebase_options.dart';
import 'modulos/inicio/inicio_pantalla.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MiAppPOS());
}

class MiAppPOS extends StatelessWidget {
  const MiAppPOS({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modoTemaNotifier,
      builder: (context, modoActual, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'POS Restaurante',
          theme: AppTemas.temaClaro,
          darkTheme: AppTemas.temaOscuro,
          themeMode: modoActual,
          home: const InicioPantalla(),
        );
      },
    );
  }
}