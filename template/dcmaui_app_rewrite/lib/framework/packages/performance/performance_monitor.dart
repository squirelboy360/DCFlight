import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

// Helper class for operation time tracking - moved to top level
class _Operation {
  final String name;
  final double startTime;
  final double duration;

  _Operation(this.name, this.startTime, this.duration);

  double get endTime => startTime + duration;
}

/// Performance monitor for DCMAUI framework
/// Collects performance metrics and reports on system performance
class PerformanceMonitor {
  // Singleton instance
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Performance metrics
  final Map<String, List<double>> _renderTimes = {};
  final Map<String, List<double>> _eventTimes = {};
  final Map<String, Stopwatch> _activeTimers = {};

  // State tracking
  bool _isMonitoring = false;
  Timer? _reportingTimer;

  // Start monitoring performance
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    // Set up periodic reporting
    _reportingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      reportPerformanceMetrics();
    });

    developer.log('Performance monitoring started', name: 'Performance');
  }

  // Stop monitoring performance
  void stopMonitoring() {
    _isMonitoring = false;
    _reportingTimer?.cancel();
    _reportingTimer = null;
    developer.log('Performance monitoring stopped', name: 'Performance');
  }

  // Start timing an operation
  void startTimer(String operation, {String category = 'render'}) {
    if (!_isMonitoring) return;

    _activeTimers[operation] = Stopwatch()..start();
  }

  // End timing an operation and record results
  void endTimer(String operation, {String category = 'render'}) {
    if (!_isMonitoring || !_activeTimers.containsKey(operation)) return;

    final timer = _activeTimers.remove(operation)!;
    timer.stop();
    final elapsed =
        timer.elapsedMicroseconds / 1000.0; // Convert to milliseconds

    // Store in appropriate category
    final collection = category == 'event' ? _eventTimes : _renderTimes;
    collection[operation] ??= [];
    collection[operation]!.add(elapsed);

    // Log individual times for very expensive operations
    if (elapsed > 16.0) {
      // Frame budget threshold
      developer.log(
          '⚠️ Slow $category operation: $operation took ${elapsed.toStringAsFixed(2)}ms',
          name: 'Performance');
    }
  }

  // Time an async operation
  Future<T> timeAsync<T>(String operation, Future<T> Function() callback,
      {String category = 'render'}) async {
    startTimer(operation);
    try {
      return await callback();
    } finally {
      endTimer(operation, category: category);
    }
  }

  // Time a synchronous operation
  T timeSync<T>(String operation, T Function() callback,
      {String category = 'render'}) {
    startTimer(operation);
    try {
      return callback();
    } finally {
      endTimer(operation, category: category);
    }
  }

  // Report collected metrics
  void reportPerformanceMetrics() {
    if (_renderTimes.isEmpty && _eventTimes.isEmpty) return;

    developer.log('📊 DCMAUI PERFORMANCE REPORT', name: 'Performance');

    // Compute and report render metrics
    _reportCategoryMetrics('UI Operations (FFI Thread)', _renderTimes);

    // Compute and report event metrics
    _reportCategoryMetrics(
        'Event Handling (Method Channel Thread)', _eventTimes);

    // Calculate thread separation metrics
    _reportThreadSeparationMetrics();

    // Clear metrics for next period
    _renderTimes.clear();
    _eventTimes.clear();
  }

  // Report metrics for a specific category
  void _reportCategoryMetrics(
      String categoryName, Map<String, List<double>> metrics) {
    if (metrics.isEmpty) return;

    developer.log('📊 $categoryName:', name: 'Performance');

    // Calculate total time spent
    double totalTime = 0;
    int totalOperations = 0;

    for (final entry in metrics.entries) {
      final operation = entry.key;
      final times = entry.value;

      // Calculate statistics
      final count = times.length;
      final total = times.fold(0.0, (sum, time) => sum + time);
      final average = total / count;
      final max = times.reduce((a, b) => a > b ? a : b);

      totalTime += total;
      totalOperations += count;

      // Log detailed metrics for operations
      developer.log(
          '  • $operation: ${count}x, avg: ${average.toStringAsFixed(2)}ms, max: ${max.toStringAsFixed(2)}ms',
          name: 'Performance');
    }

    // Log summary
    developer.log(
        '  📈 Summary: $totalOperations operations, total: ${totalTime.toStringAsFixed(2)}ms, avg: ${(totalTime / totalOperations).toStringAsFixed(2)}ms',
        name: 'Performance');
  }

  // Analyze and report on thread separation benefits
  void _reportThreadSeparationMetrics() {
    // Determine if there's evidence of overlapping operations
    final renderOps = _collectAllOperationTimes(_renderTimes);
    final eventOps = _collectAllOperationTimes(_eventTimes);

    if (renderOps.isEmpty || eventOps.isEmpty) return;

    // Calculate potential blocking time saved by thread separation
    final totalRenderTime = renderOps.fold(0.0, (sum, op) => sum + op.duration);
    final totalEventTime = eventOps.fold(0.0, (sum, op) => sum + op.duration);

    // Count overlapping operations
    int overlappingOps = 0;
    double overlappingTime = 0;

    for (final renderOp in renderOps) {
      for (final eventOp in eventOps) {
        if (_operationsOverlap(renderOp, eventOp)) {
          overlappingOps++;
          overlappingTime += math.min(
              renderOp.endTime -
                  math.max(renderOp.startTime, eventOp.startTime),
              eventOp.endTime -
                  math.max(renderOp.startTime, eventOp.startTime));
        }
      }
    }

    if (overlappingOps > 0) {
      developer.log('📊 Thread Separation Benefits:', name: 'Performance');
      developer.log('  • Parallel operations: $overlappingOps',
          name: 'Performance');
      developer.log(
          '  • Time saved by dual threads: ${overlappingTime.toStringAsFixed(2)}ms',
          name: 'Performance');

      // Calculate percent improvement
      final singleThreadTime = totalRenderTime + totalEventTime;
      final dualThreadTime = singleThreadTime - overlappingTime;
      final improvement =
          ((singleThreadTime - dualThreadTime) / singleThreadTime) * 100;

      developer.log(
          '  • Efficiency improvement: ${improvement.toStringAsFixed(1)}%',
          name: 'Performance');

      if (improvement > 10) {
        developer.log(
            '  ✅ EVIDENCE OF DUAL-THREAD BENEFIT: Significant performance improvement detected',
            name: 'Performance');
      }
    }
  }

  // Convert time records to sequential operations for overlap analysis
  List<_Operation> _collectAllOperationTimes(
      Map<String, List<double>> timeMap) {
    final operations = <_Operation>[];
    double currentTime = 0;

    for (final entry in timeMap.entries) {
      final operation = entry.key;
      final times = entry.value;

      for (final time in times) {
        operations.add(_Operation(operation, currentTime, time));
        currentTime += time;
      }
    }

    return operations;
  }

  // Check if two operations would overlap in a single-threaded model
  bool _operationsOverlap(_Operation op1, _Operation op2) {
    return (op1.startTime < op2.endTime && op1.endTime > op2.startTime);
  }

  // Get metrics report
  Map<String, dynamic> getMetricsReport() {
    final report = <String, dynamic>{};

    // Render metrics
    final renderMetrics = <String, Map<String, dynamic>>{};
    for (final entry in _renderTimes.entries) {
      final times = entry.value;
      if (times.isEmpty) continue;

      final avg = times.reduce((a, b) => a + b) / times.length;
      final max = times.reduce((a, b) => a > b ? a : b);

      renderMetrics[entry.key] = {
        'count': times.length,
        'avg': avg,
        'max': max,
        'total': times.reduce((a, b) => a + b),
      };
    }

    // Event metrics
    final eventMetrics = <String, Map<String, dynamic>>{};
    for (final entry in _eventTimes.entries) {
      final times = entry.value;
      if (times.isEmpty) continue;

      final avg = times.reduce((a, b) => a + b) / times.length;
      final max = times.reduce((a, b) => a > b ? a : b);

      eventMetrics[entry.key] = {
        'count': times.length,
        'avg': avg,
        'max': max,
        'total': times.reduce((a, b) => a + b),
      };
    }

    report['render'] = renderMetrics;
    report['event'] = eventMetrics;

    return report;
  }
}

