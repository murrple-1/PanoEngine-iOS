#import "Panorama.h"

@interface CylindricalPanorama : Panorama
{
@private
	int _x;
	int _y;
}

- (id)initWithX:(int)x Y:(int)y;

- (void)setTexture:(OpenGLTexture *)texture X:(int)x Y:(int)y;
@end
