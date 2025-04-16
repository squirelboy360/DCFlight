import 'package:dc_test/framework/packages/vdom/component/component.dart';
import 'package:dc_test/framework/packages/vdom/vdom.dart';
import 'package:dc_test/framework/utilities/screen_utilities.dart';
import 'package:flutter/material.dart';

//
// Entry point for the app
//
void startApp(Component app) {
  // Ensured method channel is initialized.
  // Previously was not required due to the use of FFI for UI manipulation at the native side
  // but method channels proved to be more efficient in communication upon proper bench marking for some reasons so MethodChannels are the way to go
  // might sound wierd but we are using a forked version of the flutter engine (flutter engine already uses ffi and jni behind the scenes but we optimise it for the minimum overhead).
  // Fan fact, thread hopping is a must for UI rendering as we saw an up to 2x performance increase in rendering time due to frequent thread hops when the vdom really needed to trigger an update while a previous operation was already updating the UI. We still batch but only if needed.
  WidgetsFlutterBinding.ensureInitialized();
  ScreenUtilities.instance.refreshDimensions();
  startNativeApp(app: app);
  // we dont need the flutter view to run to get the dart instance but this is just in case as a fallback mechanism
  // runApp(MaterialApp(
  //   home: Scaffold(
  //     body: Center(
  //       child: Wrap(
  //         children: [
  //           Text('FLUTTER BACKGROUND THREAD FOR EMBEDDING FLUTTER VIEWS'),
  //           Text(
  //               "Currently not in use, call flutter view adaptor to render in a flutter view")
  //         ],
  //       ),
  //     ),
  //   ),
  // ));
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
