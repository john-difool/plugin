#import <Foundation/Foundation.h>
#import <PlugInBase/PlugInBase.h>

@interface Plugin2 : NSObject <Plugin>

@end

@implementation Plugin2

+ (NSString *)pluginName {
    __attribute__((used, section("__DATA,ExportPlugIn" )))
    static const char *__export_entry__ = { __func__ };
    return @"";
}


@end