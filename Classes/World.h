/*
 *  World.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 16.04.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Physics.h"
#include "Cube3D.h"
#include "cinder/Quaternion.h"
#include "Shader.h"
#import "btBulletDynamicsCommon.h"

class World {
	Physics *mPhysics;
	int mObjCounter;
	
public:
	World(Physics* physics);
	Cube3D* addStaticCube(Vec3f pos, Vec3f size, ci::Quatf rot, Shader *s);
	
};
