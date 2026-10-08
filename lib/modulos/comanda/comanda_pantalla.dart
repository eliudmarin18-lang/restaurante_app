import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

double _toDbl(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class ComandaPantalla extends StatefulWidget {
  const ComandaPantalla({super.key});

  @override
  State<ComandaPantalla> createState() => _ComandaPantallaState();
}

class _ComandaPantallaState extends State<ComandaPantalla> {
  String _tipoOrden = 'mesa';
  String _mesaSeleccionada = 'Mesa 1';
  String? _comandaIdActual;
  bool _cargandoMesa = false;

  final _notasCtrl = TextEditingController();
  final List<Map<String, dynamic>> _items = [];

  double get _total => _items.fold(
      0.0, (acc, item) => acc + (_toDbl(item['precio']) * (item['cantidad'] as int)));

  @override
  void initState() {
    super.initState();
    _cargarMesa();
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarMesa() async {
    if (_tipoOrden != 'mesa') {
      return setState(() {
        _comandaIdActual = null;
        _items.clear();
      });
    }
    setState(() => _cargandoMesa = true);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('comandas')
          .where('mesa', isEqualTo: _mesaSeleccionada)
          .where('estado', isEqualTo: 'abierta')
          .limit(1)
          .get();

      setState(() {
        _cargandoMesa = false;
        if (snap.docs.isEmpty) {
          _comandaIdActual = null;
          _items.clear();
          return;
        }
        _comandaIdActual = snap.docs.first.id;
        final rawItems = snap.docs.first['items'] as List? ?? [];
        _items
          ..clear()
          ..addAll(rawItems.map((i) => {
                'nombre': i['nombre']?.toString() ?? '',
                'precio': _toDbl(i['precio']),
                'cantidad': (i['cantidad'] as int?) ?? 1,
              }));
      });
    } catch (e) {
      setState(() => _cargandoMesa = false);
      debugPrint('Error al cargar mesa: $e');
    }
  }

  Future<void> _procesarPedido({required bool esCobro}) async {
    if (_items.isEmpty) return;
    final db = FirebaseFirestore.instance;
    final payload = <String, dynamic>{
      'origen': _tipoOrden,
      'mesa': _tipoOrden == 'mesa' ? _mesaSeleccionada : 'N/A',
      'estado': esCobro ? 'pagada' : 'abierta',
      'items': _items,
      'total': _total,
      'notas_cliente': _notasCtrl.text.trim(),
      if (esCobro)
        'fecha_pago': FieldValue.serverTimestamp()
      else
        'ultima_actualizacion': FieldValue.serverTimestamp(),
    };

    try {
      if (_comandaIdActual != null) {
        await db.collection('comandas').doc(_comandaIdActual).update(payload);
      } else {
        payload['fecha_creacion'] = FieldValue.serverTimestamp();
        final doc = await db.collection('comandas').add(payload);
        if (_tipoOrden == 'mesa' && !esCobro) _comandaIdActual = doc.id;
      }

      if (_tipoOrden == 'mesa') {
        final numMesa = _mesaSeleccionada.replaceAll('Mesa ', '').trim();
        final q = await db
            .collection('mesas')
            .where('numero', isEqualTo: numMesa)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          await q.docs.first.reference.update({'estado': esCobro ? 'libre' : 'ocupada'});
        }
      }

      _msg(
        esCobro ? 'Cobrado: \$${_total.toStringAsFixed(2)}' : 'Guardado en $_mesaSeleccionada',
        Colors.green,
      );

      if (esCobro) {
        setState(() {
          _items.clear();
          _comandaIdActual = null;
          _notasCtrl.clear();
        });
      }
    } catch (e) {
      _msg('Error: $e', Colors.red);
    }
  }

  void _msg(String txt, Color col) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(txt), backgroundColor: col),
    );
  }

  void _agregar(Map<String, dynamic> prod) {
    setState(() {
      final nombre = prod['nombre']?.toString() ?? '';
      final precio = _toDbl(prod['precio']);
      final idx = _items.indexWhere((i) => i['nombre'] == nombre);
      if (idx >= 0) {
        _items[idx]['cantidad'] = (_items[idx]['cantidad'] as int) + 1;
      } else {
        _items.add({'nombre': nombre, 'precio': precio, 'cantidad': 1});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final esWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comanda y POS'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // PANEL IZQUIERDO: Resumen de Comanda
          Expanded(
            flex: esWide ? 2 : 4,
            child: Container(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'mesa',
                        label: Text('Mesa', style: TextStyle(fontSize: 11)),
                        icon: Icon(Icons.table_restaurant, size: 14),
                      ),
                      ButtonSegment(
                        value: 'llevar',
                        label: Text('Llevar', style: TextStyle(fontSize: 11)),
                        icon: Icon(Icons.takeout_dining, size: 14),
                      ),
                    ],
                    selected: {_tipoOrden},
                    onSelectionChanged: (v) {
                      setState(() => _tipoOrden = v.first);
                      _cargarMesa();
                    },
                  ),
                  const SizedBox(height: 6),
                  if (_tipoOrden == 'mesa') ...[
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('mesas').snapshots(),
                      builder: (ctx, snap) {
                        List<String> opts = ['Mesa 1'];
                        if (snap.hasData && snap.data!.docs.isNotEmpty) {
                          opts = snap.data!.docs.map((d) {
                            final raw = d['numero']?.toString() ?? d.id;
                            return raw.toLowerCase().startsWith('mesa') ? raw : 'Mesa $raw';
                          }).toList();
                        }
                        final val = opts.contains(_mesaSeleccionada) ? _mesaSeleccionada : opts.first;
                        return DropdownButtonFormField<String>(
                          initialValue: val,
                          decoration: const InputDecoration(
                            labelText: 'Mesa',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          items: opts
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m, style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _mesaSeleccionada = v);
                              _cargarMesa();
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                  TextField(
                    controller: _notasCtrl,
                    decoration: InputDecoration(
                      labelText: _tipoOrden == 'llevar' ? 'Cliente / Dir' : 'Notas',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Divider(),
                  Expanded(
                    child: _cargandoMesa
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (ctx, i) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                _items[i]['nombre'].toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              subtitle: Text(
                                '\$${_toDbl(_items[i]['precio']).toStringAsFixed(2)} x ${_items[i]['cantidad']}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: () => setState(() =>
                                        (_items[i]['cantidad'] as int) > 1
                                            ? _items[i]['cantidad'] =
                                                (_items[i]['cantidad'] as int) - 1
                                            : _items.removeAt(i)),
                                  ),
                                  Text('${_items[i]['cantidad']}',
                                      style: const TextStyle(fontSize: 12)),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () => setState(() =>
                                        _items[i]['cantidad'] =
                                            (_items[i]['cantidad'] as int) + 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _items.isEmpty ? null : () => _procesarPedido(esCobro: false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: const Text('GUARDAR', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _items.isEmpty ? null : () => _procesarPedido(esCobro: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: const Text('COBRAR', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          // PANEL DERECHO: Catálogo de Productos
          Expanded(
            flex: esWide ? 3 : 5,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('productos').snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: snap.data!.docs.length,
                  itemBuilder: (ctx, i) {
                    final d = snap.data!.docs[i].data() as Map<String, dynamic>;
                    final nombre = d['nombre']?.toString() ?? '';
                    final precio = _toDbl(d['precio']);
                    return Card(
                      child: InkWell(
                        onTap: () => _agregar(d),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fastfood, color: Colors.deepOrange, size: 22),
                            const SizedBox(height: 2),
                            Text(
                              nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '\$${precio.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}