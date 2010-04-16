/*
 *  common.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 21.02.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef COMMON_H

#define COMMON_H

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <math.h>
#import "Vec3f.h"
#include "esUtil.h"
#include "btBulletDynamicsCommon.h"
//#include "CinderBullet.h"

typedef struct _vertexStruct
{
	GLfloat position[4];
	GLfloat color[4];
	GLfloat normal[3];
} vertexStruct;

typedef struct _vertexFullStruct
{
	GLfloat position[4];
	
//	GLfloat tex[2];
	GLfloat color[4];
	GLfloat normal[3];
} vertexFullStruct;

static btRigidBody* createSphere(btDynamicsWorld *world, float radius, btQuaternion rotation, btVector3 position)
{
	btCollisionShape *sphere = new btSphereShape((btScalar) radius);
	btDefaultMotionState *motionState = new btDefaultMotionState(btTransform(rotation,position));
	
	btVector3 inertia(0,0,0);
	float mass = radius * radius * radius * 3.14 * 4.0f/3.0f;
	sphere->calculateLocalInertia(mass, inertia);
	btRigidBody::btRigidBodyConstructionInfo rigidBodyCI(mass, motionState, sphere, inertia);
	
	btRigidBody *rigidBody = new btRigidBody(rigidBodyCI);
	world->addRigidBody(rigidBody);
	
	return rigidBody;
}

#endif