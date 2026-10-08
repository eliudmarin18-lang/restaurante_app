import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference ventasCollection =
        FirebaseFirestore.instance.collection('ventas');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas / Corte de Caja'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ventasCollection.orderBy('fecha', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar historial de ventas'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay ventas registradas aún.'),
            );
          }

          // Calcular total de todas las ventas para el corte
          double totalGeneral = 0.0;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalGeneral += (data['total'] as num).toDouble();
          }

          return Column(
            children: [
              // RESUMEN DE CORTE DE CAJA
              Container(
                width: double.infinity,
                color: Colors.deepOrange.shade50,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Corte de Caja Total',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total de transacciones: ${docs.length}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Text(
                      '\$${totalGeneral.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // LISTADO DE VENTAS
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final total = (data['total'] as num).toDouble();
                    final Timestamp? timestamp = data['fecha'] as Timestamp?;
                    final fechaTexto = timestamp != null
                        ? timestamp.toDate().toLocal().toString().split('.')[0]
                        : 'Reciente';

                    final List productos = data['productos'] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.attach_money, color: Colors.white),
                        ),
                        title: Text(
                          'Venta de \$${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Fecha: $fechaTexto'),
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: productos.map<Widget>((prod) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${prod['cantidad']}x ${prod['nombre']}'),
                                      Text('\$${(prod['subtotal'] as num).toDouble().toStringAsFixed(2)}'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}