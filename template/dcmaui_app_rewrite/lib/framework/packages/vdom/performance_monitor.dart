import 'dart:developer' as developer;

/// Utility class for monitoring performance metrics
class PerformanceMonitor {
  /// Map of timers by name
  final Map<String, _Timer> _timers = {};

  /// Map of metrics by name
  final Map<String, _Metric> _metrics = {};

  /// Start a timer with the given name
  void startTimer(String name) {
    _timers[name] = _Timer(DateTime.now());
  }

  /// End a timer with the given name
  void endTimer(String name) {
    final timer = _timers[name];
    if (timer == null) return;

    final duration = DateTime.now().difference(timer.startTime);

    // Update or create the metric
    final metric = _metrics[name] ?? _Metric(name);
    metric.count++;
    metric.totalDuration += duration.inMicroseconds;
    metric.maxDuration = duration.inMicroseconds > metric.maxDuration
        ? duration.inMicroseconds
        : metric.maxDuration;
    metric.minDuration =
        metric.minDuration == 0 || duration.inMicroseconds < metric.minDuration
            ? duration.inMicroseconds
            : metric.minDuration;

    _metrics[name] = metric;

    // Remove the timer
    _timers.remove(name);
  }

  /// Get a metrics report as a map
  Map<String, dynamic> getMetricsReport() {
    final report = <String, dynamic>{};

    for (final metric in _metrics.values) {
      report[metric.name] = {
        'count': metric.count,
        'totalMs': metric.totalDuration / 1000.0,
        'avgMs': metric.count > 0
            ? (metric.totalDuration / metric.count) / 1000.0
            : 0,
        'maxMs': metric.maxDuration / 1000.0,
        'minMs': metric.minDuration / 1000.0,
      };
    }

    return report;
  }

  /// Reset all metrics
  void reset() {
    _timers.clear();
    _metrics.clear();
  }
}

/// Internal timer class
class _Timer {
  final DateTime startTime;

  _Timer(this.startTime);
}

/// Internal metric class
class _Metric {
  final String name;
  int count = 0;
  int totalDuration = 0;
  int maxDuration = 0;
  int minDuration = 0;

  _Metric(this.name);
}
