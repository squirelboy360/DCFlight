import 'package:dc_test/framework/packages/vdom/component.dart';
import 'package:dc_test/framework/packages/vdom/vdom.dart';
import 'package:flutter/material.dart';

startApp(Component app) {
  WidgetsFlutterBinding.ensureInitialized();
  startNativeApp(app: app);
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Wrap(
          children: [
            Text('FLUTTER BACKGROUND THREAD FOR EMBEDDING FLUTTER VIEWS'),
            Text(
                "Currently not in use, call flutter view adaptor to render in a flutter view")
          ],
        ),
      ),
    ),
  ));
}

void startNativeApp({required Component app}) async {
  // Create VDOM instance
  final vdom = VDom();
  // Wait for the VDom to be ready
  await vdom.isReady.whenComplete(() {
    print('VDOM is ready with values ');
    vdom.calculateAndApplyLayout().then((v) {
      print('VDOM layout applied with value');
    });
  });
  debugPrint('VDom/UICoordinator is ready');

  // Create our main app component
  final Component mainApp = app;
  // Create a component node
  final appNode = vdom.createComponent(mainApp);
  // Render the component to native UI
  await vdom.renderToNative(appNode, parentId: "root", index: 0);
}
// Todo: Dev tools setup
