#import <Flutter/Flutter.h>

@interface DcfPrimitives : NSObject <FlutterPlugin>
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
+ (void)registerComponents;
@end