import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MesasOpcionesModal {
  static void mostrarOpciones(BuildContext context, String mesaActual) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.receipt, color: Colors.blue),
                title: Text('Imprimir Pre-Cuenta ($mesaActual)'),
                subtitle: const Text('Genera ticket de consumo sin cerrar la cuenta'),
                onTap: () {
                  Navigator.pop(ctx);
                  _mostrarPreCuentaDialog(context, mesaActual);
                },
              ),
              ListTile(
                leading: const Icon(Icons.merge_type, color: Colors.orange),
                title: const Text('Unir / Juntar Mesas'),
                subtitle: const Text('Combina el consumo con otra mesa activa'),
                onTap: () {
                  Navigator.pop(ctx);
                  _mostrarDialogoUnirMesas(context, mesaActual);
                },
              ),
              ListTile(
                leading: const Icon(Icons.print, color: Colors.purple),
                title: const Text('Reimprimir Pedido de Cocina'),
                subtitle: const Text('Reenvía comanda a impresora de barra/cocina'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reimprimiendo orden de $mesaActual en cocina...')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _mostrarPreCuentaDialog(BuildContext context, String mesaId) async {
    final doc = await FirebaseFirestore.instance.collection('mesas').doc(mesaId).get();
    final items = doc.data()?['items'] as List? ?? [];
    final double total = (doc.data()?['total'] as num?)?.toDouble() ?? 0.0;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pre-Cuenta - $mesaId'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('*** TICKET PRELIMINAR ***', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              ...items.map((it) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${it['cantidad']}x ${it['nombre']}'),
                        Text('\$${((it['precio'] ?? 0) * (it['cantidad'] ?? 1)).toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imprimiendo pre-cuenta...')));
            },
            icon: const Icon(Icons.print),
            label: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }

  static void _mostrarDialogoUnirMesas(BuildContext context, String mesaOrigen) {
    String? mesaDestino;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unir $mesaOrigen con...'),
        content: StatefulBuilder(
          builder: (context, setSt) {
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Mesa Destino',
                border: OutlineInputBorder(),
              ),
              initialValue: mesaDestino,
              items: List.generate(10, (i) => 'Mesa ${i + 1}')
                  .where((m) => m != mesaOrigen)
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) => setSt(() => mesaDestino = val),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (mesaDestino != null) {
                await _unirMesasEnFirestore(mesaOrigen, mesaDestino!);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mesa $mesaOrigen unida exitosamente a $mesaDestino')),
                );
              }
            },
            child: const Text('Confirmar Unión'),
          ),
        ],
      ),
    );
  }

  static Future<void> _unirMesasEnFirestore(String origen, String destino) async {
    final batch = FirebaseFirestore.instance.batch();
    final docOrigen = await FirebaseFirestore.instance.collection('mesas').doc(origen).get();
    final docDestino = await FirebaseFirestore.instance.collection('mesas').doc(destino).get();

    final List itemsOrigen = docOrigen.data()?['items'] ?? [];
    final List itemsDestino = docDestino.data()?['items'] ?? [];
    final List itemsCombinados = [...itemsDestino, ...itemsOrigen];

    double nuevoTotal = itemsCombinados.fold(0.0, (acc, item) => acc + ((item['precio'] ?? 0.0) * (item['cantidad'] ?? 1)));

    batch.set(
      FirebaseFirestore.instance.collection('mesas').doc(destino),
      {'items': itemsCombinados, 'total': nuevoTotal, 'estado': 'ocupada'},
      SetOptions(merge: true),
    );

    batch.set(
      FirebaseFirestore.instance.collection('mesas').doc(origen),
      {'items': [], 'total': 0.0, 'estado': 'libre'},
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}