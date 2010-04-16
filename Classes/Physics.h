/*
 *  Physics.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 25.03.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "common.h"

class Physics {
public:
	Physics();
	void init();
	void setGravity(Vec3f g);
	
	btDiscreteDynamicsWorld*				m_dynamicsWorld;	
	btBroadphaseInterface*					m_broadphase;	
	btCollisionDispatcher*					m_dispatcher;	
	btConstraintSolver*						m_solver;
	btDefaultCollisionConfiguration*		m_collisionConfiguration;
	
	Vec3f m_gravity;
};