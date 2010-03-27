//
//  Obj3D.h
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ES2Renderer.h"
#import "btBulletDynamicsCommon.h"
//#import "ArcBall.h"


@interface Obj3D : NSObject 
{
	
	
	// Attribute locations
	GLuint	positionLoc, colorLoc;
	// Uniform locations
	GLuint  mvpLoc;
	
	GLuint program;
	
	ESMatrix  mvpMatrix;
	ESMatrix  tfMatrix;
	
	Vec3f position;
	Vec3f velocity, acceleration;
//	Matrix3fT rotation;
	float rx, ry, rz;
	
	btRigidBody *body;
}

@property float rx;
@property float ry;
@property float rz;
@property GLuint program;
@property Vec3f position;

-(void) update:(double)dt pMatrix:(ESMatrix*)p;
-(void) render;
-(void) setPos:(Vec3f)pos;
-(Vec3f) pos;
-(ESMatrix*) tfMatrix;

@end
