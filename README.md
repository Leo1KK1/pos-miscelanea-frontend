# pos_miscelanea_frontend

## Conexión con el backend

Inicia `npm run dev` en `../pos-miscelanea-backend` con su `.env` configurado. En modo debug, la app usa `http://localhost:3000` (escritorio/web) o `http://10.0.2.2:3000` (emulador Android). Para un dispositivo físico, usa la IP de la computadora en la red local:

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

Sustituye la IP por la real. El backend debe ser accesible desde el dispositivo. HTTP se permite solo en debug; usa una URL HTTPS del backend desplegado para builds de producción, por ejemplo `flutter build apk --dart-define=API_BASE_URL=https://api.ejemplo.com`. La URL es el origen, sin `/api` ni ruta. No incluyas secretos en `--dart-define`.

El navegador exige CORS para llamadas entre orígenes. Configura `CORS_ALLOWED_ORIGINS` en el backend con el origen exacto de Flutter web y usa un puerto fijo, por ejemplo `flutter run -d chrome --web-port=59275`. La selección de tienda requiere conexión y la pantalla principal aún está pendiente.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
