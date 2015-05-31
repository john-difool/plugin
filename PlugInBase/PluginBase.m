#import <Foundation/Foundation.h>

#import <dlfcn.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import <mach-o/dyld.h>
#import <mach-o/getsect.h>

#import "PluginBase.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

static NSString *PluginNameForClass(Class cls)
{
    NSString *name = nil;
    if ([cls respondsToSelector:@selector(pluginName)]) {
        name = [cls valueForKey:@"pluginName"];
    }
    if ([name length] == 0) {
        name = NSStringFromClass(cls);
    }
    return name;
}

static NSArray *classesByPluginID(void)
{
    static NSArray *allPlugins;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableSet *uniquePlugins = [NSMutableSet set];
        
        Dl_info info;
        dladdr(&classesByPluginID, &info);
        const uint64_t mach_header = (uint64_t)info.dli_fbase;
        const struct section_64 *section = getsectbynamefromheader_64((void *)mach_header, "__DATA", "ExportPlugin");
        if (section) {
            for (uint64_t addr = section->offset;
                 addr < section->offset + section->size;
                 addr += sizeof(const char **)) {
                
                // Get data entry
                NSString *entry = @(*(const char **)(mach_header + addr));
                NSArray *parts = [[entry substringWithRange:(NSRange){2, entry.length - 3}]
                                  componentsSeparatedByString:@" "];
                
                // Parse class name
                NSString *pluginClassName = parts[0];
                NSRange categoryRange = [pluginClassName rangeOfString:@"("];
                if (categoryRange.length) {
                    pluginClassName = [pluginClassName substringToIndex:categoryRange.location];
                }
                
                // Get class
                Class cls = NSClassFromString(pluginClassName);
                
                // Register plugin
                NSString *pluginName = PluginNameForClass(cls);
                [uniquePlugins addObject:pluginName];
            }
        }
        
        allPlugins = [uniquePlugins allObjects];
    });
    
    return allPlugins;
}

static void localPluginsConfig(void)
{
    classesByPluginID();
}


@implementation BasePlugin : NSObject 

- (instancetype)init
{
    
    if ((self = [super init])) {
        localPluginsConfig();        
    }
    return self;
}
@end

