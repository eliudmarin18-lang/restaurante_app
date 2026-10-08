import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CobroControlador extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> procesarPago({
    required String comandaId,
    required String mesaNumero,
    required double total,
    required String metodoPago,
  }) async {
    await _db.collection('ventas').add({
      'comandaId': comandaId,
      'mesaNumero': mesaNumero,
      'total': total,
      'metodoPago': metodoPago,
      'fecha': FieldValue.serverTimestamp(),
    });

    await _db.collection('comandas').doc(comandaId).update({
      'estado': 'pagado',
    });
  }
}