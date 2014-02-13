#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>
#import "UIImageLoader.h"

@class Panorama;
@class PanoramaCamera;

@interface PanoramaViewController : GLKViewController
{
@private
	Panorama *_panorama;
	PanoramaCamera *_camera;
    
	BOOL _sensorEnabled;
	BOOL _touchEnabled;
    
	EAGLContext *_context;
    
	NSMutableArray *_initialTouches;
    
	BOOL _skipSensor;
	NSNumber *_initialPitch;
	NSNumber *_initialRoll;
    
	NSNumber *_pitchStep;
	NSNumber *_yawStep;
	NSNumber *_zoomStep;
    
	NSTimer *_timer;
    
	CMMotionManager *_motionManager;
}

@property (readwrite, nonatomic, retain) Panorama *panorama;
@property (readonly, nonatomic) PanoramaCamera *camera;

@property (readwrite, nonatomic) BOOL sensorEnabled;
@property (readwrite, nonatomic) BOOL touchEnabled;

- (id)initWithParameters:(NSString *)parameters andUIImageLoader:(NSObject <UIImageLoader> *)loader;

@end
