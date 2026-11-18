import 'package:material_ui/material_ui.dart';

import '../material.dart';
import '../stores/store_selection_screen.dart';

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({required this.contexto, required this.emailUsuario, super.key});
  final Map<String, dynamic> contexto;
  final String emailUsuario;

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final permissions = (widget.contexto['permisos'] is List)
        ? (widget.contexto['permisos'] as List).whereType<String>().toSet()
        : <String>{};
    final role = widget.contexto['rol'] is String ? widget.contexto['rol'] as String : '';
    final destinations = <_Destination>[
      const _Destination('Inicio', Icons.home_outlined),
      if (permissions.contains('productos:leer')) const _Destination('Productos', Icons.inventory_2_outlined),
      if (permissions.contains('inventario:leer')) const _Destination('Inventario', Icons.warehouse_outlined),
      const _Destination('Más', Icons.more_horiz),
    ];
    final selected = _index < destinations.length ? _index : 0;
    return LayoutBuilder(builder: (context, constraints) {
      final mobile = constraints.maxWidth < 600;
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Row(children: [
          if (!mobile) NavigationRail(
            selectedIndex: selected,
            onDestinationSelected: (i) => setState(() => _index = i),
            extended: constraints.maxWidth >= 1024,
            labelType: constraints.maxWidth >= 1024 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            destinations: [for (final d in destinations) NavigationRailDestination(icon: Icon(d.icon), label: Text(d.title))],
          ),
          Expanded(child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(padding: EdgeInsets.all(mobile ? 24 : 32), children: [
              _storeHeader(role),
              const SizedBox(height: 28),
              if (selected == 0) ...[
                Text('Hola, ${widget.emailUsuario}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: ColoresApp.textoPrincipal)),
                const SizedBox(height: 8),
                Text(role == 'cajero' ? 'Atiende a tu siguiente cliente.' : 'Accesos de tu tienda',
                  style: const TextStyle(fontSize: 16, color: ColoresApp.textoSecundario)),
                const SizedBox(height: 24),
                if (role == 'cajero') const _PendingCard(title: 'Nueva venta', icon: Icons.point_of_sale_outlined),
                if (role != 'cajero') const _PendingCard(title: 'Vender', icon: Icons.point_of_sale_outlined),
                const SizedBox(height: 12),
                for (var i = 1; i < destinations.length - 1; i++) ...[
                  _AccessCard(destination: destinations[i], onTap: () => setState(() => _index = i)),
                  const SizedBox(height: 12),
                ],
                if (role != 'cajero') const _PendingCard(title: 'Caja', icon: Icons.account_balance_wallet_outlined),
                const SizedBox(height: 28),
                Text(role == 'cajero' ? 'Más vendidos' : 'Productos por revisar',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Esta información estará disponible cuando se integre el módulo correspondiente.',
                  style: TextStyle(color: ColoresApp.textoSecundario)),
              ] else ...[
                Text(destinations[selected].title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Text('Esta sección está pendiente de implementar.', style: TextStyle(color: ColoresApp.textoSecundario)),
              ],
            ]),
          ))),
        ])),
        bottomNavigationBar: mobile ? NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [for (final d in destinations) NavigationDestination(icon: Icon(d.icon), label: d.title)],
        ) : null,
      );
    });
  }

  Widget _storeHeader(String role) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(side: const BorderSide(color: ColoresApp.borde), borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => StoreSelectionScreen(emailUsuario: widget.emailUsuario),
      )),
      child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TIENDA ACTIVA', style: TextStyle(fontSize: 12, color: ColoresApp.textoSecundario)),
          Text(widget.contexto['nombre'] as String, style: const TextStyle(fontSize: 16)),
          Text('${_roleLabel(role)} · Cambiar tienda', style: const TextStyle(fontSize: 12, color: ColoresApp.verdePrincipal)),
        ])),
        const Icon(Icons.expand_more, color: ColoresApp.verdePrincipal),
      ])),
    ),
  );

  String _roleLabel(String role) => switch (role) {
    'propietario' => 'Propietario', 'encargado' => 'Encargado', 'cajero' => 'Cajero', _ => role,
  };
}

class _Destination {
  const _Destination(this.title, this.icon);
  final String title;
  final IconData icon;
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.destination, required this.onTap});
  final _Destination destination;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap, icon: Icon(destination.icon),
    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(72), alignment: Alignment.centerLeft,
      side: const BorderSide(color: ColoresApp.borde), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    label: Text('${destination.title} · Pendiente'),
  );
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: const Color(0xFFE6EBE7), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [Icon(icon, color: ColoresApp.textoSecundario), const SizedBox(width: 12),
      Text('$title · Próximamente', style: const TextStyle(color: ColoresApp.textoSecundario, fontWeight: FontWeight.w600))]),
  );
}
