final class LokiStreams {
  final List<LokiStream> streams; // TODO 3: maybe we will want to index based on the stream labels

  const LokiStreams(this.streams);

  factory LokiStreams.fromJson(List<dynamic> json) {
    final streams = <LokiStream>[];
    for (final obj in json) {
      streams.add(LokiStream.fromJson(obj as Map<String, dynamic>));
    }
    return LokiStreams(streams);
  }

  @override
  String toString() {
    return streams.join("\n");
  }
}

final class LokiStream {
  final List<LokiLabel> labels;
  final List<LokiLog> logs;

  const LokiStream(this.labels, this.logs);

  factory LokiStream.fromJson(Map<String, dynamic> json) {
    final labels = <LokiLabel>[];
    final logs = <LokiLog>[];

    for (final label in (json["stream"] as Map<String, dynamic>).entries) {
      labels.add(LokiLabel(label.key, label.value as String));
    }

    for (final log_ in (json["values"] as List)) {
      final log = log_ as List;
      int timestamp;
      if (log[0] is String) {
        timestamp = int.parse(log[0]);
      } else {
        timestamp = log[0] as int;
      }
      timestamp = (timestamp / 1000).floor();
      logs.add(LokiLog(DateTime.fromMicrosecondsSinceEpoch(timestamp), log[1] as String));
    }

    return LokiStream(labels, logs);
  }

  @override
  String toString() {
    return "${labels.join(" ")}\n${logs.join('\n')}";
  }

  String? getLabel(String labelName) {
    for (final label in labels) {
      if (label.name == labelName) {
        return label.value;
      }
    }
    return null;
  }
}

final class LokiLabel {
  final String name;
  final String value;

  const LokiLabel(this.name, this.value);

  @override
  bool operator ==(Object other) {
    return other is LokiLabel && name == other.name && value == other.value;
  }

  @override
  int get hashCode => Object.hashAll([name, value]);

  @override
  String toString() {
    return "$name: $value";
  }
}

final class LokiLog {
  final DateTime timestamp;
  final String log;

  const LokiLog(this.timestamp, this.log);

  @override
  String toString() {
    return "$timestamp: $log";
  }
}

sealed class LokiTimestamp {
  const LokiTimestamp();

  String toQueryParamValue();

  @override
  String toString() => toQueryParamValue();
}

final class LokiTimestampMicro extends LokiTimestamp {
  final int value;

  const LokiTimestampMicro(this.value);

  @override
  String toQueryParamValue() {
    return "${value}000";
  }
}

final class LokiTimestampSeconds extends LokiTimestamp {
  final double value;

  const LokiTimestampSeconds(this.value);

  @override
  String toQueryParamValue() {
    return "$value";
  }
}

final class LokiTimestampDate extends LokiTimestamp {
  final DateTime value;

  const LokiTimestampDate(this.value);

  @override
  String toQueryParamValue() {
    return '${value.microsecondsSinceEpoch}000';
  }
}

enum LokiDirection { forward, backward }
