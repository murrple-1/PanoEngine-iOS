#import "CubicPanorama.h"
#import "OpenGLTexture.h"
#import "Panorama+Protected.h"

@implementation CubicPanorama

- (id)initWithX:(int)x Y:(int)y {
	if (self = [super init]) {
		_x = x;
		_y = y;
        
		_textures = (OpenGLTexture **)calloc(self.textureCount, sizeof(OpenGLTexture *));
        
		_vertexBuffer = (float *)malloc(sizeof(float) * CubeFaceOrientationLength * _x * _y * 3 * 4);
        
		float stepM = (PanoramaR * 2.0f) / _x;
		float stepN = (PanoramaR * 2.0f) / _y;
        
		int c = 0;
		for (CubeFaceOrientation i = 0; i < CubeFaceOrientationLength; i++) {
			GLKVector3 v[4];
            
			GLKVector3 start;
            
			switch (i) {
				case FRONT:
					start.x = -PanoramaR;
					start.y = -PanoramaR;
					start.z = PanoramaR;
					break;
                    
				case BACK:
					start.x = PanoramaR;
					start.y = -PanoramaR;
					start.z = -PanoramaR;
					break;
                    
				case RIGHT:
					start.x = PanoramaR;
					start.y = -PanoramaR;
					start.z = PanoramaR;
					break;
                    
				case LEFT:
					start.x = -PanoramaR;
					start.y = -PanoramaR;
					start.z = -PanoramaR;
					break;
                    
				case UP:
					start.x = -PanoramaR;
					start.y = -PanoramaR;
					start.z = -PanoramaR;
					break;
                    
				case DOWN:
					start.x = -PanoramaR;
					start.y = PanoramaR;
					start.z = PanoramaR;
					break;
                    
				default:
					break;
			}
            
			for (int j = 0; j < _x; j++) {
				for (int m = 0; m < 4; m++) {
					v[m].x = start.x;
					v[m].y = start.y;
					v[m].z = start.z;
				}
                
				float tStepM = (stepM * (j + 1));
				switch (i) {
					case FRONT:
						v[1].x += tStepM;
						v[3].x += tStepM;
                        
						v[2].y += stepN;
						v[3].y += stepN;
						break;
                        
					case BACK:
						v[1].x += tStepM;
						v[3].x += tStepM;
                        
						v[2].y += stepN;
						v[3].y += stepN;
						break;
                        
					case RIGHT:
						v[1].y += tStepM;
						v[3].y += tStepM;
                        
						v[2].z += stepN;
						v[3].z += stepN;
						break;
                        
					case LEFT:
						v[1].y += tStepM;
						v[3].y += tStepM;
                        
						v[2].z -= stepN;
						v[3].z -= stepN;
						break;
                        
					case UP:
						v[1].x += tStepM;
						v[3].x += tStepM;
                        
						v[2].z += stepN;
						v[3].z += stepN;
						break;
                        
					case DOWN:
						v[1].x += tStepM;
						v[3].x += tStepM;
                        
						v[2].z -= stepN;
						v[3].z -= stepN;
						break;
                        
					default:
						break;
				}
                
				for (int k = 0; k < _y; k++) {
					for (int m = 0; m < 4; m++) {
						_vertexBuffer[c++] = v[m].x;
						_vertexBuffer[c++] = v[m].y;
						_vertexBuffer[c++] = v[m].z;
					}
                    
					switch (i) {
						case FRONT:
							v[2].y += stepN;
							v[3].y += stepN;
							break;
                            
						case BACK:
							v[2].y += stepN;
							v[3].y += stepN;
							break;
                            
						case RIGHT:
							v[2].z += stepN;
							v[3].z += stepN;
							break;
                            
						case LEFT:
							v[2].z -= stepN;
							v[3].z -= stepN;
							break;
                            
						case UP:
							v[2].z += stepN;
							v[3].z += stepN;
							break;
                            
						case DOWN:
							v[2].z -= stepN;
							v[3].z -= stepN;
							break;
                            
						default:
							break;
					}
				}
			}
		}
        
		_normalBuffer = (float *)malloc(sizeof(float) * CubeFaceOrientationLength * _x * _y * 3 * 4);
        
		c = 0;
		for (int i = 0; i < CubeFaceOrientationLength; i++) {
			for (int j = 0; j < _x; j++) {
				for (int k = 0; k < _y; k++) {
					for (int l = 0; l < 4; l++) {
						float nX = 0.0f;
						float nY = 0.0f;
						float nZ = 0.0f;
						switch (i) {
							case FRONT:
								nZ = 1.0f;
								break;
                                
							case BACK:
								nZ = -1.0f;
								break;
                                
							case RIGHT:
								nX = 1.0f;
								break;
                                
							case LEFT:
								nX = -1.0f;
								break;
                                
							case UP:
								nY = 1.0f;
								break;
                                
							case DOWN:
								nY = -1.0f;
								break;
						}
						_normalBuffer[c++] = nX;
						_normalBuffer[c++] = nY;
						_normalBuffer[c++] = nZ;
					}
				}
			}
		}
        
		_textureCoordBuffer = (float *)malloc(sizeof(float) * CubeFaceOrientationLength * _x * _y * 2 * 4);
        
		c = 0;
		for (int i = 0; i < CubeFaceOrientationLength; i++) {
			for (int j = 0; j < _x; j++) {
				for (int k = 0; k < _y; k++) {
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
	}
	return self;
}

- (int)textureCount {
	return CubeFaceOrientationLength * _x * _y;
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
	for (int i = 0; i < CubeFaceOrientationLength; i++) {
		for (int j = 0; j < (_x * _y); j++) {
			if ([self bindTexture:i * (_x * _y) + j]) {
				glDrawArrays(GL_TRIANGLE_STRIP, start, step);
			}
			start += step;
		}
	}
    
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_CULL_FACE);
}

- (void)setTexture:(OpenGLTexture *)texture face:(CubeFaceOrientation)face X:(int)x Y:(int)y {
	int index = (face * (_x * _y)) + (y * _x) + x;
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
