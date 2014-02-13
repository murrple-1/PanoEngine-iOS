#import "PanoramaHotspot.h"
#import "PanoramaHotspot+Protected.h"
#import "OpenGLTexture.h"

const float HotspotR = 0.5f;

@implementation PanoramaHotspot

@synthesize Id = _id;
@synthesize texture = _texture;
@synthesize x = _x;
@synthesize y = _y;
@synthesize width = _width;
@synthesize height = _height;
@synthesize data = _data;

static float vertexBuffer[] = {
	-1.0f, 1.0f, HotspotR,
	-1.0f, -1.0f, HotspotR,
	1.0f, 1.0f, HotspotR,
	1.0f, -1.0f, HotspotR
};

static float textureCoordBuffer[] = {
	0.0f, 1.0f,
	0.0f, 0.0f,
	1.0f, 1.0f,
	1.0f, 0.0f
};

static float normalBuffer[] = {
	0.0f, 0.0f, 1.0f
};

- (id)initWithId:(int)Id texture:(OpenGLTexture *)texture x:(float)x y:(float)y width:(float)width height:(float)height data:(NSString *)data {
	if (self = [super init]) {
		_id = Id;
		_texture = [texture retain];
		_x = x;
		_y = y;
		_width = width;
		_height = height;
		_data = [data retain];
	}
	return self;
}

- (void)drawHotspot {
	if ([self bindTexture]) {
		glEnable(GL_CULL_FACE);
		glCullFace(GL_BACK);
		glFrontFace(GL_CW);
        
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_NORMAL_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
		glVertexPointer(3, GL_FLOAT, 0, vertexBuffer);
		glTexCoordPointer(2, GL_FLOAT, 0, textureCoordBuffer);
		glNormalPointer(GL_FLOAT, 0, normalBuffer);
        
		glPushMatrix();
        
		glScalef(_width, _height, 1.0f);
		glRotatef(_x, 0.0f, 1.0f, 0.0f);
		glRotatef(_y, 1.0f, 0.0f, 0.0f);
        
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
		glPopMatrix();
        
		glDisable(GL_BLEND);
        
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisable(GL_CULL_FACE);
	}
}

- (void)dealloc {
	[_texture release];
	[_data release];
	[super dealloc];
}

@end
