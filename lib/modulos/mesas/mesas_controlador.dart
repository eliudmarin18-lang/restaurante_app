import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mesas_modelo.dart';

class MesasControlador extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Mesa>> obtenerMesas() {
    return _db.collection('mesas').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Mesa.fromFirestore(doc)).toList(),
        );
  }

  Future<void> cambiarEstadoMesa(String mesaId, String nuevoEstado) async {
    await _db.collection('mesas').doc(mesaId).update({'estado': nuevoEstado});
  }
}