import 'package:simplehttpserver/simplehttpserver.dart';

void main() async {
  print("app: start");
  final server = await SimpleHttp();

  server.GET('/', (event) async {
    event.response.write('hello from /');
    event.response.close();
  });

  server.GET('/hello', (event) async {
    event.response.write('hello any');
    event.response.close();
  });

  server.GET('/hello/:name', (event) async {
    final name = event.uri.pathSegments.last;
    final message = 'Hello ${name}';

    event.response.write(message);
    event.response.close();
  });

  server.StartListen('localhost', 9090);
}
