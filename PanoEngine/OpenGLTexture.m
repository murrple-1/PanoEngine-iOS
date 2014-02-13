#import "OpenGLTexture.h"

@implementation OpenGLTexture

- (id)initWithBitmap:(UIImage *)image {
	return [self initWithBitmap:image AndUseMipMaps:NO];
}

- (id)initWithBitmap:(UIImage *)image AndUseMipMaps:(BOOL)useMipmaps {
	if (self = [super init]) {
		_image = [image retain];
		_useMipmaps = useMipmaps;
		_textureBuffer = NULL;
		_contextCache = nil;
	}
	return self;
}

- (int)textureID {
	if (_textureBuffer == NULL) {
		[self loadTexture];
	}
    
	if (_textureBuffer != NULL) {
		if (_contextCache == [EAGLContext currentContext]) {
			return _textureBuffer[0];
		}
		else {
			free(_textureBuffer);
			[_contextCache release];
			[self loadTexture];
		}
	}
    
	return -1;
}

- (void)loadTexture {
	if (_image) {
		_textureBuffer = (GLuint *)malloc(sizeof(GLuint));
		_contextCache = [[EAGLContext currentContext] retain];
        
		glGenTextures(1, _textureBuffer);
		glBindTexture(GL_TEXTURE_2D, _textureBuffer[0]);
        
		glTexParameterx(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameterx(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
		GLsizei width = _image.size.width;
		GLsizei height = _image.size.height;
        
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		void *imageData = calloc(height * width, 4);
		CGContextRef imgContext = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		CGContextDrawImage(imgContext, CGRectMake(0, 0, width, height), _image.CGImage);
        
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        
		CGContextRelease(imgContext);
		free(imageData);
        
		if (_useMipmaps) {
			glGenerateMipmap(GL_TEXTURE_2D);
		}
	}
}

- (void)dealloc {
	if (_textureBuffer != NULL) {
		free(_textureBuffer);
	}
	[_contextCache release];
	[_image release];
	[super dealloc];
}

@end
