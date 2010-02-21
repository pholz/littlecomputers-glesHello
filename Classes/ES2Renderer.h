//
//  ES2Renderer.h
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ESRenderer.h"
#include "esUtil.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define VERTEX_POS_INDX	0 
#define VERTEX_COLOR_INDX	1 

typedef struct _vertexStruct
{
	GLfloat position[4];
	GLubyte color[4];
} vertexStruct;

@interface ES2Renderer : NSObject <ESRenderer>
{
@private
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;
	
	GLuint program;
	
	
	vertexStruct vertices[8];
	GLubyte indices[24];
	
	GLuint    vertexBuffer;
	GLuint    indexBuffer;
	// Attribute locations
	GLuint  positionLoc, colorLoc;
	// Uniform locations
	GLuint  mvpLoc;
	
	ESMatrix  mvpMatrix;
	
	NSDate* lastDate;
	NSDate* curDate;
	double accTime;
}

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) initScene;
- (void) glerr:(NSString*)msg;

@end

