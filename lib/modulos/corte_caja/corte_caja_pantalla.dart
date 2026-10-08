import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CorteCajaPantalla extends StatefulWidget {
  const CorteCajaPantalla({super.key});

  @override
  State<CorteCajaPantalla> createState() => _CorteCajaPantallaState();
}

class _CorteCajaPantallaState extends State<CorteCajaPantalla> {
  DateTime _fechaFiltro = DateTime.now();
  final TextEditingController _busquedaController = TextEditingController();
  String _busquedaTexto = '';

  Future<void> _eliminarVenta(String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Venta?'),
        content: const Text('Esta acción anulará este cobro del corte de caja.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance.collection('ventas').doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta eliminada correctamente.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corte de Caja e Historial'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _fechaFiltro,
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _fechaFiltro = picked);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar por mesa, método de pago o monto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaTexto.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaController.clear();
                          setState(() => _busquedaTexto = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _busquedaTexto = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ventas').orderBy('fecha', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final mesa = (data['mesa'] ?? '').toString().toLowerCase();
                  final metodo = (data['metodoPago'] ?? '').toString().toLowerCase();
                  final total = (data['total'] ?? 0.0).toString();

                  return mesa.contains(_busquedaTexto) || metodo.contains(_busquedaTexto) || total.contains(_busquedaTexto);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No hay registros de ventas que coincidan.'));
                }

                double totalEfectivo = 0.0;
                double totalTarjeta = 0.0;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double t = (data['total'] as num?)?.toDouble() ?? 0.0;
                  if (data['metodoPago'] == 'Tarjeta') {
                    totalTarjeta += t;
                  } else {
                    totalEfectivo += t;
                  }
                }

                return Column(
                  children: [
                    Container(
                      color: Colors.green.shade50,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MetricaResumen(titulo: 'Efectivo', monto: totalEfectivo, color: Colors.green),
                          _MetricaResumen(titulo: 'Tarjeta', monto: totalTarjeta, color: Colors.blue),
                          _MetricaResumen(titulo: 'Total Día', monto: totalEfectivo + totalTarjeta, color: Colors.deepOrange),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final docId = docs[index].id;
                          final String mesa = data['mesa'] ?? 'Mesa';
                          final double total = (data['total'] as num?)?.toDouble() ?? 0.0;
                          final String metodo = data['metodoPago'] ?? 'Efectivo';

                          return ListTile(
                            leading: Icon(
                              metodo == 'Tarjeta' ? Icons.credit_card : Icons.money,
                              color: metodo == 'Tarjeta' ? Colors.blue : Colors.green,
                            ),
                            title: Text('$mesa - Total: \$${total.toStringAsFixed(2)}'),
                            subtitle: Text('Método: $metodo'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _eliminarVenta(docId),
                              tooltip: 'Borrar Venta Duplicada',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricaResumen extends StatelessWidget {
  final String titulo;
  final double monto;
  final Color color;

  const _MetricaResumen({required this.titulo, required this.monto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(
          '\$${monto.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}