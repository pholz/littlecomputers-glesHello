/*
 *  common.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 21.02.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <math.h>
#import "Vec3f.h"

typedef struct _vertexStruct
{
	GLfloat position[4];
	GLfloat color[4];
	Vec3f normal;
} vertexStruct;

