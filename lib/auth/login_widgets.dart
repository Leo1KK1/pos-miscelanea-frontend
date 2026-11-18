import 'package:material_ui/material_ui.dart';

import '../material.dart';

/// Marca compacta para encabezados de acceso.
class LoginMarca extends StatelessWidget {
  const LoginMarca({super.key, this.titulo = 'Mi Tiendita POS'});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 320;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ColoresApp.verdePrincipal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Colors.white,
                size: 27,
              ),
            ),
            if (!compacto) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  titulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ColoresApp.textoPrincipal,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Campo de correo con etiqueta y dimensiones compartidas por el acceso.
class LoginCampoCorreo extends StatelessWidget {
  const LoginCampoCorreo({
    super.key,
    this.controller,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return _LoginCampoResponsive(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LoginEtiqueta('Correo electrónico'),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              enabled: enabled,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: _decoracionLogin(
                hintText: 'tu@correo.com',
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo de contraseña con control local para mostrar u ocultar el texto.
class LoginCampoPassword extends StatefulWidget {
  const LoginCampoPassword({
    super.key,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  State<LoginCampoPassword> createState() => _LoginCampoPasswordState();
}

class _LoginCampoPasswordState extends State<LoginCampoPassword> {
  bool _mostrar = false;

  @override
  Widget build(BuildContext context) {
    return _LoginCampoResponsive(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LoginEtiqueta('Contraseña'),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              obscureText: !_mostrar,
              textInputAction: TextInputAction.done,
              decoration: _decoracionLogin(
                hintText: 'Ingresa tu contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _mostrar ? 'Ocultar contraseña' : 'Mostrar contraseña',
                  onPressed: widget.enabled
                      ? () => setState(() => _mostrar = !_mostrar)
                      : null,
                  icon: Icon(
                    _mostrar
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensaje de error accesible, listo para mostrar u ocultar según el estado.
class LoginMensajeError extends StatelessWidget {
  const LoginMensajeError({super.key, required this.mensaje});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    if (mensaje == null || mensaje!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _LoginCampoResponsive(
      child: Semantics(
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColoresApp.error.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 18, color: ColoresApp.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mensaje!,
                  style: const TextStyle(
                    color: ColoresApp.error,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginEtiqueta extends StatelessWidget {
  const _LoginEtiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(
          color: ColoresApp.textoPrincipal,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _LoginCampoResponsive extends StatelessWidget {
  const _LoginCampoResponsive({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SizedBox(width: double.infinity, child: child),
        ),
      );
}

InputDecoration _decoracionLogin({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder borde(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: ColoresApp.textoSecundario),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: borde(ColoresApp.borde),
    enabledBorder: borde(ColoresApp.borde),
    focusedBorder: borde(ColoresApp.verdePrincipal),
    disabledBorder: borde(ColoresApp.borde),
  );
}
