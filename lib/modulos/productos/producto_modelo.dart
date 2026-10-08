import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;
  final DateTime? fechaCreacion;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    this.fechaCreacion,
  });

  factory Producto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Producto(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] as num? ?? 0.0).toDouble(),
      categoria: data['categoria'] ?? 'Sin categoría',
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'fechaCreacion': fechaCreacion ?? FieldValue.serverTimestamp(),
    };
  }
}