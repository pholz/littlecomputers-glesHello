//
//  ES2Renderer.h
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ESRenderer.h"
#include "esUtil.h"
#include <time.h>

#import "common.h"

//#import "Cube3D.h"

#define VERTEX_POS_INDX	0 
#define VERTEX_COLOR_INDX	1 




@interface ES2Renderer : NSObject <ESRenderer>
{
@public
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer, depthRenderbuffer;
	
	GLuint program;
	
	// Attribute locations
	GLuint	  positionLoc, colorLoc;
	// Uniform locations
	GLuint  mvpLoc;
	
	NSMutableArray *objects;
	
	// handle touch
	CGPoint last, now;
	float rotx, roty;
}

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) glerr:(NSString*)msg;



@end

