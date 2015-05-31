#import <Foundation/Foundation.h>
#import "PluginBase.h"


@interface Plugin1 : NSObject <Plugin>

@end

@implementation Plugin1

+ (NSString *)pluginName {
    __attribute__((used, section("__DATA,ExportPlugin" )))
    static const char *__export_entry__ = { __func__ };
    return @"";
}


@end