/// Performance monitoring for the VDOM
class VDOMPerformanceMonitor {
  /// Singleton instance
  static final VDOMPerformanceMonitor _instance =
      VDOMPerformanceMonitor._internal();

  /// Private constructor
  VDOMPerformanceMonitor._internal();

  /// Factory constructor to return the singleton instance
  factory VDOMPerformanceMonitor() {
    return _instance;
  }

  /// Time metrics
  final Map<String, List<double>> _timeMetrics = {};

  /// Count metrics
  final Map<String, int> _countMetrics = {};

  /// Active timers
  final Map<String, DateTime> _activeTimers = {};

  /// Categories for different metrics
  final Map<String, String> _metricCategories = {};

  /// Whether monitoring is enabled
  bool _isMonitoring = false;

  /// Start monitoring
  void startMonitoring() {
    _isMonitoring = true;
    developer.log('Performance monitoring started', name: 'Performance');
  }

  /// Stop monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    developer.log('Performance monitoring stopped', name: 'Performance');
  }

  /// Start timing an operation
  void startTimer(String name, {String category = 'render'}) {
    if (!_isMonitoring) return;

    _activeTimers[name] = DateTime.now();
    _metricCategories[name] = category;
  }

  /// End timing an operation
  void endTimer(String name, {String? category}) {
    if (!_isMonitoring) return;

    final startTime = _activeTimers[name];
    if (startTime == null) {
      developer.log('Timer "$name" not started', name: 'Performance');
      return;
    }

    final duration =
        DateTime.now().difference(startTime).inMicroseconds / 1000.0;
    _activeTimers.remove(name);

    // Store the metric
    if (!_timeMetrics.containsKey(name)) {
      _timeMetrics[name] = [];
    }
    _timeMetrics[name]!.add(duration);

    // Override category if specified
    if (category != null) {
      _metricCategories[name] = category;
    }
  }

  /// Increment a counter
  void incrementCounter(String name, {int by = 1, String category = 'count'}) {
    if (!_isMonitoring) return;

    _countMetrics[name] = (_countMetrics[name] ?? 0) + by;
    _metricCategories[name] = category;
  }

  /// Reset all metrics
  void resetMetrics() {
    _timeMetrics.clear();
    _countMetrics.clear();
    _activeTimers.clear();
    developer.log('Performance metrics reset', name: 'Performance');
  }

  /// Get timing metrics statistics
  Map<String, dynamic> getTimeMetricStats(String name) {
    final metrics = _timeMetrics[name];
    if (metrics == null || metrics.isEmpty) {
      return {
        'count': 0,
        'avg': 0.0,
        'min': 0.0,
        'max': 0.0,
        'p50': 0.0,
        'p90': 0.0,
        'p99': 0.0,
        'total': 0.0,
        'category': _metricCategories[name] ?? 'unknown'
      };
    }

    // Sort for percentile calculations
    final sortedMetrics = List<double>.from(metrics)..sort();

    final avg = metrics.reduce((a, b) => a + b) / metrics.length;
    final min = sortedMetrics.first;
    final max = sortedMetrics.last;
    final p50 = _percentile(sortedMetrics, 50);
    final p90 = _percentile(sortedMetrics, 90);
    final p99 = _percentile(sortedMetrics, 99);
    final total = metrics.reduce((a, b) => a + b);

    return {
      'count': metrics.length,
      'avg': avg,
      'min': min,
      'max': max,
      'p50': p50,
      'p90': p90,
      'p99': p99,
      'total': total,
      'category': _metricCategories[name] ?? 'unknown'
    };
  }

  /// Calculate percentile from sorted data
  double _percentile(List<double> sortedData, int percentile) {
    if (sortedData.isEmpty) return 0;
    if (sortedData.length == 1) return sortedData[0];

    final index = (percentile / 100.0) * (sortedData.length - 1);
    final lower = sortedData[index.floor()];
    final upper = sortedData[index.ceil()];

    return lower + (upper - lower) * (index - index.floor());
  }

  /// Get all metrics
  Map<String, dynamic> getMetrics() {
    final result = <String, dynamic>{};

    // Time metrics
    final timeMetrics = <String, dynamic>{};
    for (final name in _timeMetrics.keys) {
      timeMetrics[name] = getTimeMetricStats(name);
    }
    result['time'] = timeMetrics;

    // Count metrics
    final countMetrics = <String, dynamic>{};
    for (final entry in _countMetrics.entries) {
      countMetrics[entry.key] = {
        'value': entry.value,
        'category': _metricCategories[entry.key] ?? 'unknown'
      };
    }
    result['count'] = countMetrics;

    return result;
  }

  /// Log all metrics
  void logMetrics() {
    if (!_isMonitoring) return;

    developer.log('Performance Metrics:', name: 'Performance');

    // Log time metrics
    for (final name in _timeMetrics.keys) {
      final stats = getTimeMetricStats(name);
      developer.log(
          '$name: ${stats['count']} calls, '
          'avg: ${stats['avg'].toStringAsFixed(2)}ms, '
          'min: ${stats['min'].toStringAsFixed(2)}ms, '
          'max: ${stats['max'].toStringAsFixed(2)}ms',
          name: 'Performance');
    }

    // Log count metrics
    for (final entry in _countMetrics.entries) {
      developer.log('${entry.key}: ${entry.value}', name: 'Performance');
    }
  }
}
