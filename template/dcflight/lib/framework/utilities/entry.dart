import 'package:dcflight/framework/packages/vdom/component/component.dart';
import 'package:dcflight/framework/packages/vdom/vdom.dart';
import 'package:dcflight/framework/utilities/screen_utilities.dart';
import 'package:flutter/material.dart';

void initializeApplication(Component app) {
  //
  // Entry point for the app
  //
  WidgetsFlutterBinding.ensureInitialized();
  // Ensured method channel is initialized.
  // Previously was not required due to the use of FFI for UI manipulation at the native side
  // but method channels proved to be more efficient in communication upon proper bench marking for some reasons so MethodChannels are the way to go
  // might sound wierd but we are using a forked version of the flutter engine (flutter engine already uses ffi and jni behind the scenes but we optimise it for the minimum overhead).
  // Fan fact, thread hopping is a must for UI rendering as we saw an up to 2x performance increase in rendering time due to frequent thread hops when the vdom really needed to trigger an update while a previous operation was already updating the UI. We still batch but only if needed.
  ScreenUtilities.instance.refreshDimensions();
  startNativeApp(app: app);
}

void startNativeApp({required Component app}) async {
  // Create VDOM instance
  final vdom = VDom();
  // Create our main app component
  final Component mainApp = app;
  // Create a component node
  final appNode = vdom.createComponent(mainApp);
  // Render the component to native UI
  await vdom.renderToNative(appNode, parentId: "root", index: 0);
  // Wait for the VDom to be ready
  vdom.isReady.whenComplete(() async {
    debugPrint('VDOM is ready to calculate ');
    await vdom.calculateAndApplyLayout().then((v) {
      debugPrint('VDOM layout applied from enry point');
    });
  });
}
// Todo: Dev tools setup
