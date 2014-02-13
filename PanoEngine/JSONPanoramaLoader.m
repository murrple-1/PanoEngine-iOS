#import "JSONPanoramaLoader.h"

#import "CubicPanorama.h"
#import "CylindricalPanorama.h"
#import "OpenGLTexture.h"
#import "PanoramaCamera.h"
#import "PanoramaViewController.h"
#import "PanoramaHotspot.h"
#import "GLUtil.h"

typedef enum {
	Unknown,
	Cubic,
	Cylindrical
} PanoramaType;

@implementation JSONPanoramaLoader

#pragma mark -
#pragma mark init methods

- (id)initWithJSON:(NSDictionary *)json andUIImageLoader:(NSObject <UIImageLoader> *)loader {
	if (self = [super init]) {
		_json = [json retain];
        _loader =[loader retain];
	}
	return self;
}

#pragma mark -
#pragma mark private methods

- (OpenGLTexture *)createTexture:(NSString *)packageID {
	UIImage *image = [_loader loadImageWithAssetID:packageID];
	OpenGLTexture *texture = [[[OpenGLTexture alloc] initWithBitmap:image] autorelease];
	return texture;
}

- (void)loadCubicTexture:(NSString *)assetId panorama:(CubicPanorama *)panorama face:(CubeFaceOrientation)face X:(int)x Y:(int)y {
	OpenGLTexture *texture = [self createTexture:assetId];
	[panorama setTexture:texture face:face X:x Y:y];
}

- (void)jsonForCubicPanorama:(NSArray *)jsonArray face:(CubeFaceOrientation)face panorama:(CubicPanorama *)panorama {
	for (NSDictionary *image in jsonArray) {
		int x = [[image objectForKey:@"divX"] intValue];
		int y = [[image objectForKey:@"divY"] intValue];
		NSString *assetID = [image objectForKey:@"assetID"];
		dispatch_async(dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT),
		               ^{
                           [self loadCubicTexture:assetID panorama:panorama face:face X:x Y:y];
                       });
	}
}

- (void)loadCylindricalTexture:(NSString *)assetId panorama:(CylindricalPanorama *)panorama X:(int)x Y:(int)y {
	OpenGLTexture *texture = [self createTexture:assetId];
	[panorama setTexture:texture X:x Y:y];
}

#pragma mark -
#pragma mark PanoramaLoader methods

