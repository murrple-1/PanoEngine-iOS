#import "Panorama.h"
#import "Panorama+Protected.h"
#import "PanoramaHotspot.h"

const float PanoramaR = 1.0f;

@implementation Panorama

@synthesize hotspots = _hotspots;

- (id)init {
	if (self = [super init]) {
		_hotspots = [[NSMutableArray alloc] init];
        _hotspotListeners = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)drawFrame {
	[self drawPanorama];
	for (PanoramaHotspot *hotspot in _hotspots) {
		[hotspot drawHotspot];
	}
}

- (void)setTexture:(OpenGLTexture *)texture index:(int)index {
	[_textures[index] release];
	_textures[index] = [texture retain];
}

- (int)textureCount {
	return 0;
}

- (void)addHotspot:(PanoramaHotspot *)hotspot {
	[_hotspots addObject:hotspot];
}

- (void)removeHotspot:(PanoramaHotspot *)hotspot {
	[_hotspots removeObject:hotspot];
}

- (void)registerHotspotTouchListener:(id<PanoramaHotspotTouchListener>)listener {
    [_hotspotListeners addObject:listener];
}

- (void)deregisterHotspotTouchListener:(id<PanoramaHotspotTouchListener>)listener {
    [_hotspotListeners removeObject:listener];
}

- (void)didTouchHotspot:(PanoramaHotspot *)hotspot {
    for(id<PanoramaHotspotTouchListener> listener in _hotspotListeners) {
        [listener didTouchHotspot:hotspot];
    }
}

- (void)dealloc {
	[_hotspots release];
    [_hotspotListeners release];
	[super dealloc];
}

@end
