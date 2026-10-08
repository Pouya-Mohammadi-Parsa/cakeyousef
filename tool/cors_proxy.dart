// Local CORS proxy for Flutter web debug.
// Forwards http://localhost:8787/* → http://62.60.222.55/*
//
// Run: dart run tool/cors_proxy.dart
import 'dart:io';

const targetHost = '62.60.222.55';
const listenPort = 8787;

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, listenPort);
  stdout.writeln('CORS proxy: http://127.0.0.1:$listenPort → http://$targetHost');
  stdout.writeln('Keep this running, then Hot Restart the Flutter web app.');

  await for (final request in server) {
    try {
      await _handle(request);
    } catch (e, st) {
      stderr.writeln('Proxy error: $e\n$st');
      if (request.response.connectionInfo != null) {
        try {
          request.response.statusCode = HttpStatus.badGateway;
          await request.response.close();
        } catch (_) {}
      }
    }
  }
}

Future<void> _handle(HttpRequest request) async {
  _addCors(request.response);

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  final upstream = Uri(
    scheme: 'http',
    host: targetHost,
    path: request.uri.path,
    query: request.uri.hasQuery ? request.uri.query : null,
  );

  final client = HttpClient();
  try {
    final out = await client.openUrl(request.method, upstream);
    request.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (lower == 'host' || lower == 'origin' || lower == 'referer') return;
      for (final v in values) {
        out.headers.add(name, v);
      }
    });
    out.headers.set(HttpHeaders.hostHeader, targetHost);

    await out.addStream(request);
    final incoming = await out.close();

    request.response.statusCode = incoming.statusCode;
    incoming.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (lower == 'transfer-encoding' ||
          lower == 'content-encoding' ||
          lower.startsWith('access-control-')) {
        return;
      }
      for (final v in values) {
        request.response.headers.add(name, v);
      }
    });
    _addCors(request.response);

    await request.response.addStream(incoming);
    await request.response.close();
  } finally {
    client.close(force: true);
  }
}

void _addCors(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set(
    'Access-Control-Allow-Methods',
    'GET,POST,PUT,PATCH,DELETE,OPTIONS',
  );
  response.headers.set(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization, Accept',
  );
  response.headers.set('Access-Control-Max-Age', '86400');
}
