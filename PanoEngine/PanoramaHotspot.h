#import <GLKit/GLKit.h>

@class OpenGLTexture;

extern const float HotspotR;

@interface PanoramaHotspot : NSObject
{
@private
	int _id;
	OpenGLTexture *_texture;
	float _x;
	float _y;
	float _width;
	float _height;
	NSString *_data;
}

@property (readonly, nonatomic) int Id;
@property (readonly, nonatomic) OpenGLTexture *texture;
@property (readonly, nonatomic) float x;
@property (readonly, nonatomic) float y;
@property (readonly, nonatomic) float width;
@property (readonly, nonatomic) float height;
@property (readonly, nonatomic) NSString *data;

- (id)initWithId:(int)Id texture:(OpenGLTexture *)texture x:(float)x y:(float)y width:(float)width height:(float)height data:(NSString *)data;

- (void)drawHotspot;

@end
