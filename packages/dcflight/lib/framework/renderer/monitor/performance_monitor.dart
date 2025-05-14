/// Performance monitoring utility for tracking timings
class PerformanceMonitor {
  /// Map of timers with start times
  final Map<String, DateTime> _timers = {};

  /// Map of elapsed times by timer name
  final Map<String, List<Duration>> _elapsedTimes = {};

  /// Start a timer with a given name
  void startTimer(String name) {
    _timers[name] = DateTime.now();
  }

  /// End a timer and record elapsed time
  Duration endTimer(String name) {
    if (!_timers.containsKey(name)) {
      return Duration.zero;
    }

    final startTime = _timers[name]!;
    final endTime = DateTime.now();
    final elapsed = endTime.difference(startTime);

    // Store elapsed time
    _elapsedTimes.putIfAbsent(name, () => []);
    _elapsedTimes[name]!.add(elapsed);

    // Clean up
    _timers.remove(name);

    return elapsed;
  }

  /// Get the average time for a timer
  Duration getAverageTime(String name) {
    if (!_elapsedTimes.containsKey(name) || _elapsedTimes[name]!.isEmpty) {
      return Duration.zero;
    }

    final times = _elapsedTimes[name]!;
    final total = times.fold<Duration>(
        Duration.zero, (sum, time) => sum + time);

    return Duration(microseconds: total.inMicroseconds ~/ times.length);
  }

  /// Get all timer statistics
  Map<String, Map<String, dynamic>> getStats() {
    final result = <String, Map<String, dynamic>>{};

    for (final entry in _elapsedTimes.entries) {
      final name = entry.key;
      final times = entry.value;

      if (times.isEmpty) continue;

      // Calculate statistics
      final total = times.fold<Duration>(
          Duration.zero, (sum, time) => sum + time);
      final avg = Duration(microseconds: total.inMicroseconds ~/ times.length);
      
      // Find min and max
      Duration min = times.first;
      Duration max = times.first;
      
      for (final time in times) {
        if (time < min) min = time;
        if (time > max) max = time;
      }

      // Record stats
      result[name] = {
        'count': times.length,
        'total': total.inMicroseconds / 1000.0,
        'avg': avg.inMicroseconds / 1000.0,
        'min': min.inMicroseconds / 1000.0,
        'max': max.inMicroseconds / 1000.0,
      };
    }

    return result;
  }

  /// Reset all timers and statistics
  void reset() {
    _timers.clear();
    _elapsedTimes.clear();
  }
}
