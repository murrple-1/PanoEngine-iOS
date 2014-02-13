#import <Foundation/Foundation.h>

@class PanoramaHotspot;

@protocol PanoramaHotspotTouchListener <NSObject>

- (void)didTouchHotspot:(PanoramaHotspot *)hotspot;

@end
