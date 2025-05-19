import 'package:dcflight/framework/renderer/vdom/component/store.dart';

final globalCounterState = StoreHelpers.createGlobalStore<int>(
  'globalCounterState',
  0,
);