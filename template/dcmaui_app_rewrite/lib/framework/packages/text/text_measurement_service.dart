import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;
import '../native_bridge/native_bridge.dart';

/// Text measurement cache key
class TextMeasurementKey {
  final String text;
  final double fontSize;
  final String? fontFamily;
  final String? fontWeight;
  final double? letterSpacing;
  final String? textAlign;
  final double? maxWidth;

  const TextMeasurementKey({
    required this.text,
    required this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.letterSpacing,
    this.textAlign,
    this.maxWidth,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TextMeasurementKey &&
        other.text == text &&
        other.fontSize == fontSize &&
        other.fontFamily == fontFamily &&
        other.fontWeight == fontWeight &&
        other.letterSpacing == letterSpacing &&
        other.textAlign == textAlign &&
        other.maxWidth == maxWidth;
  }

  @override
  int get hashCode {
    return Object.hash(
      text,
      fontSize,
      fontFamily,
      fontWeight,
      letterSpacing,
      textAlign,
      maxWidth,
    );
  }
}

/// Text measurement result
class TextMeasurement {
  final double width;
  final double height;
  final bool isEstimate;

  const TextMeasurement({
    required this.width,
    required this.height,
    this.isEstimate = false,
  });
}

/// Service for measuring text size
class TextMeasurementService {
  /// Singleton instance
  static final TextMeasurementService instance = TextMeasurementService._();

  /// Cached measurements
  final Map<TextMeasurementKey, TextMeasurement> _cache = {};

  /// Native bridge for accurate measurements
  late final NativeBridge _nativeBridge;

  /// Set of pending measurement requests to avoid duplicates
  final Set<TextMeasurementKey> _pendingRequests = {};

  /// Map of completer for pending requests
  final Map<TextMeasurementKey, List<Completer<TextMeasurement>>>
      _pendingCompleters = {};

  /// In-memory font metrics cache for quick estimation
  final Map<String, _FontMetrics> _fontMetricsCache = {};

  TextMeasurementService._();

  /// Initialize the service with a native bridge
  void initialize(NativeBridge nativeBridge) {
    _nativeBridge = nativeBridge;
    _initializeDefaultFontMetrics();
  }

  /// Initialize default font metrics for common fonts
  void _initializeDefaultFontMetrics() {
    // System font (San Francisco on iOS, Roboto on Android)
    _fontMetricsCache[''] = _FontMetrics(
      averageCharWidth: 0.6, // Average character width as fraction of fontSize
      lineHeightMultiplier: 1.2, // Line height as multiple of fontSize
      spaceWidth: 0.3, // Width of space as fraction of fontSize
    );

    // Common fonts
    _fontMetricsCache['Roboto'] = _FontMetrics(
      averageCharWidth: 0.58,
      lineHeightMultiplier: 1.2,
      spaceWidth: 0.3,
    );

    _fontMetricsCache['SF Pro'] = _FontMetrics(
      averageCharWidth: 0.6,
      lineHeightMultiplier: 1.3,
      spaceWidth: 0.3,
    );
  }

  /// Measure text dimensions with caching and native fallback
  Future<TextMeasurement> measureText(
    String text, {
    required double fontSize,
    String? fontFamily,
    String? fontWeight,
    double? letterSpacing,
    String? textAlign,
    double? maxWidth,
    String? containerId,
  }) async {
    // Create cache key
    final key = TextMeasurementKey(
      text: text,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      textAlign: textAlign,
      maxWidth: maxWidth,
    );

    // Check cache first
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Generate quick estimate for immediate use
    final estimate = _estimateTextSize(text, key);

    // If this is a one-character measurement, we can just use the estimate
    if (text.length <= 1) {
      final measurement = TextMeasurement(
        width: estimate.width,
        height: estimate.height,
        isEstimate: true,
      );
      _cache[key] = measurement;
      return measurement;
    }

    // Don't proceed with native measurement if we have no bridge
    if (!_hasNativeBridge) {
      return estimate;
    }

    // Check if we already have a pending request for this text
    if (_pendingRequests.contains(key)) {
      // Wait for existing request to complete
      final completer = Completer<TextMeasurement>();
      _pendingCompleters.putIfAbsent(key, () => []).add(completer);
      return completer.future;
    }

    // Mark as pending
    _pendingRequests.add(key);
    final requestCompleters = <Completer<TextMeasurement>>[];
    _pendingCompleters[key] = requestCompleters;

    try {
      // Convert properties to attributes map
      final textAttributes = <String, dynamic>{
        'fontSize': fontSize,
      };

      if (fontFamily != null) {
        textAttributes['fontFamily'] = fontFamily;
      }

      if (fontWeight != null) {
        textAttributes['fontWeight'] = fontWeight;
      }

      if (letterSpacing != null) {
        textAttributes['letterSpacing'] = letterSpacing;
      }

      if (textAlign != null) {
        textAttributes['textAlign'] = textAlign;
      }

      if (maxWidth != null) {
        textAttributes['maxWidth'] = maxWidth;
      }

      // Request measurement from native
      final result = await _nativeBridge.measureText(
        containerId ?? 'root',
        text,
        textAttributes,
      );

      // Create measurement result
      final measurement = TextMeasurement(
        width: result['width'] ?? 0.0,
        height: result['height'] ?? 0.0,
        isEstimate: false,
      );

      // Cache the result
      _cache[key] = measurement;

      // Complete all pending completers
      for (final completer in requestCompleters) {
        completer.complete(measurement);
      }

      return measurement;
    } catch (e) {
      developer.log('Error measuring text: $e', name: 'TextMeasurement');

      // Complete with estimate on error
      for (final completer in requestCompleters) {
        completer.complete(estimate);
      }

      return estimate;
    } finally {
      // Clean up pending request
      _pendingRequests.remove(key);
      _pendingCompleters.remove(key);
    }
  }

  /// Get a cached measurement or null if not in cache
  TextMeasurement? getCachedMeasurement(TextMeasurementKey key) {
    return _cache[key];
  }

  /// Clear cached measurements
  void clearCache() {
    _cache.clear();
  }

  /// Measure text with Flutter's TextPainter for estimation
  TextMeasurement _estimateTextSize(String text, TextMeasurementKey key) {
    // Check if we have metrics for this font
    final metrics =
        _fontMetricsCache[key.fontFamily ?? ''] ?? _fontMetricsCache['']!;

    // Simple estimation based on character count
    final basicWidth = text.length * metrics.averageCharWidth * key.fontSize;

    // Handle max width and multi-line scenarios
    double width = basicWidth;
    double height = key.fontSize * metrics.lineHeightMultiplier;

    // If there's a max width constraint, estimate line wrapping
    if (key.maxWidth != null && basicWidth > key.maxWidth!) {
      // Approximate number of lines
      final lines = max(1, (basicWidth / key.maxWidth!).ceil());
      width = min(basicWidth, key.maxWidth!);
      height = key.fontSize * metrics.lineHeightMultiplier * lines;
    }

    return TextMeasurement(
      width: width,
      height: height,
      isEstimate: true,
    );
  }

  // Check if we have a native bridge available
  bool get _hasNativeBridge {
    try {
      // ignore: unnecessary_null_comparison
      return _nativeBridge != null;
    } catch (e) {
      return false;
    }
  }
}

/// Font metrics for estimation
class _FontMetrics {
  final double averageCharWidth;
  final double lineHeightMultiplier;
  final double spaceWidth;

  _FontMetrics({
    required this.averageCharWidth,
    required this.lineHeightMultiplier,
    required this.spaceWidth,
  });
}
