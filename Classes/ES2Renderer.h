//
//  ES2Renderer.h
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#include <vector.h>
#import "ESRenderer.h"

#include "ArcBall.h"
#import "common.h"
#import "Shader.h"
class Physics;
class World;

#define VERTEX_POS_INDX	0 
#define VERTEX_COLOR_INDX	1 

class Obj3D;


@interface ES2Renderer : NSObject <ESRenderer>
{
@public
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer, depthRenderbuffer;
	
	NSMutableDictionary *shaders;
	GLuint program;
	
	// Attribute locations
	GLuint	  positionLoc, colorLoc;
	// Uniform locations
	GLuint  mvpLoc;
	
	std::vector<Obj3D*> objects;
	
	// handle touch
	CGPoint last;
	float rotx, roty;
	
	Matrix4fT	Transform ;
	
	Matrix3fT	LastRot;   
	
	Matrix3fT	ThisRot;   
	
	Point2fT	MousePt;

	float lastAccX, lastAccY, lastAccZ;
	
	ArcBallT arcball;
	
	World *world;
	Physics *physics;
	
	float angle;
}

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) glerr:(NSString*)msg;
- (void) initPhysics;
- (void) setLastAccelerationX:(float)x Y:(float)y Z:(float)z;


@end

