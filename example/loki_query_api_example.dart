import 'package:loki_query_api/loki_query_api.dart';

void main() async {
  final loki = Loki(
    Uri.parse("https://loki.dyssolsoft.com"),
    BasicAuthetication("loki", "loki-access"),
  );
  final result = await loki.rangeQuery(
    '{job="ctm_prod_web_server"} |= ``',
    limit: 3,
    direction: LokiDirection.backward,
    since: Duration(minutes: 5),
  );
  print(result);
}
