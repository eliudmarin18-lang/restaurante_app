import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/temas.dart';
import '../comanda/comanda_pantalla.dart';
import '../corte_caja/corte_caja_pantalla.dart';
import '../mesas/mesas_pantalla.dart';
import '../productos/gestion_productos_pantalla.dart';

class InicioPantalla extends StatelessWidget {
  const InicioPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final bool esAncho = anchoPantalla > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema POS - Restaurante'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Menú del Sistema',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.orange),
              title: const Text('Tomar Comanda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ComandaPantalla()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_restaurant, color: Colors.blue),
              title: const Text('Gestión de Mesas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MesasPantalla()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.deepOrange),
              title: const Text('Gestión de Productos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GestionProductosPantalla(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale, color: Colors.green),
              title: const Text('Historial y Corte de Caja'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CorteCajaPantalla()),
                );
              },
            ),
            const Divider(),

            // Opción de Modo Oscuro integrada en el menú
            ValueListenableBuilder<ThemeMode>(
              valueListenable: modoTemaNotifier,
              builder: (context, modoActual, _) {
                final esOscuro = modoActual == ThemeMode.dark;
                return SwitchListTile(
                  title: const Text('Modo Oscuro',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(esOscuro ? 'Activado' : 'Desactivado',
                      style: const TextStyle(fontSize: 12)),
                  secondary: Icon(
                    esOscuro ? Icons.dark_mode : Icons.light_mode,
                    color: esOscuro ? Colors.amber : Colors.orange,
                  ),
                  value: esOscuro,
                  onChanged: (bool valor) {
                    modoTemaNotifier.value =
                        valor ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: esAncho ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: esAncho ? 1.3 : 1.15,
              children: [
                _TarjetaAccion(
                  titulo: 'Tomar Comanda',
                  subtitulo: 'Crear nueva orden',
                  icono: Icons.receipt_long,
                  colorFondo: Colors.deepOrange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ComandaPantalla()),
                  ),
                ),
                _TarjetaAccion(
                  titulo: 'Estado Mesas',
                  subtitulo: 'Ver cuentas e inicio',
                  icono: Icons.table_restaurant,
                  colorFondo: Colors.blue.shade700,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MesasPantalla()),
                  ),
                ),
                _TarjetaAccion(
                  titulo: 'Corte de Caja',
                  subtitulo: 'Balance e historial',
                  icono: Icons.point_of_sale,
                  colorFondo: Colors.green.shade700,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CorteCajaPantalla()),
                  ),
                ),
                _TarjetaAccion(
                  titulo: 'Productos',
                  subtitulo: 'Catálogo y precios',
                  icono: Icons.inventory_2,
                  colorFondo: Colors.purple.shade700,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GestionProductosPantalla(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Monitoreo de Mesas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MesasPantalla()),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Ver Mapa'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _ResumenMesasEnVivo(),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAccion extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color colorFondo;
  final VoidCallback onTap;

  const _TarjetaAccion({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.colorFondo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorFondo,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, size: 32, color: Colors.white),
              const Spacer(),
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenMesasEnVivo extends StatelessWidget {
  const _ResumenMesasEnVivo();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('mesas').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay mesas registradas en la base de datos.'),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 140,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String rawNumero =
                data['numero']?.toString() ?? '${index + 1}';
            final String textoMesa = rawNumero.toLowerCase().contains('mesa')
                ? rawNumero
                : 'Mesa $rawNumero';
            final String estado = data['estado'] ?? 'libre';
            final bool esOcupada = estado.toLowerCase() == 'ocupada';

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ComandaPantalla()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_restaurant,
                      color: esOcupada ? Colors.red : Colors.green,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      textoMesa,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
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
    );
  }
}