import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../comanda/cobrar_pantalla.dart';
import '../comanda/comanda_pantalla.dart';

class MesasPantalla extends StatelessWidget {
  const MesasPantalla({super.key});

  void _mostrarOpcionesMesa(BuildContext context, String rawNumero, String estado) {
    final String mesaTexto = rawNumero.toLowerCase().contains('mesa')
        ? rawNumero
        : 'Mesa $rawNumero';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$mesaTexto (${estado.toUpperCase()})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.deepOrange),
              title: const Text('Ver / Editar Comanda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ComandaPantalla()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale, color: Colors.green),
              title: const Text('Cobrar Mesa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CobrarPantalla(
                      mesaNombre: mesaTexto,
                      total: 150.0,
                      items: const [],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Mesas'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('mesas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay mesas registradas en la base de datos.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String rawNumero = data['numero']?.toString() ?? '${index + 1}';
              final String textoMesa = rawNumero.toLowerCase().contains('mesa')
                  ? rawNumero
                  : 'Mesa $rawNumero';
              final String estado = data['estado'] ?? 'libre';
              final bool esOcupada = estado == 'ocupada';

              return Card(
                color: esOcupada ? Colors.red.shade50 : Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: esOcupada ? Colors.red : Colors.green,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _mostrarOpcionesMesa(context, rawNumero, estado),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_restaurant,
                        color: esOcupada ? Colors.red : Colors.green,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        textoMesa,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        estado.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: esOcupada ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}