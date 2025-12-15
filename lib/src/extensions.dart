extension PrometheusDuration on Duration {
  String toPrometheusString() {
    Duration duration = this;

    final microseconds = duration.inSeconds;
    final absMicroseconds = microseconds.abs();

    // Handle zero duration
    if (absMicroseconds == 0) {
      return '0s';
    }

    // Handle negative duration
    if (microseconds < 0) {
      return '-${_buildPrometheusDurationString(absMicroseconds)}';
    }

    return _buildPrometheusDurationString(absMicroseconds);
  }
}

String _buildPrometheusDurationString(int totalSeconds) {
  final components = <String>[];

  // Calculate each time component
  var remaining = totalSeconds;

  // Days (if any)
  final days = remaining ~/ Duration.secondsPerDay;
  if (days > 0) {
    components.add('${days}d');
    remaining %= Duration.secondsPerDay;
  }

  // Hours (if any)
  final hours = remaining ~/ Duration.secondsPerHour;
  if (hours > 0) {
    components.add('${hours}h');
    remaining %= Duration.secondsPerHour;
  }

  // Minutes (if any)
  final minutes = remaining ~/ Duration.secondsPerMinute;
  if (minutes > 0) {
    components.add('${minutes}m');
    remaining %= Duration.secondsPerMinute;
  }

  // Seconds (if any)
  final seconds = remaining;
  if (seconds > 0) {
    components.add('${seconds}s');
  }

  // If no components were added (shouldn't happen due to zero check), return 0s
  if (components.isEmpty) {
    return '0s';
  }

  return components.join();
}
