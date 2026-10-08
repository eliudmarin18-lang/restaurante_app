import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../productos/producto_modelo.dart';
import 'comanda_modelo.dart';

class ComandaControlador extends ChangeNotifier {
  final CollectionReference _comandasCollection =
      FirebaseFirestore.instance.collection('comandas');

  String _mesaSeleccionada = 'Mesa 1';
  final List<ItemComanda> _itemsActuales = [];

  String get mesaSeleccionada => _mesaSeleccionada;
  List<ItemComanda> get itemsActuales => List.unmodifiable(_itemsActuales);
  
  double get totalActual =>
      _itemsActuales.fold(0.0, (acumulado, item) => acumulado + item.subtotal);

  void cambiarMesa(String nuevaMesa) {
    _mesaSeleccionada = nuevaMesa;
    notifyListeners();
  }

  void agregarProducto(Producto producto) {
    final index =
        _itemsActuales.indexWhere((item) => item.idProducto == producto.id);
    if (index >= 0) {
      _itemsActuales[index].cantidad++;
    } else {
      _itemsActuales.add(
        ItemComanda(
          idProducto: producto.id,
          nombre: producto.nombre,
          precio: producto.precio,
        ),
      );
    }
    notifyListeners();
  }

  void removerProducto(int index) {
    if (_itemsActuales[index].cantidad > 1) {
      _itemsActuales[index].cantidad--;
    } else {
      _itemsActuales.removeAt(index);
    }
    notifyListeners();
  }

  void limpiarComanda() {
    _itemsActuales.clear();
    notifyListeners();
  }

  Future<void> enviarACocina() async {
    if (_itemsActuales.isEmpty) return;

    final comanda = Comanda(
      numeroMesa: _mesaSeleccionada,
      items: _itemsActuales,
      estado: 'en_preparacion',
    );

    await _comandasCollection.add(comanda.toMap());
    limpiarComanda();
  }
}