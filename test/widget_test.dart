import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pos_miscelanea_frontend/main.dart';

void main() {
  testWidgets('soporta anchos transitorios durante el cambio de tamaño', (tester) async {
    tester.view.physicalSize = const Size(434, 645);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MiTienditaApp());
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1.6, 645);
    await tester.pump();
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(434, 645);
    await tester.pump();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra el formulario de inicio de sesión', (tester) async {
    await tester.pumpWidget(const MiTienditaApp());

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('valida campos vacíos y muestra mensajes pendientes', (tester) async {
    await tester.pumpWidget(const MiTienditaApp());

    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Escribe un correo válido y tu contraseña.'), findsOneWidget);

    await tester.tap(find.text('Olvidé mi contraseña'));
    await tester.pump();
    expect(
      find.text('La recuperación de contraseña aún no está disponible.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite mostrar y ocultar contraseña', (tester) async {
    await tester.pumpWidget(const MiTienditaApp());

    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
