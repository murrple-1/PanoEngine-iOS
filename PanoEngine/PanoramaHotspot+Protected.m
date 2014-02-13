#import "PanoramaHotspot+Protected.h"
#import "OpenGLTexture.h"

@implementation PanoramaHotspot (Protected)

- (BOOL)bindTexture {
	if (_texture != nil) {
		int textureId = _texture.textureID;
		glBindTexture(GL_TEXTURE_2D, textureId);
		return YES;
	}
	else {
		return NO;
	}
}

@end
