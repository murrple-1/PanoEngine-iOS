#import <OpenGLES/ES1/gl.h>

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
               GLfloat centerx, GLfloat centery, GLfloat centerz,
               GLfloat upx, GLfloat upy, GLfloat upz);

void gluPerspective(GLfloat fovy, GLfloat aspect,
                    GLfloat zNear, GLfloat zFar);

float toRadians(float degrees);

float toDegrees(float radians);
