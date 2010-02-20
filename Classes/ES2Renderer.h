//
//  ES2Renderer.h
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

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
	
	
	
	const vertexStruct vertices[8];
	const GLubyte indices[24];
	
	GLuint    vertexBuffer;
	GLuint    indexBuffer;
}

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) perspective:(double)fovy aspect:(double)aspect near:(double)zNear far:(double)zFar;
- (void) initScene;

@end

