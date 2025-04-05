/// Properties specific to View components
class ViewProps {
  /// Create view component-specific props
  const ViewProps();

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return <String, dynamic>{};
  }

  /// Create new ViewProps by merging with another
  ViewProps merge(ViewProps other) {
    return ViewProps();
  }
}
