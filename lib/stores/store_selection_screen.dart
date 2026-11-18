import 'package:material_ui/material_ui.dart';

import '../auth/login_screen.dart';
import '../auth/login_widgets.dart';
import '../material.dart';
import '../home/store_home_screen.dart';
import 'store_service.dart';

class StoreSelectionScreen extends StatefulWidget {
  const StoreSelectionScreen({required this.emailUsuario, super.key});

  final String emailUsuario;

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  final _service = StoreService();
  List<StoreMembership> _tiendas = const [];
  bool _cargando = true;
  String? _error;
  bool _sesionExpirada = false;
  String? _seleccionandoId;

  @override
  void initState() {
    super.initState();
    _cargarTiendas();
  }

  Future<void> _cargarTiendas() async {
    setState(() { _cargando = true; _error = null; _sesionExpirada = false; });
    try {
      final tiendas = await _service.listarTiendas();
      if (!mounted) return;
      setState(() { _tiendas = tiendas; _cargando = false; });
    } on StoreException catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error.message;
        _sesionExpirada = error.sessionExpired;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _cargando = false; _error = 'No fue posible consultar tus tiendas.'; });
    }
  }

  Future<void> _seleccionar(StoreMembership tienda) async {
    setState(() { _seleccionandoId = tienda.id; _error = null; _sesionExpirada = false; });
    try {
      final contexto = await _service.seleccionarTienda(tienda.id);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => StoreHomeScreen(contexto: contexto, emailUsuario: widget.emailUsuario),
      ));
    } on StoreException catch (error) {
      if (!mounted) return;
      setState(() {
        _seleccionandoId = null;
        _error = error.message;
        _sesionExpirada = error.sessionExpired;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _seleccionandoId = null; _error = 'No fue posible validar el acceso a esta tienda.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // Browsers can briefly report near-zero widths while resizing.
          if (constraints.maxWidth < 200) {
            return const SizedBox.shrink();
          }
          final escritorio = constraints.maxWidth >= 900;
          final ancho = constraints.maxWidth < 600
              ? constraints.maxWidth - 48
              : escritorio ? 820.0 : 520.0;
          return Center(
            child: SizedBox(
              width: ancho,
              child: CustomScrollView(slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(constraints.maxWidth < 600 ? 24 : 32, 32,
                      constraints.maxWidth < 600 ? 24 : 32, 32),
                  sliver: SliverList.list(children: [
                    _estadoConexion(),
                    const SizedBox(height: 24),
                    const Text('Selecciona tu tienda', style: TextStyle(
                      color: ColoresApp.textoPrincipal, fontSize: 28,
                      height: 1.4, fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 4),
                    Text('Hola, ${widget.emailUsuario}. ¿En cuál vas a trabajar?',
                      style: const TextStyle(color: ColoresApp.textoSecundario, fontSize: 16, height: 1.4)),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      LoginMensajeError(mensaje: _error),
                      const SizedBox(height: 16),
                      if (_sesionExpirada)
                        SizedBox(height: 48, child: FilledButton(
                          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen(),
                          )),
                          child: const Text('Iniciar sesión nuevamente'),
                        ))
                      else
                        SizedBox(height: 48, child: OutlinedButton.icon(
                          onPressed: _cargando ? null : _cargarTiendas,
                          icon: const Icon(Icons.refresh), label: const Text('Intentar de nuevo'),
                        )),
                      const SizedBox(height: 16),
                    ],
                    if (_cargando)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error == null && _tiendas.isEmpty)
                      _sinTiendas()
                    else if (_error == null)
                      _listaTiendas(escritorio),
                  ]),
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }

  Widget _estadoConexion() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: ColoresApp.verdeClaro, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(_cargando ? Icons.sync : _error == null ? Icons.check_circle_outline : Icons.info_outline,
        color: ColoresApp.verdePrincipal, size: 20),
      const SizedBox(width: 12),
      Text(_cargando ? 'Consultando tiendas…' : _error == null ? 'Conectado' : 'No se pudo completar la consulta',
        style: const TextStyle(color: ColoresApp.verdePrincipal, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _listaTiendas(bool escritorio) {
    if (!escritorio) {
      return Column(children: [
        for (final tienda in _tiendas) ...[
          _StoreCard(tienda: tienda, loading: _seleccionandoId == tienda.id,
            busy: _seleccionandoId != null, onSelect: () => _seleccionar(tienda)),
          const SizedBox(height: 12),
        ],
      ]);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tiendas.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400, mainAxisExtent: 140,
        crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final tienda = _tiendas[index];
        return _StoreCard(tienda: tienda, loading: _seleccionandoId == tienda.id,
          busy: _seleccionandoId != null, onSelect: () => _seleccionar(tienda));
      },
    );
  }

  Widget _sinTiendas() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 56),
    child: Column(children: [
      const LoginMarca(),
      const SizedBox(height: 40),
      const Text('Todavía no tienes tiendas registradas', textAlign: TextAlign.center,
        style: TextStyle(color: ColoresApp.textoPrincipal, fontSize: 22, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      const Text('Pide al propietario que te invite a su tienda para poder continuar.',
        textAlign: TextAlign.center,
        style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 16, height: 1.4)),
    ]),
  );

}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.tienda, required this.loading, required this.busy, required this.onSelect});

  final StoreMembership tienda;
  final bool loading;
  final bool busy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) => Container(
    height: 140,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ColoresApp.borde),
      borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(tienda.nombre, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: ColoresApp.textoPrincipal, fontSize: 16)),
      const SizedBox(height: 2),
      Text(_rolLabel(tienda.rol), style: const TextStyle(color: ColoresApp.textoSecundario, fontSize: 14)),
      const Spacer(),
      SizedBox(width: double.infinity, height: 48, child: FilledButton(
        onPressed: busy ? null : onSelect,
        style: FilledButton.styleFrom(backgroundColor: ColoresApp.verdePrincipal,
          foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: loading ? const SizedBox(width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Entrar'),
      )),
    ]),
  );

  String _rolLabel(String rol) => switch (rol) {
    'propietario' => 'Propietario',
    'encargado' => 'Encargado',
    'cajero' => 'Cajero',
    _ => rol,
  };
}
