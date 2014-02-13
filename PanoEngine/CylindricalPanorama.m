#import "CylindricalPanorama.h"
#import "OpenGLTexture.h"
#import "Panorama+Protected.h"

@implementation CylindricalPanorama

- (id)initWithX:(int)x Y:(int)y {
	if (self = [super init]) {
		_x = x;
		_y = y;
        
		_textures = (OpenGLTexture **)calloc(self.textureCount, sizeof(OpenGLTexture *));
        
		_vertexBuffer = (float *)malloc(sizeof(float) * _x * _y * 3 * 4);
		float radianStep = (M_PI * 2) / _x;
		float hStep = (PanoramaR * 2.0f) / _y;
        
		GLKVector3 startVector;
		startVector.x = 0.0f;
		startVector.y = 0.0f;
		startVector.z = PanoramaR;
        
		GLKMatrix3 rotation = GLKMatrix3Identity;
		rotation = GLKMatrix3Rotate(rotation, radianStep, 0.0f, 1.0f, 0.0f);
        
		GLKVector3 endVector;
		endVector = GLKMatrix3MultiplyVector3(rotation, startVector);
        
		int c = 0;
		for (int i = 0; i < _x; i++) {
			float startH = -PanoramaR;
			for (int j = 0; j < _y; j++) {
				_vertexBuffer[c++] = startVector.x;
				_vertexBuffer[c++] = startH + hStep;
				_vertexBuffer[c++] = startVector.z;
                
				_vertexBuffer[c++] = startVector.x;
				_vertexBuffer[c++] = startH;
				_vertexBuffer[c++] = startVector.z;
                
				_vertexBuffer[c++] = endVector.x;
				_vertexBuffer[c++] = startH + hStep;
				_vertexBuffer[c++] = endVector.z;
                
				_vertexBuffer[c++] = endVector.x;
				_vertexBuffer[c++] = startH;
				_vertexBuffer[c++] = endVector.z;
                
				startH += hStep;
			}
			startVector = endVector;
			endVector = GLKMatrix3MultiplyVector3(rotation, startVector);
		}
        
		_normalBuffer = (float *)malloc(sizeof(float) * _x * _y * 3 * 4);
        
		startVector.x = 0.0f;
		startVector.y = 0.0f;
		startVector.z = -PanoramaR;
        
		c = 0;
		for (int i = 0; i < _x; i++) {
			for (int j = 0; j < _y; j++) {
				for (int k = 0; k < 4; k++) {
					_normalBuffer[c++] = startVector.x;
					_normalBuffer[c++] = startVector.y;
					_normalBuffer[c++] = startVector.z;
				}
			}
			startVector = GLKMatrix3MultiplyVector3(rotation, startVector);
		}
        
		_textureCoordBuffer = (float *)malloc(sizeof(float) * _x * _y * 2 * 4);
        
		c = 0;
		for (int i = 0; i < _x; i++) {
			for (int j = 0; j < _y; j++) {
				_textureCoordBuffer[c++] = 1.0f;
				_textureCoordBuffer[c++] = 0.0f;
                
				_textureCoordBuffer[c++] = 1.0f;
				_textureCoordBuffer[c++] = 1.0f;
                
				_textureCoordBuffer[c++] = 0.0f;
				_textureCoordBuffer[c++] = 0.0f;
                
				_textureCoordBuffer[c++] = 0.0f;
				_textureCoordBuffer[c++] = 1.0f;
			}
		}
	}
	return self;
}

- (int)textureCount {
	return _x * _y;
}

- (void)drawPanorama {
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	glFrontFace(GL_CW);
    
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
	glVertexPointer(3, GL_FLOAT, 0, _vertexBuffer);
	glTexCoordPointer(2, GL_FLOAT, 0, _textureCoordBuffer);
	glNormalPointer(GL_FLOAT, 0, _normalBuffer);
    
	int start = 0;
	const int step = 4;
    
	for (int i = 0; i < _x; i++) {
		for (int j = 0; j < _y; j++) {
			if ([self bindTexture:(i * _y) + j]) {
				glDrawArrays(GL_TRIANGLE_STRIP, start, step);
			}
			start += step;
		}
	}
    
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_CULL_FACE);
}

- (void)setTexture:(OpenGLTexture *)texture X:(int)x Y:(int)y {
	int index = (x * _y) + y;
	[_textures[index] release];
	_textures[index] = [texture retain];
}

- (void)dealloc {
	for (int i = 0; i < self.textureCount; i++) {
		[_textures[i] release];
	}
	free(_textures);
	free(_vertexBuffer);
	free(_normalBuffer);
	free(_textureCoordBuffer);
	[super dealloc];
}

@end
