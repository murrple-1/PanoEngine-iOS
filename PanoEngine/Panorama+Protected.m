#import "Panorama+Protected.h"
#import "OpenGLTexture.h"

@implementation Panorama (Protected)

- (BOOL)bindTexture:(int)index {
	OpenGLTexture *texture = _textures[index];
	if (texture) {
		int textureID = texture.textureID;
		glBindTexture(GL_TEXTURE_2D, textureID);
		return YES;
	}
	else {
		return NO;
	}
}

- (void)drawPanorama {
	// do nothing
}

@end
