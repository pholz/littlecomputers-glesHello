/*
 *  Shader.cpp
 *  glesHello
 *
 *  Created by Peter Holzkorn on 24.03.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Shader.h"

@implementation Shader

@synthesize name;
@synthesize program;
@synthesize positionLoc;
@synthesize colorLoc;
@synthesize mvpLoc;

-(id)initWithName:(NSString*)_name
{
	self = [super init];
	name = _name;
	[name retain];
	
	return self;
}

@end