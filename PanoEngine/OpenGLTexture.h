#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface OpenGLTexture : NSObject
{
	UIImage *_image;
	BOOL _useMipmaps;
	GLuint *_textureBuffer;
    
	EAGLContext *_contextCache;
}
@property (readonly, nonatomic) int textureID;

- (id)initWithBitmap:(UIImage *)image;
- (id)initWithBitmap:(UIImage *)image AndUseMipMaps:(BOOL)useMipmaps;

@end