- (void)load:(PanoramaViewController *)view {
	if (_json) {
		Panorama *panorama = nil;
		NSString *type = [_json objectForKey:@"type"];
		PanoramaType panoramaType = Unknown;
		if (type && [type isKindOfClass:[NSString class]]) {
			if ([type isEqualToString:@"cubic"]) {
				panoramaType = Cubic;
				int subdivisionX = [[_json objectForKey:@"subdivisionX"] intValue];
				int subdivisionY = [[_json objectForKey:@"subdivisionY"] intValue];
				panorama = [[[CubicPanorama alloc] initWithX:subdivisionX Y:subdivisionY] autorelease];
			}
			else if ([type isEqualToString:@"cylindrical"]) {
				panoramaType = Cylindrical;
				int subdivisionX = [[_json objectForKey:@"subdivisionX"] intValue];
				int subdivisionY = [[_json objectForKey:@"subdivisionY"] intValue];
				panorama = [[[CylindricalPanorama alloc] initWithX:subdivisionX Y:subdivisionY] autorelease];
			}
			if (!panorama) {
				[NSException raise:@"PanoramaLoadException" format:@"Panorama type is wrong"];
			}
		}
		else {
			[NSException raise:@"PanoramaLoadException" format:@"type property not exists"];
		}
		NSDictionary *images = [_json objectForKey:@"images"];
		if (images && [images isKindOfClass:[NSDictionary class]]) {
			NSString *preview = [images objectForKey:@"preview"];
			if (preview && [preview isKindOfClass:[NSString class]]) {
				OpenGLTexture *texture = [self createTexture:preview];
				for (int i = 0; i < panorama.textureCount; i++) {
					[panorama setTexture:texture index:i];
				}
			}
            
			if (panoramaType == Cubic) {
				CubicPanorama *cPanorama = (CubicPanorama *)panorama;
                
				NSArray *imageArr = [images objectForKey:@"front"];
				[self jsonForCubicPanorama:imageArr face:FRONT panorama:cPanorama];
                
				imageArr = [images objectForKey:@"back"];
				[self jsonForCubicPanorama:imageArr face:BACK panorama:cPanorama];
                
				imageArr = [images objectForKey:@"left"];
				[self jsonForCubicPanorama:imageArr face:LEFT panorama:cPanorama];
                
				imageArr = [images objectForKey:@"right"];
				[self jsonForCubicPanorama:imageArr face:RIGHT panorama:cPanorama];
                
				imageArr = [images objectForKey:@"up"];
				[self jsonForCubicPanorama:imageArr face:UP panorama:cPanorama];
                
				imageArr = [images objectForKey:@"down"];
				[self jsonForCubicPanorama:imageArr face:DOWN panorama:cPanorama];
			}
			else if (panoramaType == Cylindrical) {
				CylindricalPanorama *cPanorama = (CylindricalPanorama *)panorama;
                
				NSArray *imageArr = [images objectForKey:@"images"];
				for (NSDictionary *image in imageArr) {
					int x = [[image objectForKey:@"divX"] intValue];
					int y = [[image objectForKey:@"divY"] intValue];
					NSString *assetID = [image objectForKey:@"assetID"];
					dispatch_async(dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT),
					               ^{
                                       [self loadCylindricalTexture:assetID panorama:cPanorama X:x Y:y];
                                   });
				}
			}
		}
		else {
			[NSException raise:@"PanoramaGL" format:@"images property not exists"];
		}
        
		NSDictionary *camera = [_json objectForKey:@"camera"];
		if (camera && [camera isKindOfClass:[NSDictionary class]]) {
			int athmin = [(NSNumber *)[camera objectForKey:@"athmin"] intValue];
			int athmax = [(NSNumber *)[camera objectForKey:@"athmax"] intValue];
			int atvmin = [(NSNumber *)[camera objectForKey:@"atvmin"] intValue];
			int atvmax = [(NSNumber *)[camera objectForKey:@"atvmax"] intValue];
			int hlookat = [(NSNumber *)[camera objectForKey:@"hlookat"] intValue];
			int vlookat = [(NSNumber *)[camera objectForKey:@"vlookat"] intValue];
            
            
			[view.camera setPitchRange_min:toRadians(atvmin) max:toRadians(atvmax)];
			[view.camera setYawRange_min:toRadians(athmin) max:toRadians(athmax)];
			[view.camera setLookAt_pitch:toRadians(vlookat) yaw:toRadians(hlookat)];
		}
		NSArray *hotspots = [_json objectForKey:@"hotspots"];
		if (hotspots && [hotspots isKindOfClass:[NSArray class]]) {
			for (NSDictionary *hotspot in hotspots) {
				if ([hotspot isKindOfClass:[NSDictionary class]]) {
					OpenGLTexture *hotspotTexture = [self createTexture:[hotspot objectForKey:@"image"]];
					int identifier = [(NSNumber *)[hotspot objectForKey:@"id"] intValue];
					int atv = [(NSNumber *)[hotspot objectForKey:@"atv"] intValue];
					int ath = [(NSNumber *)[hotspot objectForKey:@"ath"] intValue];
					float width = [(NSNumber *)[hotspot objectForKey:@"width"] floatValue];
					float height = [(NSNumber *)[hotspot objectForKey:@"height"] floatValue];
					NSString *data = [hotspot objectForKey:@"data"];
					PanoramaHotspot *currentHotspot = [[[PanoramaHotspot alloc] initWithId:identifier texture:hotspotTexture x:atv y:ath width:width height:height data:data] autorelease];
					[panorama addHotspot:currentHotspot];
				}
			}
		}
        
		NSString *sensorialRotation = [[_json objectForKey:@"gyro"] objectForKey:@"enabled"];
		if (sensorialRotation && [sensorialRotation isKindOfClass:[NSString class]]) {
			view.sensorEnabled = [sensorialRotation boolValue];
		}
        
		NSString *touchEnabled = [[_json objectForKey:@"scrolling"] objectForKey:@"enabled"];
		if (touchEnabled && [touchEnabled isKindOfClass:[NSString class]]) {
			view.touchEnabled = [touchEnabled boolValue];
		}
        
		view.panorama = panorama;
	}
}

#pragma mark -

- (void)dealloc {
	[_json release];
    [_loader release];
	[super dealloc];
}

@end
