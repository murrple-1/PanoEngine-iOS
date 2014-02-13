#import "Panorama.h"

typedef enum {
	FRONT, BACK, RIGHT, LEFT, UP, DOWN
} CubeFaceOrientation;

#define CubeFaceOrientationLength 6

@interface CubicPanorama : Panorama
{
@private
	int _x;
	int _y;
}

- (id)initWithX:(int)x Y:(int)y;

- (void)setTexture:(OpenGLTexture *)texture face:(CubeFaceOrientation)face X:(int)x Y:(int)y;
@end
