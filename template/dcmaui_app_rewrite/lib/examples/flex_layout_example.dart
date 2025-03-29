import 'package:flutter/material.dart';
import '../framework/components/base_props.dart';
import '../framework/components/view_props.dart';
import '../framework/components/text_props.dart';
import '../framework/components/button_props.dart';
import '../framework/constants/layout_enums.dart';
import '../framework/packages/vdom/component.dart';
import '../framework/packages/vdom/vdom_node.dart';
import '../framework/components/ui.dart';
import 'dart:math' as math;

/// Example component showing flexbox layout capabilities
class FlexLayoutExample extends StatefulComponent {
  FlexLayoutExample({super.key});

  @override
  VDomNode render() {
    final isHorizontal = useState<bool>(false);
    final useWrap = useState<bool>(true);
    final itemCount = useState<int>(12);

    // Generate a list of colored boxes
    final boxes = List.generate(
      itemCount.value,
      (i) => createBox(i),
    );

    // ULTRA SIMPLE LAYOUT - SINGLE CONTAINER WITH DIRECT CHILDREN
    return UI.View(
      props: ViewProps(
        backgroundColor: Colors.white,
        width: double.infinity,
        height: double.infinity,
        padding: 16,
      ),
      children: [
        // Fixed header - using absolute height
        UI.View(
            props: ViewProps(
              height: 40,
              marginBottom: 16,
            ),
            children: [
              UI.Text(
                content: 'Flexbox Layout Demo',
                props: TextProps(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ]),

        // Control panel - fixed height with explicit dimensions
        UI.View(
          props: ViewProps(
            backgroundColor: Color(0xFFF0F0F0),
            borderRadius: 8,
            padding: 12,
            marginBottom: 16,
            height: 150, // Explicit fixed height
            overflow: true, // Clip contents
          ),
          children: [
            // Direction control
            UI.View(
              props: ViewProps(
                flexDirection: FlexDirection.row,
                alignItems: AlignItems.center,
                height: 36, // Fixed height
                marginBottom: 8,
              ),
              children: [
                UI.Text(
                  content: 'Direction:',
                  props: TextProps(
                    width: 80,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                UI.Button(
                  title: 'Vertical',
                  onPress: (_) => isHorizontal.setValue(false),
                  props: ButtonProps(
                    backgroundColor: !isHorizontal.value
                        ? Colors.blue
                        : Colors.grey.shade300,
                    color: !isHorizontal.value ? Colors.white : Colors.black,
                    marginRight: 8,
                    height: 30,
                    paddingHorizontal: 12,
                    paddingVertical: 6,
                    borderRadius: 4,
                  ),
                ),
                UI.Button(
                  title: 'Horizontal',
                  onPress: (_) => isHorizontal.setValue(true),
                  props: ButtonProps(
                    backgroundColor:
                        isHorizontal.value ? Colors.blue : Colors.grey.shade300,
                    color: isHorizontal.value ? Colors.white : Colors.black,
                    marginRight: 8,
                    height: 30,
                    paddingHorizontal: 12,
                    paddingVertical: 6,
                    borderRadius: 4,
                  ),
                ),
              ],
            ),

            // Wrap control
            UI.View(
              props: ViewProps(
                flexDirection: FlexDirection.row,
                alignItems: AlignItems.center,
                height: 36, // Fixed height
                marginBottom: 8,
              ),
              children: [
                UI.Text(
                  content: 'Wrap:',
                  props: TextProps(
                    width: 80,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                UI.Button(
                  title: 'On',
                  onPress: (_) => useWrap.setValue(true),
                  props: ButtonProps(
                    backgroundColor:
                        useWrap.value ? Colors.blue : Colors.grey.shade300,
                    color: useWrap.value ? Colors.white : Colors.black,
                    marginRight: 8,
                    height: 30,
                    paddingHorizontal: 12,
                    paddingVertical: 6,
                    borderRadius: 4,
                  ),
                ),
                UI.Button(
                  title: 'Off',
                  onPress: (_) => useWrap.setValue(false),
                  props: ButtonProps(
                    backgroundColor:
                        !useWrap.value ? Colors.blue : Colors.grey.shade300,
                    color: !useWrap.value ? Colors.white : Colors.black,
                    marginRight: 8,
                    height: 30,
                    paddingHorizontal: 12,
                    paddingVertical: 6,
                    borderRadius: 4,
                  ),
                ),
              ],
            ),

            // Items control
            UI.View(
              props: ViewProps(
                flexDirection: FlexDirection.row,
                alignItems: AlignItems.center,
                height: 36, // Fixed height
              ),
              children: [
                UI.Text(
                  content: 'Items:',
                  props: TextProps(
                    width: 80,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                UI.Button(
                  title: '-',
                  onPress: (_) {
                    if (itemCount.value > 1)
                      itemCount.setValue(itemCount.value - 1);
                  },
                  props: ButtonProps(
                    backgroundColor: Colors.blue,
                    color: Colors.white,
                    marginRight: 8,
                    height: 30,
                    width: 30,
                    paddingHorizontal: 0,
                    paddingVertical: 0,
                    borderRadius: 4,
                  ),
                ),
                UI.Text(
                  content: itemCount.value.toString(),
                  props: TextProps(
                    width: 40,
                    textAlign: TextAlign.center,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                UI.Button(
                  title: '+',
                  onPress: (_) => itemCount.setValue(itemCount.value + 1),
                  props: ButtonProps(
                    backgroundColor: Colors.blue,
                    color: Colors.white,
                    marginRight: 8,
                    height: 30,
                    width: 30,
                    paddingHorizontal: 0,
                    paddingVertical: 0,
                    borderRadius: 4,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Boxes container - DIRECTLY ADD BOXES without extra container
        UI.View(
          props: ViewProps(
            flex: 1,
            backgroundColor: Color(0xFFEEEEEE),
            borderRadius: 8,
            padding: 8,
            flexDirection:
                isHorizontal.value ? FlexDirection.row : FlexDirection.column,
            flexWrap: useWrap.value ? FlexWrap.wrap : FlexWrap.nowrap,
            overflow: true, // Force clipping of contents
          ),
          children: boxes,
        ),
      ],
    );
  }

  // Create a colored box with index number
  VDomNode createBox(int index) {
    final hue = (index * 30) % 360;
    final color = HSVColor.fromAHSV(1.0, hue.toDouble(), 0.7, 0.9).toColor();

    return UI.View(
      key: 'box_$index',
      props: ViewProps(
        width: 80, // Smaller fixed width
        height: 80, // Smaller fixed height
        backgroundColor: color,
        borderRadius: 8,
        margin: 8,
        alignItems: AlignItems.center,
        justifyContent: JustifyContent.center,
      ),
      children: [
        UI.Text(
          content: (index + 1).toString(),
          props: TextProps(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
