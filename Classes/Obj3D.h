//
//  Obj3D.h
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ES2Renderer.h"
//#import "ArcBall.h"


@interface Obj3D : NSObject 
{
	
	
	// Attribute locations
	GLuint	  positionLoc, colorLoc;
	// Uniform locations
	GLuint  mvpLoc;
	
	GLuint program;
	
	ESMatrix  mvpMatrix;
	
	Vec3f position, velocity, acceleration;
//	Matrix3fT rotation;
	float rx, ry, rz;
	
	
}

@property float rx;
@property float ry;
@property float rz;

-(void) update:(double)dt pMatrix:(ESMatrix*)p;
-(void) render;
-(void) setPos:(Vec3f)pos;
-(Vec3f) pos;

@end
