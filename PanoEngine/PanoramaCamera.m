#import "PanoramaCamera.h"

@implementation PanoramaCamera

- (id)initWithFOV:(float)fov AndZoomFactor:(float)zoom {
	if (self = [super init]) {
		_pitch = 0.0f;
		_yaw = 0.0f;
        
		_minPitchAngle = -(M_PI * 0.5f);
		_maxPitchAngle = M_PI * 0.5f;
        
		_minYawAngle = -M_PI;
		_maxPitchAngle = M_PI;
        
		_fov = fov;
		_zoomFactor = zoom;
	}
	return self;
}

@synthesize fov = _fov;
@synthesize zoomFactor = _zoomFactor;

- (float)adjustedFOV {
	return _fov / _zoomFactor;
}

- (GLKVector3)lookAtVector {
	GLKVector3 vector = { 0.0f, 0.0f, 1.0f };
	GLKMatrix3 matrix = GLKMatrix3Identity;
	matrix = GLKMatrix3Rotate(matrix, _pitch, 1.0f, 0.0f, 0.0f);
	matrix = GLKMatrix3Rotate(matrix, _yaw, 0.0f, 1.0f, 0.0f);
	vector = GLKMatrix3MultiplyVector3(matrix, vector);
	return vector;
}

- (float)positionX {
	return _positionVector.x;
}

- (void)setPositionX:(float)positionX {
	_positionVector.x = positionX;
}

- (float)positionY {
	return _positionVector.y;
}

- (void)setPositionY:(float)positionY {
	_positionVector.y = positionY;
}

- (float)positionZ {
	return _positionVector.z;
}

- (void)setPositionZ:(float)positionZ {
	_positionVector.z = positionZ;
}

@synthesize pitch = _pitch;
@synthesize yaw = _yaw;

- (void)rotatePitch:(float)rotateRad {
	float tPitch = _pitch + rotateRad;
	if (tPitch > _maxPitchAngle) {
		_pitch = _maxPitchAngle;
	}
	else if (tPitch < _minPitchAngle) {
		_pitch = _minPitchAngle;
	}
	else {
		_pitch = tPitch;
	}
    
	if (_pitch >= (M_PI * 0.5f)) {
		_pitch = (M_PI * 0.5f) * 0.99f;
	}
	else if (tPitch <= -(M_PI * 0.5f)) {
		_pitch = -(M_PI * 0.5f) * 0.99f;
	}
}

- (void)rotateYaw:(float)rotateRad {
	const float twoPi = M_PI * 2.0f;
	const float threshold = 0.001f;
	const float minThres = twoPi - threshold;
	const float maxThres = twoPi + threshold;
    
	float t1 = _minYawAngle - _maxYawAngle;
	float t2 = _maxYawAngle - _minYawAngle;
    
	BOOL wrapAround = _minYawAngle == _maxYawAngle || (t1 >= minThres && t1 <= maxThres) || (t2 >= minThres && t2 <= maxThres);
	float tYaw = _yaw + rotateRad;
	if (wrapAround) {
		_yaw = tYaw;
	}
	else if (tYaw < _minYawAngle) {
		_yaw = _minYawAngle;
	}
	else if (tYaw > _maxYawAngle) {
		_yaw = _maxYawAngle;
	}
	else {
		_yaw = tYaw;
	}
}

- (void)setPitchRange_min:(float)min max:(float)max {
	_minPitchAngle = min;
	_maxPitchAngle = max;
}

- (void)setYawRange_min:(float)min max:(float)max {
	_minYawAngle = min;
	_maxYawAngle = max;
}

- (void)setLookAt_pitch:(float)pitch yaw:(float)yaw {
	_pitch = pitch;
	_yaw = yaw;
}

@end
