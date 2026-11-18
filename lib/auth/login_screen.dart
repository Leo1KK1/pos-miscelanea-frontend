import 'package:material_ui/material_ui.dart';

import '../material.dart';
import 'auth_service.dart';
import 'login_widgets.dart';
import '../stores/store_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@') ||
        _passwordController.text.isEmpty) {
      setState(() => _error = 'Escribe un correo válido y tu contraseña.');
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final emailUsuario = await _authService.iniciarSesion(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => StoreSelectionScreen(emailUsuario: emailUsuario),
      ));
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Browsers can briefly report near-zero widths while resizing.
            if (constraints.maxWidth < 200) {
              return const SizedBox.shrink();
            }
            final anchoContenido = constraints.maxWidth < 600
                ? constraints.maxWidth - 48
                : constraints.maxWidth < 1024
                    ? 440.0
                    : 460.0;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth < 600 ? 24 : 32,
                  vertical: 32,
                ),
                child: SizedBox(
                  width: anchoContenido,
                  child: _formulario(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _formulario() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LoginMarca(),
        const SizedBox(height: 28),
        const Text('Iniciar sesión', style: TextStyle(
          color: ColoresApp.textoPrincipal, fontSize: 28,
          fontWeight: FontWeight.w600, height: 1.4,
        )),
        const SizedBox(height: 4),
        const Text('Qué gusto tenerte de vuelta.\nEntra para atender tu tienda.',
          style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 16, height: 1.4)),
        const SizedBox(height: 24),
        LoginCampoCorreo(
          controller: _emailController,
          enabled: !_cargando,
        ),
        const SizedBox(height: 8),
        LoginCampoPassword(
          controller: _passwordController,
          enabled: !_cargando,
          onSubmitted: (_) => _entrar(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 48,
            child: TextButton(
              onPressed: _cargando ? null : () => _mensajeRecuperacionPendiente(context),
              child: const Text('Olvidé mi contraseña', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          LoginMensajeError(mensaje: _error!),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _cargando ? null : _entrar,
            style: FilledButton.styleFrom(
              backgroundColor: ColoresApp.verdePrincipal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _cargando
                ? const Text('Validando acceso…', style: TextStyle(fontWeight: FontWeight.w600))
                : const Text('Entrar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 48, child: TextButton(
          onPressed: _cargando ? null : () => _mensajeRegistroPendiente(context),
          child: const Text('Crear cuenta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        )),
      ],
    ),
  );

  void _mensajeRecuperacionPendiente(BuildContext context) => ScaffoldMessenger.of(context)
    .showSnackBar(const SnackBar(content: Text('La recuperación de contraseña aún no está disponible.')));

  void _mensajeRegistroPendiente(BuildContext context) => ScaffoldMessenger.of(context)
    .showSnackBar(const SnackBar(content: Text('La creación de cuenta aún no está disponible.')));
}
