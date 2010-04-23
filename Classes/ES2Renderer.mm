//
//  ES2Renderer.m
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ES2Renderer.h"
#include "Cube3D.h"
#include "Sphere3D.h"
#include "TriMesh3D.h"
#include "cinder/app/AppCocoaTouch.h"
#include "cinder/cocoa/CinderCocoaTouch.h"
#include "cinder/TriMesh.h"
#include "cinder/ObjLoader.h"
#include "cinder/Quaternion.h"
#include "Resources.h"
#include "Physics.h"
#include "World.h"
#include <string>
#include <sstream>

#define CONVEX_SCALE 0.05f

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
	ATTRIB_NORM,
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
	
	/*
	positionLoc = glGetAttribLocation ( program, "position" );
	colorLoc = glGetAttribLocation ( program, "color" );
	mvpLoc = glGetUniformLocation( program, "modelViewProjectionMatrix" );
	*/
	
	NSEnumerator* en = [shaders objectEnumerator];
	id ob;
	while((ob = [en nextObject]) != nil)
	{
		Shader* sh = (Shader*)ob;
		sh.positionLoc = glGetAttribLocation ( sh.program, "position" );
		sh.colorLoc = glGetAttribLocation ( sh.program, "color" );
		sh.normLoc = glGetAttribLocation ( sh.program, "norm" );
		sh.mvpLoc = glGetUniformLocation( sh.program, "modelViewProjectionMatrix" );
		sh.timLoc = glGetUniformLocation( sh.program, "tiMvpMatrix" );
		sh.lightPos = glGetUniformLocation(sh.program, "lightPos");
		
	}

		
	
	
	
//	[self initScene];
	[self initPhysics];
	
	objects = std::vector<Obj3D*>();
	
	
	// add particle boxes
	for(int i = 0; i < 6; i++){
		Cube3D *c = new Cube3D();
		c->init();
		std::stringstream ss;
		ss << "ob_cube_" << i;
		c->setId(ss.str());
		c->shader = [shaders objectForKey:@"light"];
		c->scale = Vec3f(0.5f, 0.5f, 0.5f);
		
		btCollisionShape *boxShape = new btBoxShape(btVector3(c->scale.x/2.0f,c->scale.y/2.0f,c->scale.z/2.0f));
		btDefaultMotionState *boxMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1),btVector3(float(i)-3.0f, 0.0f, 20.0f)));
		btVector3 inertia(0,0,0);
		float mass = .5f * .5f * .5f;
		boxShape->calculateLocalInertia(mass, inertia);
		
		btRigidBody::btRigidBodyConstructionInfo boxCI(mass, boxMotionState, boxShape, inertia);
		btRigidBody* body = new btRigidBody(boxCI);
		body->setUserPointer(c);
		body->setActivationState(DISABLE_DEACTIVATION);
		physics->m_dynamicsWorld->addRigidBody(body);
		c->body = body;
		objects.push_back(c);
	}
	

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
	
	
	angle = 0.0f;
	lastAccX = lastAccY = lastAccZ = 0;
	
	
	// load mesh
	
	/*
	ci::TriMesh convex;
	ci::ObjLoader loader( ci::app::App::loadResource( RES_TORUS )->getStream() );
	loader.load( &convex );

	btConvexHullShape* shape = ci::bullet::createConvexHullShape(convex, ci::Vec3f(CONVEX_SCALE, CONVEX_SCALE, CONVEX_SCALE));
	btRigidBody *convexBody = ci::bullet::createStaticRigidBody(physics->m_dynamicsWorld, shape, ci::Quatf(ci::Vec3f(1.0f, 0.0f, 0.0f), 3.14f/2.0f), ci::Vec3f(0,0,-7));
	TriMesh3D *tri = new TriMesh3D();
	tri->init(convex);
	tri->shader = [shaders objectForKey:@"light"];
	tri->body = convexBody;
	tri->scale = CONVEX_SCALE;
	objects.push_back(tri);
	 */
	
	ci::TriMesh sph;
	ci::ObjLoader loader2( ci::app::App::loadResource( RES_HISPHERE )->getStream() );
	loader2.load( &sph );
	
	btRigidBody *sphBody = createSphere(physics->m_dynamicsWorld, 0.5f, btQuaternion(), btVector3(2,2,20));
	TriMesh3D *sphTri = new TriMesh3D();
	
	sphTri->init(sph);
	sphTri->setId("ob_sphere");
	sphTri->shader = [shaders objectForKey:@"light2"];
	sphTri->body = sphBody;
	sphTri->scale = Vec3f(0.5f, 0.5f, 0.5f);
	sphBody->setUserPointer(sphTri);
	objects.push_back(sphTri);
	
	
	// --------- MAKE WORLD -----------
	
	Shader *worldShader = [shaders objectForKey:@"light2"];
	
	world = new World(physics);
	objects.push_back(	world->addStaticCube(	Vec3f(0.0f, 0.0f, -7.0f), Vec3f(4.0f,2.0f,0.5f), btQuaternion(), worldShader	)	);
	objects.push_back(	world->addStaticCube(	Vec3f(0.0f, 4.0f, -7.0f), Vec3f(1.0f,2.0f,0.5f), btQuaternion(), worldShader	)	);
	objects.push_back(	world->addStaticCube(	Vec3f(0.0f, -6.0f, -7.0f), Vec3f(3.0f,2.0f,0.5f), btQuaternion(), worldShader	)	);

	world->setActor(sphTri);
	objects.push_back(  world->addGoal(Vec3f(1.0f, 1.0f, -7.0f), Vec3f(1.0f,1.0f,1.0f), btQuaternion(), worldShader ) );
	// --------------------------------
	
	
	
	return self;
}

