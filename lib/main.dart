import 'package:material_ui/material_ui.dart';

import 'auth/login_screen.dart';
import 'material.dart';

void main() {
  runApp(const MiTienditaApp());
}

class MiTienditaApp extends StatelessWidget {
  const MiTienditaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Tiendita POS',
      theme: TemaApp.claro,
      home: const LoginScreen(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int indiceSeleccionado = 0;

  static const titulos = ['Inicio', 'Vender', 'Productos', 'Inventario', 'Más'];

  static const iconos = [
    Icons.home_outlined,
    Icons.point_of_sale_outlined,
    Icons.inventory_2_outlined,
    Icons.warehouse_outlined,
    Icons.more_horiz,
  ];

  void seleccionar(int indice) {
    setState(() {
      indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final mostrarBarraInferior = ancho < 600;
        final barraLateralExtendida = ancho >= 1024;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIENDA DE EJEMPLO',
                  style: TextStyle(fontSize: 10, letterSpacing: 0.8),
                ),
                Text(
                  'Abarrotes La Esquina',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    'Vista previa',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ],
          ),
          body: Row(
            children: [
              if (!mostrarBarraInferior) ...[
                NavigationRail(
                  selectedIndex: indiceSeleccionado,
                  onDestinationSelected: seleccionar,
                  extended: barraLateralExtendida,
                  labelType: barraLateralExtendida
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: [
                    for (var i = 0; i < titulos.length; i++)
                      NavigationRailDestination(
                        icon: Icon(iconos[i]),
                        label: Text(titulos[i]),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
              ],
              Expanded(
                child: SafeArea(
                  child: indiceSeleccionado == 0
                      ? InicioPreview(onSeleccionar: seleccionar)
                      : PantallaPendiente(
                          titulo: titulos[indiceSeleccionado],
                          icono: iconos[indiceSeleccionado],
                        ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: mostrarBarraInferior
              ? NavigationBar(
                  selectedIndex: indiceSeleccionado,
                  onDestinationSelected: seleccionar,
                  destinations: [
                    for (var i = 0; i < titulos.length; i++)
                      NavigationDestination(
                        icon: Icon(iconos[i]),
                        label: titulos[i],
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }
}

class InicioPreview extends StatelessWidget {
  const InicioPreview({required this.onSeleccionar, super.key});

  final ValueChanged<int> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const espacio = 12.0;
            final dosColumnas = constraints.maxWidth >= 500;

            final anchoTarjeta = dosColumnas
                ? (constraints.maxWidth - 32 - espacio) / 2
                : constraints.maxWidth - 32;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Hola, Leo',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Esta pantalla utiliza datos de ejemplo.'),
                const SizedBox(height: 20),
                Wrap(
                  spacing: espacio,
                  runSpacing: espacio,
                  children: [
                    TarjetaAcceso(
                      ancho: anchoTarjeta,
                      titulo: 'Productos',
                      descripcion: 'Consulta el catálogo de tu tienda.',
                      icono: Icons.inventory_2_outlined,
                      onTap: () => onSeleccionar(2),
                    ),
                    TarjetaAcceso(
                      ancho: anchoTarjeta,
                      titulo: 'Inventario',
                      descripcion: 'Revisa existencias y movimientos.',
                      icono: Icons.warehouse_outlined,
                      onTap: () => onSeleccionar(3),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Productos por revisar',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Card(
                  color: ColoresApp.advertencia,
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded),
                    title: Text('Jamón'),
                    subtitle: Text('Ejemplo: existencia baja · 0.500 kg'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'El estado de conexión y los datos reales se '
                  'integrarán en una siguiente etapa.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TarjetaAcceso extends StatelessWidget {
  const TarjetaAcceso({
    required this.ancho,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.onTap,
    super.key,
  });

  final double ancho;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icono, color: ColoresApp.verdePrincipal, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(descripcion),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PantallaPendiente extends StatelessWidget {
  const PantallaPendiente({
    required this.titulo,
    required this.icono,
    super.key,
  });

  final String titulo;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 48, color: ColoresApp.verdePrincipal),
            const SizedBox(height: 12),
            Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Pantalla pendiente de implementar.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
