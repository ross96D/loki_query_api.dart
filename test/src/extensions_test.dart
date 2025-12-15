import 'package:loki_query_api/src/extensions.dart';
import 'package:test/test.dart';


void main() {
  group('PrometheusDuration Extension', () {
    test('zero duration', () {
      expect(Duration.zero.toPrometheusString(), equals('0s'));
    });

    test('single seconds', () {
      expect(Duration(seconds: 30).toPrometheusString(), equals('30s'));
      expect(Duration(seconds: 1).toPrometheusString(), equals('1s'));
      expect(Duration(seconds: 60).toPrometheusString(), equals('1m'));
    });

    test('single minutes', () {
      expect(Duration(minutes: 5).toPrometheusString(), equals('5m'));
      expect(Duration(minutes: 1).toPrometheusString(), equals('1m'));
      expect(Duration(minutes: 60).toPrometheusString(), equals('1h'));
    });

    test('single hours', () {
      expect(Duration(hours: 3).toPrometheusString(), equals('3h'));
      expect(Duration(hours: 1).toPrometheusString(), equals('1h'));
      expect(Duration(hours: 24).toPrometheusString(), equals('1d'));
    });

    test('single days', () {
      expect(Duration(days: 1).toPrometheusString(), equals('1d'));
      expect(Duration(days: 2).toPrometheusString(), equals('2d'));
    });

    test('combined durations', () {
      expect(
        Duration(hours: 2, minutes: 30).toPrometheusString(),
        equals('2h30m'),
      );
      expect(
        Duration(days: 1, hours: 3, minutes: 15).toPrometheusString(),
        equals('1d3h15m'),
      );
      expect(
        Duration(hours: 1, minutes: 30, seconds: 45).toPrometheusString(),
        equals('1h30m45s'),
      );
    });

    test('duration that converts between units', () {
      expect(Duration(seconds: 90).toPrometheusString(), equals('1m30s'));
      expect(Duration(minutes: 90).toPrometheusString(), equals('1h30m'));
      expect(Duration(hours: 25).toPrometheusString(), equals('1d1h'));
      expect(
        Duration(hours: 26, minutes: 90).toPrometheusString(),
        equals('1d3h30m'),
      );
    });

    test('negative durations', () {
      expect((-Duration(seconds: 30)).toPrometheusString(), equals('-30s'));
      expect((-Duration(minutes: 5)).toPrometheusString(), equals('-5m'));
      expect((-Duration(hours: 2)).toPrometheusString(), equals('-2h'));
      expect(
        (-Duration(hours: 1, minutes: 30)).toPrometheusString(),
        equals('-1h30m'),
      );
      expect((-Duration(seconds: 500)).toPrometheusString(), equals('-8m20s'));
      expect((-Duration(days: 750)).toPrometheusString(), equals('-750d'));
    });

    test('complex combinations', () {
      expect(
        Duration(days: 1, hours: 2, minutes: 3, seconds: 4, milliseconds: 5, microseconds: 6)
            .toPrometheusString(),
        equals('1d2h3m4s'),
      );
      expect(
        Duration(hours: 36, minutes: 90, seconds: 150).toPrometheusString(),
        equals('1d13h32m30s'),
      );
    });

    test('edge cases', () {
      expect(Duration(seconds: 1).toPrometheusString(), equals('1s'));
      expect(const Duration(days: 365).toPrometheusString(), equals('365d'));
      expect(Duration(seconds: 59).toPrometheusString(), equals('59s'));
      expect(Duration(minutes: 59).toPrometheusString(), equals('59m'));
      expect(Duration(hours: 23).toPrometheusString(), equals('23h'));
    });

    test('very small durations', () {
      expect(Duration(microseconds: 999).toPrometheusString(), equals('0s'));
      expect(Duration(milliseconds: 999).toPrometheusString(), equals('0s'));
    });
  });
}
