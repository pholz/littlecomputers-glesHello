/*
 *  World.cpp
 *  glesHello
 *
 *  Created by Peter Holzkorn on 16.04.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "World.h"
#include "Cube3D.h"
#include "Physics.h"

#include <sstream>

World::World(Physics* physics)
{
	mPhysics = physics;
	mObjCounter = 0;
	
}

Cube3D* World::addStaticCube(Vec3f pos, Vec3f size, btQuaternion rot, Shader *s)
{
	Cube3D *w1 = new Cube3D();
	w1->init();
	std::stringstream ss;
	ss << "ob_world_" << mObjCounter++;
	w1->setId(ss.str());
	w1->scale = size;
	w1->shader = s;
	btCollisionShape *w1Shape = new btBoxShape(btVector3(w1->scale.x/2.0f,w1->scale.y/2.0f,w1->scale.z/2.0f));
	btDefaultMotionState *w1MotionState = new btDefaultMotionState(	btTransform(rot,				//rotation
																				btVector3(pos.x, pos.y, pos.z)));		//position
	btVector3 w1inertia(0,0,0);
	float w1mass = 0.0f;
	w1Shape->calculateLocalInertia(w1mass, w1inertia);
	w1Shape->setUserPointer(w1);
	btRigidBody::btRigidBodyConstructionInfo w1CI(w1mass, w1MotionState, w1Shape, w1inertia);
	btRigidBody* w1body = new btRigidBody(w1CI);
	mPhysics->m_dynamicsWorld->addRigidBody(w1body);
	w1->body = w1body;
	return w1;
	
}

Cube3D* World::addGoal(Vec3f pos, Vec3f size, btQuaternion rot, Shader *s)
{
	Cube3D goal = addStaticCube(pos, size, rot, s);
	goal->body->setCollisionFlags(goal->body->getCollisionFlags() | btCollisionObject::CF_CUSTOM_MATERIAL_CALLBACK);
//	mPhysics->m_dynamicsWorld->contactPairTest(<#btCollisionObject *colObjA#>, <#btCollisionObject *colObjB#>, <#ContactResultCallback resultCallback#>)
}