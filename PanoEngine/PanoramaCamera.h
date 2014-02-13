#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface PanoramaCamera : NSObject
{
@private
	float _fov;
	float _zoomFactor;
    
	float _minPitchAngle;
	float _maxPitchAngle;
    
	float _minYawAngle;
	float _maxYawAngle;
    
	float _pitch;
	float _yaw;
    
	GLKVector3 _positionVector;
}

@property (readonly, nonatomic) float fov;
@property (readwrite, nonatomic) float zoomFactor;
@property (readonly, nonatomic) float adjustedFOV;

@property (readonly, nonatomic) GLKVector3 lookAtVector;

@property (readonly, nonatomic) GLKVector3 positionVector;
@property (readwrite, nonatomic) float positionX;
@property (readwrite, nonatomic) float positionY;
@property (readwrite, nonatomic) float positionZ;

@property (readonly, nonatomic) float pitch;
@property (readonly, nonatomic) float yaw;

- (id)initWithFOV:(float)fov AndZoomFactor:(float)zoom;

- (void)rotatePitch:(float)rotateRad;
- (void)rotateYaw:(float)rotateRad;

- (void)setPitchRange_min:(float)min max:(float)max;
- (void)setYawRange_min:(float)min max:(float)max;

- (void)setLookAt_pitch:(float)pitch yaw:(float)yaw;

@end
