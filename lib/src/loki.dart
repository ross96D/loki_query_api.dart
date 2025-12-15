import "dart:convert";

import "package:http/http.dart" as http;
import "package:loki_query_api/src/extensions.dart";
import "package:loki_query_api/src/types.dart";

final class BasicAuthetication {
  final String username;
  final String password;

  BasicAuthetication(this.username, this.password);

  @override
  String toString() => "$username:$password";

  MapEntry<String, String> get toHeader =>
      MapEntry("Authorization", "Basic ${base64Url.encode(utf8.encode("$username:$password"))}");
}

final class Loki {
  final Uri _baseUri;
  final BasicAuthetication? _basicAuthetication;
  const Loki(this._baseUri, [this._basicAuthetication]);

  // ignore: unused_element
  http.Abortable _createStreamedRequest(String method, Uri uri, Future<void>? abortTrigger) {
    final request = http.AbortableStreamedRequest(method, uri, abortTrigger: abortTrigger);
    if (_basicAuthetication != null) {
      request.headers.addEntries([_basicAuthetication.toHeader]);
    }
    return request;
  }

  http.Abortable _createRequest(String method, Uri uri, Future<void>? abortTrigger) {
    final request = http.AbortableRequest(method, uri, abortTrigger: abortTrigger);
    if (_basicAuthetication != null) {
      request.headers.addEntries([_basicAuthetication.toHeader]);
    }
    return request;
  }

  /// Do a query against a single point in time. This type of query
  /// is often referred to as an instant query. Instant queries are only
  /// used for metric type LogQL queries and will return a 400 (Bad Request)
  /// in case a log type query is provided.
  Future<String> instantQuery(String logQL, [Future<void>? abortTrigger]) async {
    final client = http.Client();
    try {
      final uri = _baseUri.resolve("/loki/api/v1/query").resolve("?query=$logQL");
      print(uri);
      final request = _createRequest("GET", uri, abortTrigger);

      final response = await client.send(request);

      final data = await response.stream.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw "unexpected status code ${response.statusCode}, expected 200\n$data";
      }
      return data;
    } finally {
      client.close();
    }
  }

  /// Do a query over a range of time. This type of query is often referred to
  /// as a range query. Range queries are used for both log and metric type
  ///  LogQL queries.
  Future<LokiStreams> rangeQuery(
    String logQL, {
    int? limit,
    LokiTimestamp? start,
    LokiTimestamp? end,
    Duration? since,
    LokiDirection? direction,
    Future<void>? abortTrigger,
  }) async {
    final client = http.Client();
    try {
      var queryParams = "?query=$logQL";
      if (limit != null) {
        queryParams += "&limit=$limit";
      }
      if (start != null) {
        queryParams += "&start=$start";
      }
      if (end != null) {
        queryParams += "&end=$end";
      }
      if (since != null) {
        queryParams += "&since=${since.toPrometheusString()}";
      }
      if (direction != null) {
        queryParams += "&direction=${direction.name}";
      }
      var uri = _baseUri.resolve("/loki/api/v1/query_range").resolve(queryParams);

      final request = _createRequest("GET", uri, abortTrigger);

      final response = await client.send(request);

      final data = await response.stream.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw "unexpected status code ${response.statusCode}, expected 200\n$data";
      }
      final decodedData = json.decode(data);
      assert(decodedData["status"] == "success");
      if (decodedData["data"]["resultType"] != "streams") {
        throw UnimplementedError(
          "Only stream parsing is implemented. Expected result type streams got ${decodedData["data"]["resultType"]}",
        );
      }
      return LokiStreams.fromJson(decodedData["data"]["result"]);
    } finally {
      client.close();
    }
  }
}