- (void) initPhysics
{
	physics = new Physics();
}



- (void) glerr:(NSString*)msg
{
	NSLog(@"%@",[NSString stringWithFormat:@"glError: %@ --> %d", msg, glGetError()]);
}

- (void) update:(double)dt
{
	physics->m_dynamicsWorld->stepSimulation(1.0f, 2);
	
	physics->m_dynamicsWorld->contactPairTest(world->getActor()->body, world->getGoal()->body, world->getActorGoalCallback());
	
	/*
	
	int numManifolds = physics->m_dynamicsWorld->getDispatcher()->getNumManifolds();
	for (int i=0;i<numManifolds;i++)
	{
		btPersistentManifold* contactManifold =  physics->m_dynamicsWorld->getDispatcher()->getManifoldByIndexInternal(i);
		btCollisionObject* obA = static_cast<btCollisionObject*>(contactManifold->getBody0());
		btCollisionObject* obB = static_cast<btCollisionObject*>(contactManifold->getBody1());
		
		void* uptrA = obA->getCollisionShape()->getUserPointer();
		void* uptrB = obB->getCollisionShape()->getUserPointer();
		Obj3D* objectA = NULL;
		Obj3D* objectB = NULL;
		
		
		if(uptrA){
			objectA = static_cast<Obj3D*>(uptrA);
		//	NSLog(@"A: %@",[NSString stringWithCString:objectA->getId().c_str()]);
		}
		if(uptrB){
			objectB = static_cast<Obj3D*>(uptrB);
		//	NSLog(@"B: %@",[NSString stringWithCString:objectB->getId().c_str()]);
		}
		
		if(objectA && objectB){
			
		}
		
		
		
	}
	*/
	angle += dt * 36.0f;
	
	
	for (int i = 0; i < objects.size(); i++) 
	{
		Obj3D *o = objects[i];
		
		
	//	esMatrixLoadIdentity(&esmTf);
	//	esMatrixMultiply([obj tfMatrix], &esmTf, &perspective);
		o->update(dt);
	}
	
//	esMatrixLoadIdentity( &modelview );
//	esTranslate( &modelview, 0.0, 0.0, -2.0 );
//	esRotate( &modelview, 35.0f + accTime * (360.0/5.0) * 3.0, 0.0, 1.0, 0.0 );
	
//	esMatrixMultiply( &mvpMatrix, &modelview, &perspective );
}

