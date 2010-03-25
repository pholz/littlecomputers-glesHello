//
//  Obj3D.m
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Obj3D.h"



@implementation Obj3D

@synthesize rx;
@synthesize ry;
@synthesize rz;
@synthesize program;

-(void) update:(double)dt pMatrix:(ESMatrix*)p
{
	
}
-(void) render
{
	
}
-(void) setPos:(Vec3f )pos
{
	position = pos;
}
-(Vec3f) pos
{
	return position;
}
-(ESMatrix*) tfMatrix
{
	return &tfMatrix;
}
@end
