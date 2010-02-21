//
//  ES2Renderer.m
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ES2Renderer.h"
#include <time.h>


// uniform index
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// attribute index
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface ES2Renderer (PrivateMethods)
- (BOOL) loadShaders;
- (BOOL) compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL) linkProgram:(GLuint)prog;
- (BOOL) validateProgram:(GLuint)prog;
@end

@implementation ES2Renderer

// Create an ES 2.0 context
- (id) init
{
	NSLog(@"ES2 renderer");
	
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShaders])
		{
            [self release];
            return nil;
        }

		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffers(1, &defaultFramebuffer);
		glGenRenderbuffers(1, &colorRenderbuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
		[self glerr:@"genbuffers"];
		
		
		
	}
	
	positionLoc = glGetAttribLocation ( program, "position" );
	colorLoc = glGetAttribLocation ( program, "color" );
	mvpLoc = glGetUniformLocation( program, "modelViewProjectionMatrix" );
	
	
	[self initScene];
	
	accTime = 0.0;
	
	return self;
}


- (void) initScene
{
	vertexStruct v0 = { { -0.5f, -0.5f,  0.5f, 1.0f }, {1.0f, 0.0f,   0, 1.0f}};	vertices[0] =  v0;
	vertexStruct v1 = { { 0.5f, -0.5f,  0.5f, 1.0f }, {0.0f, 1.0f,   0, 1.0f} };	vertices[1] =  v1;	// 1
	vertexStruct v2 = 	{{ -0.5f, 0.5f,  0.5f, 1.0f }, {1.0f, 1.0f,   0, 1.0f}};	vertices[2] =  v2;// 2
	vertexStruct v3 = 	{{ 0.5f, 0.5f,  0.5f, 1.0f }, {0.0f, 0.0f,   0, 1.0f}};	vertices[3] =  v3;// 3
		
	vertexStruct v4 = 	{{ -0.5f, -0.5f,  -0.5f, 1.0f }, {1.0f, 1.0f,   1.0f, 1.0f}};	vertices[4] =  v4;	// 4
	vertexStruct v5 = 	{{ 0.5f, -0.5f,  -0.5f, 1.0f }, {0.0f, 0.0f,   1.0f, 1.0f}};	vertices[5] =  v5;	// 5
	vertexStruct v6 = 	{{ -0.5f, 0.5f,  -0.5f, 1.0f }, {0.0f, 1.0f,   1.0f, 1.0f}};	vertices[6] =  v6;// 6
	vertexStruct v7 = 	{{ 0.5f, 0.5f,  -0.5f, 1.0f }, {1.0f, 0.0f,   1.0f, 1.0f}};	vertices[7] =  v7;// 7
	
	GLubyte _indices[] = { 0, 1, 2, 3,  7, 1, 5, 4,  7, 6, 2, 4,  0, 1};
	memcpy(indices, _indices, sizeof(indices));
	
	glGenBuffers(1, &vertexBuffer);
    glGenBuffers(1, &indexBuffer);
	[self glerr:@"genbf"];
	
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	[self glerr:@"bindbf"];
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	[self glerr:@"bfdata"];
	
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	[self glerr:@"bindbf"];
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
	[self glerr:@"bfdata"];
	
	
//	ESMatrix persp = [self perspective: 90 aspect:(backingWidth/backingHeight) near:0.1 far:100];
	
}

- (void) glerr:(NSString*)msg
{
	//NSLog(@"%@",[NSString stringWithFormat:@"glError: %@ --> %d", msg, glGetError()]);
}

