import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CobrarPantalla extends StatefulWidget {
  final String mesaNombre;
  final double total;
  final List<Map<String, dynamic>> items;

  const CobrarPantalla({
    super.key,
    required this.mesaNombre,
    required this.total,
    required this.items,
  });

  @override
  State<CobrarPantalla> createState() => _CobrarPantallaState();
}

class _CobrarPantallaState extends State<CobrarPantalla> {
  String _metodoPago = 'efectivo';
  final TextEditingController _montoRecibidoController = TextEditingController();
  double _montoRecibido = 0;

  @override
  void initState() {
    super.initState(); // <--- Corregido: punto y coma en lugar de bloque {}
    _montoRecibido = widget.total;
    _montoRecibidoController.text = widget.total.toStringAsFixed(2);
  }

  double get _cambio => _montoRecibido > widget.total ? _montoRecibido - widget.total : 0.0;

  Future<void> _confirmarCobro() async {
    try {
      await FirebaseFirestore.instance.collection('ventas').add({
        'mesa': widget.mesaNombre,
        'total': widget.total,
        'metodoPago': _metodoPago,
        'montoRecibido': _montoRecibido,
        'cambio': _cambio,
        'fecha': FieldValue.serverTimestamp(),
        'items': widget.items,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago registrado correctamente')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar cobro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cobrar - ${widget.mesaNombre}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Cantidad a Pagar', style: TextStyle(color: Colors.grey)),
                          FittedBox(
                            child: Text(
                              '\$${widget.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Efectivo')),
                            selected: _metodoPago == 'efectivo',
                            avatar: const Icon(Icons.money),
                            selectedColor: Colors.green.shade200,
                            onSelected: (val) {
                              if (val) setState(() => _metodoPago = 'efectivo');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Tarjeta')),
                            selected: _metodoPago == 'tarjeta',
                            avatar: const Icon(Icons.credit_card),
                            selectedColor: Colors.green.shade200,
                            onSelected: (val) {
                              if (val) setState(() => _metodoPago = 'tarjeta');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_metodoPago == 'efectivo') ...[
                      TextField(
                        controller: _montoRecibidoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Efectivo recibido',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _montoRecibido = double.tryParse(val) ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [widget.total, 200.0, 500.0].map((monto) {
                          return ActionChip(
                            label: Text('\$${monto.toStringAsFixed(1)}'),
                            onPressed: () {
                              setState(() {
                                _montoRecibido = monto;
                                _montoRecibidoController.text = monto.toStringAsFixed(2);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cambio a devolver:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Flexible(
                              child: FittedBox(
                                child: Text(
                                  '\$${_cambio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total a Cobrar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        FittedBox(
                          child: Text(
                            '\$${widget.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _confirmarCobro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('CONFIRMAR Y COBRAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}