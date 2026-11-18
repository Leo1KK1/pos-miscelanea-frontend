import 'package:material_ui/material_ui.dart';

/// Colores compartidos del diseño de Mi Tiendita POS.
abstract final class ColoresApp {
  static const verdePrincipal = Color(0xFF216449);
  static const textoPrincipal = Color(0xFF202F28);
  static const textoSecundario = Color(0xFF53645A);
  static const fondo = Color(0xFFF6F8F5);
  static const verdeClaro = Color(0xFFEAF2E8);
  static const borde = Color(0xFFD7E1D8);
  static const advertencia = Color(0xFFFFF2CE);
  static const error = Color(0xFFAC3030);
}

abstract final class TemaApp {
  static ThemeData get claro {
    final esquema =
        ColorScheme.fromSeed(
          seedColor: ColoresApp.verdePrincipal,
          brightness: Brightness.light,
        ).copyWith(
          primary: ColoresApp.verdePrincipal,
          onPrimary: Colors.white,
          primaryContainer: ColoresApp.verdeClaro,
          onPrimaryContainer: ColoresApp.textoPrincipal,
          surface: ColoresApp.fondo,
          onSurface: ColoresApp.textoPrincipal,
          onSurfaceVariant: ColoresApp.textoSecundario,
          outline: ColoresApp.borde,
          outlineVariant: ColoresApp.borde,
          error: ColoresApp.error,
          onError: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: ColoresApp.fondo,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: ColoresApp.textoPrincipal,
        displayColor: ColoresApp.textoPrincipal,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.fondo,
        foregroundColor: ColoresApp.textoPrincipal,
        elevation: 0,
      ),
    );
  }
}