- (void) update:(double)dt
{
	ESMatrix perspective;
	ESMatrix modelview;
	float    aspect;
	
	accTime += dt;
	if(accTime >= 5.0) accTime = 0.0;

	aspect = (GLfloat) backingWidth / (GLfloat) backingHeight;
	
	esMatrixLoadIdentity( &perspective );
	esPerspective( &perspective, 60.0f, aspect, 1.0f, 80.0f );
	
	esMatrixLoadIdentity( &modelview );
	esTranslate( &modelview, 0.0, 0.0, -2.0 );
	esRotate( &modelview, 35.0f + accTime * (360.0/5.0) * 3.0, 0.0, 1.0, 0.0 );
	
	esMatrixMultiply( &mvpMatrix, &modelview, &perspective );
}

- (void) render
{
	// This application only creates a single context which is already set current at this point.
	// This call is redundant, but needed if dealing with multiple contexts.
   // [EAGLContext setCurrentContext:context];
	
	// This application only creates a single default framebuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	//[self glerr:@"bindbf"];
	
    glViewport(0, 0, backingWidth, backingHeight);
    
	
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//	[self glerr:@"clear"];
	
	// Use shader program
    glUseProgram(program);
//	[self glerr:@"useprog"];
	
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
//	[self glerr:@"bindbf"];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
//	[self glerr:@"bindbf"];
	
	glEnableVertexAttribArray(positionLoc);
//	[self glerr:@"enableVAA"];
	glEnableVertexAttribArray(colorLoc);
//	[self glerr:@"enableVAA"];
	
    glVertexAttribPointer(positionLoc, 4, GL_FLOAT, GL_FALSE, sizeof(vertexStruct), (const void*)  0);
//	[self glerr:@"VAAptr"];
	glVertexAttribPointer(colorLoc, 4, GL_FLOAT, GL_FALSE, sizeof(vertexStruct), (const void*) (4 * sizeof(GLfloat)));
//	[self glerr:@"VAAptr"];
    
	
	glUniformMatrix4fv( mvpLoc, 1, GL_FALSE, (GLfloat*) &mvpMatrix.m[0][0] );
//	[self glerr:@"uniform"];
	
    glDrawElements(GL_TRIANGLE_STRIP, 14, GL_UNSIGNED_BYTE, (void*)0);
//	[self glerr:@"draw"];

    

	
	
	// This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL) compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
	GLint status;
	const GLchar *source;
	
	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source)
	{
		NSLog(@"Failed to load vertex shader");
		return FALSE;
	}
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
	
#if defined(DEBUG)
	GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
	{
		glDeleteShader(*shader);
		return FALSE;
	}
	
	return TRUE;
}

- (BOOL) linkProgram:(GLuint)prog
{
	GLint status;
	
	glLinkProgram(prog);

#if defined(DEBUG)
	GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
		return FALSE;
	
	return TRUE;
}

- (BOOL) validateProgram:(GLuint)prog
{
	GLint logLength, status;
	
	glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
		return FALSE;
	
	return TRUE;
}

- (BOOL) loadShaders
{
    GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;
    
    // create shader program
    program = glCreateProgram();
	
    // create and compile vertex shader
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
	{
		NSLog(@"Failed to compile vertex shader");
		return FALSE;
	}
	
    // create and compile fragment shader
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
	{
		NSLog(@"Failed to compile fragment shader");
		return FALSE;
	}
    
    // attach vertex shader to program
    glAttachShader(program, vertShader);
    
    // attach fragment shader to program
    glAttachShader(program, fragShader);
    
    // bind attribute locations
    // this needs to be done prior to linking
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
    
    // link program
	if (![self linkProgram:program])
	{
		NSLog(@"Failed to link program: %d", program);
		return FALSE;
	}
    
    // get uniform locations
    uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
    
    // release vertex and fragment shaders
    if (vertShader)
		glDeleteShader(vertShader);
    if (fragShader)
		glDeleteShader(fragShader);
	
	return TRUE;
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{
	NSLog(@"resize");
	// Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
	glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
	
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	
	glGenRenderbuffers(1, &depthRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
	
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
	
    return YES;
}

- (void) dealloc
{
	// Tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffers(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}

	if (colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	if (program)
	{
		glDeleteProgram(program);
		program = 0;
	}
	
	// Tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
