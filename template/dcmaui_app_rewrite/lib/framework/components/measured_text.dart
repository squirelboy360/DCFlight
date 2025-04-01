import '../packages/vdom/vdom_node.dart';
import '../packages/vdom/component.dart';
import '../packages/text/text_measurement_service.dart';
import 'text_props.dart';
import 'ui.dart';

/// A text component that automatically measures itself
class MeasuredText extends StatefulComponent {
  /// The text content to display
  final String content;

  /// Props for the text
  final TextProps props;

  /// Constraint width (optional)
  final double? constraintWidth;

  /// Create a measured text component
  MeasuredText({
    required this.content,
    required this.props,
    this.constraintWidth,
    super.key,
  });

  @override
  VDomNode render() {
    final text = content;
    final fontSize = props.fontSize ?? 14.0;
    final fontFamily = props.fontFamily;
    final fontWeight = props.fontWeight;

    // Create a state for dimensions
    final dimensions = useState<Map<String, double>>({
      'width': 0,
      'height': 0,
    });

    // Create effect to measure text - with proper dependency tracking
    useEffect(() {
      // Create a measurement key
      final key = TextMeasurementKey(
        text: text,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight?.value,
        maxWidth: constraintWidth,
      );

      // Check for cached measurement
      final cached = TextMeasurementService.instance.getCachedMeasurement(key);
      if (cached != null) {
        dimensions.setValue({
          'width': cached.width,
          'height': cached.height,
        });
        return null;
      }

      // Schedule measurement
      TextMeasurementService.instance
          .measureText(
        text,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight?.value,
        maxWidth: constraintWidth,
      )
          .then((result) {
        // Update dimensions when measurement completes
        dimensions.setValue({
          'width': result.width,
          'height': result.height,
        });
      });

      return null;
    }, dependencies: [text, fontSize, fontFamily, fontWeight, constraintWidth]);

    // Return the text element with appropriate dimensions
    return UI.Text(content: text, props: props);
  }
}
