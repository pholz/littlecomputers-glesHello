//
//  ES2Renderer.m
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ES2Renderer.h"
#include <time.h>

#import "Cube3D.h"

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
	
	
//	[self initScene];
	
	objects = [[NSMutableArray	alloc] init];
	Cube3D *c = [[Cube3D alloc] init:self];
	[objects addObject:c];
	
	rotx = roty = 0.0f;
	
	GLfloat tfm[16] = {  1.0f,  0.0f,  0.0f,  0.0f,
		0.0f,  1.0f,  0.0f,  0.0f,
		0.0f,  0.0f,  1.0f,  0.0f,
		0.0f,  0.0f,  0.0f,  1.0f };
	memcpy(&Transform.M, &tfm, sizeof(tfm));
	
	GLfloat lrot[9] = {  1.0f,  0.0f,  0.0f,					// Last Rotation
		0.0f,  1.0f,  0.0f,
		0.0f,  0.0f,  1.0f };
	memcpy(&LastRot.M, lrot, sizeof(lrot));
	
	GLfloat trot[9] = {  1.0f,  0.0f,  0.0f,					// This Rotation
		0.0f,  1.0f,  0.0f,
		0.0f,  0.0f,  1.0f };
	memcpy(&ThisRot.M, trot, sizeof(trot));
	
	arcball = ArcBallT(320.0f, 480.0f);
	
	return self;
}



- (void) glerr:(NSString*)msg
{
	NSLog(@"%@",[NSString stringWithFormat:@"glError: %@ --> %d", msg, glGetError()]);
}

- (void) update:(double)dt
{
	ESMatrix perspective;

	float    aspect;

	aspect = (GLfloat) backingWidth / (GLfloat) backingHeight;
	
	esMatrixLoadIdentity( &perspective );
	esPerspective( &perspective, 60.0f, aspect, 1.0f, 80.0f );
	
	NSEnumerator *enumerator = [objects objectEnumerator];
	id obj;
	
	
	
	while (obj = [enumerator nextObject]) 
	{
	//	Vec3f po = [obj pos];
	//	[obj setPos:(po)+Vec3f(0.0f,0.0f,-0.001f)];
		
	//	ESMatrix esmTf;
		memcpy(&[obj tfMatrix]->m[0][0], &Transform.M, sizeof(Transform.M));
		
	//	esMatrixLoadIdentity(&esmTf);
	//	esMatrixMultiply([obj tfMatrix], &esmTf, &perspective);
		[obj update:dt pMatrix:&perspective];
	}
	
//	esMatrixLoadIdentity( &modelview );
//	esTranslate( &modelview, 0.0, 0.0, -2.0 );
//	esRotate( &modelview, 35.0f + accTime * (360.0/5.0) * 3.0, 0.0, 1.0, 0.0 );
	
//	esMatrixMultiply( &mvpMatrix, &modelview, &perspective );
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
	
	

    NSEnumerator *enumerator = [objects objectEnumerator];
	id obj;
	
	while (obj = [enumerator nextObject]) 
	{
		
		
		[obj render];
	}

	
	
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

- (void) singleTouchBegan:(CGPoint) loc
{
	/*
	CGPoint p;
	p.x = 2.0f * loc.x / backingWidth - 1.0f;
	p.y = 2.0f * loc.y / backingHeight - 1.0f;
	last = p;
	*/
	
	MousePt.s.X = loc.x;
	MousePt.s.Y = loc.y;
	LastRot = ThisRot;
	arcball.click(&MousePt);
	
	//NSLog(@"arcball %f,%f",arcball.AdjustWidth,arcball.AdjustHeight);
	
}

- (void) singleTouchMoved:(CGPoint) loc
{
	/*
	CGPoint p;
	p.x = 2.0f * loc.x / backingWidth - 1.0f;
	p.y = 2.0f * loc.y / backingHeight - 1.0f;
	
	float dx = p.x - last.x;
	float dy = p.y - last.y;
	NSLog(@"last: %f/%f, p: %f/%f, delta: %f/%f",last.x,last.y,p.x,p.y,dx,dy);
	
	rotx += dx * 360;
	roty += dy * 360;
	
	//NSLog(@"%f/%f",rotx,roty);
	
	NSEnumerator *enumerator = [objects objectEnumerator];
	id obj;
	
	while (obj = [enumerator nextObject]) 
	{
		[obj setRx:rotx];
		[obj setRy:roty];
	}
	
	last = p;
	 */
	
	MousePt.s.X = loc.x;
	MousePt.s.Y = loc.y;
//	NSLog(@"%f,%f",MousePt.s.X,MousePt.s.Y);
	
	Quat4fT ThisQuat;
	arcball.drag(&MousePt, &ThisQuat);
	Matrix3fSetRotationFromQuat4f(&ThisRot, &ThisQuat);
	Matrix3fMulMatrix3f(&ThisRot, &LastRot);				// Accumulate Last Rotation Into This One
	Matrix4fSetRotationFromMatrix3f(&Transform, &ThisRot);
}

- (void) singleTouchEnded
{
	
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
