import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServicio {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Método genérico para obtener un stream de cualquier colección
  Stream<QuerySnapshot> obtenerColeccionStream(String nombreColeccion) {
    return db.collection(nombreColeccion).snapshots();
  }
}