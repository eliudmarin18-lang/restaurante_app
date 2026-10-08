import 'package:cloud_firestore/cloud_firestore.dart';

class ItemComanda {
  final String idProducto;
  final String nombre;
  final double precio;
  int cantidad;
  String? notas;

  ItemComanda({
    required this.idProducto,
    required this.nombre,
    required this.precio,
    this.cantidad = 1,
    this.notas,
  });

  double get subtotal => precio * cantidad;

  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'notas': notas ?? '',
      'subtotal': subtotal,
    };
  }

  factory ItemComanda.fromMap(Map<String, dynamic> map) {
    return ItemComanda(
      idProducto: map['idProducto'] ?? '',
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] as num? ?? 0).toDouble(),
      cantidad: map['cantidad'] as int? ?? 1,
      notas: map['notas'],
    );
  }
}

class Comanda {
  final String? id;
  final String numeroMesa;
  final List<ItemComanda> items;
  final String estado;
  final DateTime? fechaCreacion;

  Comanda({
    this.id,
    required this.numeroMesa,
    required this.items,
    this.estado = 'pendiente',
    this.fechaCreacion,
  });

  double get total => items.fold(0.0, (acumulado, item) => acumulado + item.subtotal);

  Map<String, dynamic> toMap() {
    return {
      'numeroMesa': numeroMesa,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'estado': estado,
      'fechaCreacion': fechaCreacion ?? FieldValue.serverTimestamp(),
    };
  }

  factory Comanda.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsList = (data['items'] as List<dynamic>? ?? [])
        .map((i) => ItemComanda.fromMap(i as Map<String, dynamic>))
        .toList();

    return Comanda(
      id: doc.id,
      numeroMesa: data['numeroMesa'] ?? '1',
      items: itemsList,
      estado: data['estado'] ?? 'pendiente',
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate(),
    );
  }
}