- (void) render
{
	ESMatrix perspective;
	
	float    aspect;
	
	aspect = (GLfloat) backingWidth / (GLfloat) backingHeight;
	
	esMatrixLoadIdentity( &perspective );
	//esRotate(&perspective, angle, 0.0f, 0.0f, 1.0f);
	esPerspective( &perspective, 60.0f, aspect, 1.0f, 80.0f );
	
	
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
  //  glUseProgram(program);
//	[self glerr:@"useprog"];
	
	

    for (int i = 0; i < objects.size(); i++) 
	{
		Obj3D *o = objects[i];
		memcpy(&o->tfMatrix.m[0][0], &Transform.M, sizeof(Transform.M));
		o->render(&perspective);
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

- (void) setLastAccelerationX:(float)x Y:(float)y Z:(float)z
{
	lastAccX = x;
	lastAccY = y;
	lastAccZ = z;
	NSLog(@"%f,%f,%f", x, y, z);
	physics->setGravity(Vec3f(x,y,z));
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
	shaders = [[NSMutableDictionary alloc] init];
	
	NSArray *names =[[NSArray alloc] initWithObjects: @"light", @"light2", nil];
	
	for(int i = 0; i < [names count]; i++)
	{
		NSString* name = [names objectAtIndex:i];
		
		GLuint vertShader, fragShader;
		NSString *vertShaderPathname, *fragShaderPathname;
		
		// create shader program
		GLuint curProgram = glCreateProgram();
		Shader* sh = [[Shader alloc] initWithName:name];
		[sh setProgram:curProgram];
		[shaders setObject:sh forKey:name];
		
		// create and compile vertex shader
		vertShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
		if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
		{
			NSLog(@"Failed to compile vertex shader");
			return FALSE;
		}
		
		// create and compile fragment shader
		fragShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
		if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
		{
			NSLog(@"Failed to compile fragment shader");
			return FALSE;
		}
		
		// attach vertex shader to program
		glAttachShader(curProgram, vertShader);
		
		// attach fragment shader to program
		glAttachShader(curProgram, fragShader);
		
		// bind attribute locations
		// this needs to be done prior to linking
		glBindAttribLocation(curProgram, ATTRIB_VERTEX, "position");
		glBindAttribLocation(curProgram, ATTRIB_COLOR, "color");
		glBindAttribLocation(curProgram, ATTRIB_NORM, "norm");
		
		// link program
		if (![self linkProgram:curProgram])
		{
			NSLog(@"Failed to link program: %d", curProgram);
			return FALSE;
		}
		
		// release vertex and fragment shaders
		if (vertShader)
			glDeleteShader(vertShader);
		if (fragShader)
			glDeleteShader(fragShader);

	}

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
	/*
	MousePt.s.X = loc.x;
	MousePt.s.Y = loc.y;
	LastRot = ThisRot;
	arcball.click(&MousePt);
	*/
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
	
	/*
	MousePt.s.X = loc.x;
	MousePt.s.Y = loc.y;
//	NSLog(@"%f,%f",MousePt.s.X,MousePt.s.Y);
	
	Quat4fT ThisQuat;
	arcball.drag(&MousePt, &ThisQuat);
	Matrix3fSetRotationFromQuat4f(&ThisRot, &ThisQuat);
	Matrix3fMulMatrix3f(&ThisRot, &LastRot);				// Accumulate Last Rotation Into This One
	Matrix4fSetRotationFromMatrix3f(&Transform, &ThisRot);
	 */
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
