#import <Foundation/Foundation.h>
#import "PanoramaHotspotTouchListener.h"

@class OpenGLTexture;
@class PanoramaHotspot;

extern const float PanoramaR;

@interface Panorama : NSObject
{
@private
	NSMutableArray *_hotspots;
    NSMutableArray *_hotspotListeners;
    
@protected
	OpenGLTexture **_textures;
	float *_vertexBuffer;
	float *_textureCoordBuffer;
	float *_normalBuffer;
	float *_colorBuffer;
	char *_indexBuffer;
}

@property (readonly, nonatomic) NSArray *hotspots;
@property (readonly, nonatomic) int textureCount;

- (void)drawFrame;

- (void)setTexture:(OpenGLTexture *)texture index:(int)index;

- (void)addHotspot:(PanoramaHotspot *)hotspot;
- (void)removeHotspot:(PanoramaHotspot *)hotspot;

- (void)registerHotspotTouchListener:(id<PanoramaHotspotTouchListener>)listener;
- (void)deregisterHotspotTouchListener:(id<PanoramaHotspotTouchListener>)listener;
- (void)didTouchHotspot:(PanoramaHotspot *)hotspot;

@end
