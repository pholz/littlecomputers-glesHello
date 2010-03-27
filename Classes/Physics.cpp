/*
 *  Physics.cpp
 *  glesHello
 *
 *  Created by Peter Holzkorn on 25.03.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Physics.h"

Physics::Physics()
{
	init();
}

void Physics::init()
{
	m_collisionConfiguration = new btDefaultCollisionConfiguration();
	m_dispatcher = new btCollisionDispatcher(m_collisionConfiguration);
	m_broadphase = new btDbvtBroadphase();
	btSequentialImpulseConstraintSolver* sol = new btSequentialImpulseConstraintSolver;
	m_solver = sol;
	
	m_dynamicsWorld = new btDiscreteDynamicsWorld(m_dispatcher, m_broadphase, m_solver, m_collisionConfiguration);
	m_dynamicsWorld->setGravity(btVector3(0,0,-10));
	
	btVector3 gndVecs[5] = {
		btVector3(0,1,0),
		btVector3(-1,0,0),
		btVector3(0,-1,0),
		btVector3(1,0,0),
		btVector3(0,0,1)
	};
	
	btVector3 gndPos[5] = {
		btVector3(0,-2,0),
		btVector3(2,0,0),
		btVector3(0,2,0),
		btVector3(-2,0,0),
		btVector3(0,0,-8)
	};
	
	for(int i = 0; i < 5; i++)
	{
		// make a ground plane that cannot be moved
		btCollisionShape * groundShape	= new btStaticPlaneShape(gndVecs[i],1);
		
		btDefaultMotionState * groundMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1),gndPos[i]));
		btRigidBody::btRigidBodyConstructionInfo groundRigidBodyCI(0,groundMotionState,groundShape,btVector3(0,0,0));
		
		btRigidBody *groundRigidBody = new btRigidBody(groundRigidBodyCI);
		m_dynamicsWorld->addRigidBody(groundRigidBody);
	}
	
}