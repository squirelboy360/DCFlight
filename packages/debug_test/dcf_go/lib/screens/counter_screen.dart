import 'dart:ui';

import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';
import 'package:dcflight/framework/renderer/vdom/component/state_hook.dart';
import 'package:dcflight/framework/utilities/flutter.dart';

// Change from class to function that returns a VDomNode
VDomNode CounterScreen({
  required StateHook<int> counterState,
  required Color textColor,
  required Color accentColor,
}) {
  return view(
    layout: const LayoutProps(
      width: '100%',
      height: 600,
      justifyContent: YogaJustifyContent.center,
      alignItems: YogaAlign.center,
      padding: 20,
    ),
    children: [
    view(
      layout: const LayoutProps(
        width: '100%',
        height: 300,
        justifyContent: YogaJustifyContent.center,
        alignItems: YogaAlign.center,
        marginBottom: 20,
      ),
      style: StyleSheet(
        backgroundColor: Colors.teal,
        borderRadius: 20,
      ),
      children: [
          dcfIcon(name: DCFIcons.folder,color: Colors.purpleAccent, size: 100),
      dcfIcon(name: DCFIcons.edit,color: Colors.purpleAccent, size: 100),
      dcfIcon(name:'assets/logo.svg', size: 100,layout: const LayoutProps(
        margin: 20,
        height: 100,
        width: 100,
      )),
      ]
    ),

      text(
        content: "Counter: ${counterState.value}",
        textProps: TextProps(
          fontSize: 36,
          color: textColor,
          fontWeight: "bold",
        ),
        layout: const LayoutProps(
          marginBottom: 40,
        ),
      ),
      view(
        layout: const LayoutProps(
          width: '100%',
          flexDirection: YogaFlexDirection.row,
          justifyContent: YogaJustifyContent.spaceEvenly,
          alignItems: YogaAlign.center,
        ),
        children: [
          button(
            buttonProps: ButtonProps(
              title: "Decrement",
              color: const Color(0xFFFFFFFF),
              backgroundColor: counterState.value > 0 ? accentColor : const Color(0xFFAAAAAA),
            ),
            layout: const LayoutProps(
              width: 120,
              height: 50,
            ),
            onPress: () {
              if (counterState.value > 0) {
                counterState.setValue(counterState.value - 1);
              }
            },
          ),
          button(
            buttonProps: ButtonProps(
              title: "Reset",
              color: const Color(0xFFFFFFFF),
              backgroundColor: counterState.value != 0 ? const Color(0xFFFF5722) : const Color(0xFFAAAAAA),
            ),
            layout: const LayoutProps(
              width: 120,
              height: 50,
            ),
            onPress: () {
              if (counterState.value != 0) {
                counterState.setValue(0);
              }
            },
          ),
          button(
            buttonProps: ButtonProps(
              title: "Increment",
              color: const Color(0xFFFFFFFF),
              backgroundColor: accentColor,
            ),
            layout: const LayoutProps(
              width: 120,
              height: 50,
            ),
            onPress: () {
              counterState.setValue(counterState.value + 1);
            },
          ),
        ],
      ),
    ],
  );
}
