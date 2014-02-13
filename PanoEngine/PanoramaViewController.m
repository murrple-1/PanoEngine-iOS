#import "PanoramaViewController.h"
#import "JSONPanoramaLoader.h"
#import "Panorama.h"
#import "GLUtil.h"
#import "PanoramaCamera.h"
#import "PanoramaHotspot.h"
#import "JSONKit.h"

static float ZNEAR = 0.01f;
static float ZFAR = 100.0f;
static float ZOOM_FACTOR = 0.0005f;
static float MAX_ZOOM = 2.0f;
static float MIN_ZOOM = 0.5f;
static double TIMER_STEP = 0.01;
static float DRAG_RADIUS = 100.0f;
static float DRAG_FACTOR = 0.0001f;
static float SENSOR_FACTOR = 0.05f;

@implementation PanoramaViewController

@synthesize panorama = _panorama;
@synthesize camera = _camera;
@synthesize sensorEnabled = _sensorEnabled;
@synthesize touchEnabled = _touchEnabled;

- (id)initWithParameters:(NSString *)parameters andUIImageLoader:(NSObject<UIImageLoader> *)loader {
	if (self = [super init]) {
		_camera = [[PanoramaCamera alloc] initWithFOV:45.0f AndZoomFactor:0.5f];
		_sensorEnabled = NO;
		_touchEnabled = YES;
        
		_initialTouches = [[NSMutableArray alloc] init];
		NSDictionary *json = parameters.objectFromJSONString;
		NSObject <PanoramaLoader> *pLoader = [[[JSONPanoramaLoader alloc] initWithJSON:json andUIImageLoader:loader] autorelease];
		[pLoader load:self];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	self.view.multipleTouchEnabled = YES;
    
	[self setupGL];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	_skipSensor = YES;
	[_motionManager release];
	_motionManager = [[CMMotionManager alloc] init];
	_motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    
	if (_motionManager.isDeviceMotionAvailable) {
		NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
		[_motionManager startDeviceMotionUpdatesToQueue:queue withHandler: ^(CMDeviceMotion *motion, NSError *error) {
		    [self handleDeviceMotion:motion error:error];
		}];
	}
    
	[_timer invalidate];
	[_timer release];
	_timer = [[NSTimer scheduledTimerWithTimeInterval:TIMER_STEP target:self selector:@selector(doTimer:) userInfo:nil repeats:YES] retain];
}

- (void)setupGL {
	_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
	GLKView *glView = (GLKView *)self.view;
	glView.context = _context;
    
	[EAGLContext setCurrentContext:_context];
    
	glEnable(GL_TEXTURE_2D);
	glShadeModel(GL_SMOOTH);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClearDepthf(1.0f);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_touchEnabled) {
		for (UITouch *touch in touches) {
			CGPoint point = [touch locationInView:self.view];
			NSValue *value = [NSValue valueWithCGPoint:point];
			[_initialTouches addObject:value];
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_touchEnabled) {
		NSArray *viewTouches = [[event touchesForView:self.view] allObjects];
		switch (_initialTouches.count) {
			case 0:
			{
				for (UITouch *touch in viewTouches) {
					CGPoint point = [touch locationInView:self.view];
					NSValue *value = [NSValue valueWithCGPoint:point];
					[_initialTouches addObject:value];
				}
				break;
			}
                
			case 1:
			{
				CGPoint initialPoint = [[_initialTouches objectAtIndex:0] CGPointValue];
				CGPoint newPoint = [[viewTouches objectAtIndex:0] locationInView:self.view];
                
				CGFloat xDist = initialPoint.x - newPoint.x;
				CGFloat yDist = initialPoint.y - newPoint.y;
                
				CGFloat dist = sqrtf((xDist * xDist) + (yDist * yDist));
				if (dist > DRAG_RADIUS) {
					xDist = (xDist / dist) * DRAG_RADIUS;
					yDist = (yDist / dist) * DRAG_RADIUS;
				}
                
				[_yawStep release];
				_yawStep = [[NSNumber alloc] initWithFloat:xDist * DRAG_FACTOR];
				[_pitchStep release];
				_pitchStep = [[NSNumber alloc] initWithFloat:(-yDist * DRAG_FACTOR)];
				break;
			}
                
			case 2:
			{
				CGPoint iPoint1 = [[_initialTouches objectAtIndex:0] CGPointValue];
				CGPoint iPoint2 = [[_initialTouches objectAtIndex:1] CGPointValue];
                
				CGPoint nPoint1 = [[viewTouches objectAtIndex:0] locationInView:self.view];
				CGPoint nPoint2 = [[viewTouches objectAtIndex:1] locationInView:self.view];
                
				CGFloat xDist1 = iPoint1.x - iPoint2.x;
				CGFloat yDist1 = iPoint1.y - iPoint2.y;
                
				CGFloat dist1 = sqrtf((xDist1 * xDist1) + (yDist1 * yDist1));
                
				CGFloat xDist2 = nPoint1.x - nPoint2.x;
				CGFloat yDist2 = nPoint1.y - nPoint2.y;
                
				CGFloat dist2 = sqrtf((xDist2 * xDist2) + (yDist2 * yDist2));
                
				CGFloat distDiff = dist2 - dist1;
				CGFloat zoomFactor = distDiff * ZOOM_FACTOR;
                
				[_zoomStep release];
				_zoomStep = [[NSNumber alloc] initWithFloat:zoomFactor];
                
				break;
			}
                
			default:
				break;
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_touchEnabled) {
		if (_initialTouches.count == 1) {
			CGPoint initialTouchPoint = [[_initialTouches objectAtIndex:0] CGPointValue];
			CGPoint newTouchPoint = [[touches anyObject] locationInView:self.view];
            
			CGFloat xDiff = ABS(initialTouchPoint.x - newTouchPoint.x);
			CGFloat yDiff = ABS(initialTouchPoint.y - newTouchPoint.y);
			if (xDiff < 10.0f && yDiff < 10.0f) {
                
                GLKVector3 positionVec = _camera.positionVector;
                GLKVector3 lookAtVec = _camera.lookAtVector;
                GLKMatrix4 view = GLKMatrix4MakeLookAt(positionVec.x, positionVec.y, positionVec.z, lookAtVec.x, lookAtVec.y, lookAtVec.z, 0.0f, 1.0f, 0.0f);
                
                GLKMatrix4 projection = GLKMatrix4MakePerspective(toRadians(_camera.adjustedFOV), self.view.frame.size.width / self.view.frame.size.height, ZNEAR, ZFAR);
                
                for(PanoramaHotspot *hotspot in _panorama.hotspots)
                {
                    GLKVector4 points[4];
                    points[0] = GLKVector4Make(-1.0f, -1.0f, HotspotR, 1.0f);
                    points[1] = GLKVector4Make(1.0f, -1.0f, HotspotR, 1.0f);
                    points[2] = GLKVector4Make(1.0f, 1.0f, HotspotR, 1.0f);
                    points[3] = GLKVector4Make(-1.0f, 1.0f, HotspotR, 1.0f);
                    
                    GLKMatrix4 model = GLKMatrix4MakeScale(hotspot.width, hotspot.height, 1.0f);
                    model = GLKMatrix4RotateX(model, hotspot.x);
                    model = GLKMatrix4RotateY(model, hotspot.y);
                    
                    GLKMatrix4MultiplyVector4Array(GLKMatrix4Multiply(projection, GLKMatrix4Multiply(view, model)), points, 4);
                    
                    CGMutablePathRef path = CGPathCreateMutable();
                    float width = self.view.frame.size.width;
                    float height = self.view.frame.size.height;
                    float halfWidth = width * 0.5f;
                    float halfHeight = height * 0.5f;
                    float new_x = (points[0].x * width) / (2.0f * points[0].w) + halfWidth;
                    float new_y = height - ((points[0].y * height) / (2.0f * points[0].w) + halfHeight);
                    CGPathMoveToPoint(path, NULL, new_x, new_y);
                    for(int i = 1; i < 4; i++) {
                        new_x = (points[i].x * width) / (2.0f * points[i].w) + halfWidth;
                        new_y = height - ((points[i].y * height) / (2.0f * points[i].w) + halfHeight);
                        CGPathAddLineToPoint(path, NULL, new_x, new_y);
                    }
                    
                    BOOL contains = CGPathContainsPoint(path, NULL, newTouchPoint, false);
                    CFRelease(path);
                    
                    if(contains) {
                        [_panorama didTouchHotspot:hotspot];
                        break;
                    }
                    
                }
			}
		}
        
		[_pitchStep release];
		_pitchStep = nil;
		[_yawStep release];
		_yawStep = nil;
		[_zoomStep release];
		_zoomStep = nil;
        
		[_initialTouches removeAllObjects];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_touchEnabled) {
		[_pitchStep release];
		_pitchStep = nil;
		[_yawStep release];
		_yawStep = nil;
		[_zoomStep release];
		_zoomStep = nil;
        
		[_initialTouches removeAllObjects];
	}
}

- (void)handleDeviceMotion:(CMDeviceMotion *)motion error:(NSError *)error {
	if (_sensorEnabled) {
		CMAttitude *att = motion.attitude;
		if (_skipSensor) {
			_skipSensor = NO;
		}
		else if (!_initialPitch && !_initialRoll) {
			_initialPitch = [[NSNumber alloc] initWithFloat:(float)att.pitch];
			_initialRoll = [[NSNumber alloc] initWithFloat:(float)att.roll];
		}
		else {
			if (_initialTouches.count < 1) {
				float pitch = ([_initialPitch floatValue] - att.pitch) * SENSOR_FACTOR;
				float roll = ([_initialRoll floatValue] - att.roll) * SENSOR_FACTOR;
				[_pitchStep release];
				_pitchStep = [[NSNumber alloc] initWithFloat:pitch];
				[_yawStep release];
				_yawStep = [[NSNumber alloc] initWithFloat:roll];
			}
		}
	}
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	if (_panorama) {
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(_camera.adjustedFOV, view.frame.size.width / view.frame.size.height, ZNEAR, ZFAR);
        
		glMatrixMode(GL_MODELVIEW);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glLoadIdentity();
        
		GLKVector3 lookAt = _camera.lookAtVector;
		GLKVector3 position = _camera.positionVector;
		gluLookAt(position.x, position.y, position.z, lookAt.x, lookAt.y, lookAt.z, 0.0f, 1.0f, 0.0f);
        
		[_panorama drawFrame];
	}
}

- (void)doTimer:(id)sender {
	if (_pitchStep) {
		[_camera rotatePitch:[_pitchStep floatValue]];
	}
    
	if (_yawStep) {
		[_camera rotateYaw:[_yawStep floatValue]];
	}
    
	if (_zoomStep) {
		float zoom = _camera.zoomFactor + [_zoomStep floatValue];
		if (zoom > MAX_ZOOM) {
			zoom = MAX_ZOOM;
		}
		else if (zoom < MIN_ZOOM) {
			zoom = MIN_ZOOM;
		}
		_camera.zoomFactor = zoom;
	}
}

- (void)dealloc {
	[_panorama release];
	[_camera release];
	[_context release];
	[_initialTouches release];
    
	[_motionManager release];
	[_timer invalidate];
	[_timer release];
    
	[_initialPitch release];
	[_initialRoll release];
    
	[_pitchStep release];
	[_yawStep release];
	[_zoomStep release];
	[super dealloc];
}

@end
