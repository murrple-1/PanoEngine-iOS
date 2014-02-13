#import <Foundation/Foundation.h>

@class PanoramaViewController;

@protocol PanoramaLoader <NSObject>

- (void)load:(PanoramaViewController *)view;

@end
