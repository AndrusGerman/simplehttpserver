import 'dart:io';

class SimpleHttp {
  HttpServer httpServer;

  List<EngineRoute> routes = [];

  GET(String route, Future Function(HttpRequest) callback) {
    this.routes.add(EngineRoute().CreateRoute('GET', route, callback));
  }

  POST(String route, Future Function(HttpRequest) callback) {
    this.routes.add(EngineRoute().CreateRoute('POST', route, callback));
  }

  Future Function(HttpRequest event) RouteNotFound = (HttpRequest event) async {
    event.response.write({'err': 'route not Found'});
    event.response.close();
  };

  Future<HttpServer> StartListen(dynamic address, int port) async {
    this.httpServer = await HttpServer.bind(address, port);

    _listen();

    return this.httpServer;
  }

  _listen() {
    this.httpServer.listen((event) async {
      // Find Route
      final index = this.routes.indexWhere((element) {
        return element.isValidRequest(event);
      });

      // Is Not Found
      if (index == -1) {
        await this.RouteNotFound(event);
      }

      // Route found
      if (index != -1) {
        await this.routes[index].callback(event);
      }
    });
  }
}

class EngineRoute {
  String _route;
  String method;
  Future Function(HttpRequest) callback;

  CreateRoute(
      String method, String route, Future Function(HttpRequest) callback) {
    this.method = method;
    this._route = route;
    this.callback = callback;
    return this;
  }

  // Validations Route

  bool isValidRequest(HttpRequest event) {
    // Not valid methods
    if (!(method == event.method)) {
      return false;
    }
    // Not valid path
    if (!this._validPath(event)) {
      return false;
    }

    return true;
  }

  bool _validPath(HttpRequest event) {
    final listPt = _route.split('/').where((element) => element != "");

    final request =
        event.requestedUri.pathSegments.where((element) => element != "");

    return _compareSegmentsString(listPt.toList(), request.toList());
  }

  bool _compareSegmentsString(List<String> original, List<String> request) {
    // Not more sub routes
    if (original.length == 0 && request.length == 0) {
      return true;
    }
    // Not more sub routes one element
    if (original.length == 0 || request.length == 0) {
      return false;
    }

    // dynamic element example: /hola/:xd == /hola/luis
    if (original.first.contains(':')) {
      return true;
    }

    // same route
    if (original.first == request.first) {
      return _compareSegmentsString(
          original.skip(1).toList(), request.skip(1).toList());
    }

    // Not valid
    return false;
  }
}
