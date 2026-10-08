import 'package:cloud_firestore/cloud_firestore.dart';

class Mesa {
  final String id;
  final String numero;
  final String estado; // 'libre', 'ocupada', 'reservada'
  final int capacidad;

  Mesa({
    required this.id,
    required this.numero,
    this.estado = 'libre',
    required this.capacidad,
  });

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'estado': estado,
      'capacidad': capacidad,
    };
  }

  factory Mesa.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mesa(
      id: doc.id,
      numero: data['numero'] ?? '',
      estado: data['estado'] ?? 'libre',
      capacidad: data['capacidad'] as int? ?? 4,
    );
  }
}