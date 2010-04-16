/*
 *  World.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 16.04.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "cinder/Quaternion.h"
#import "Shader.h"

class Physics;

class Cube3D;

class World {
	Physics *mPhysics;
	int mObjCounter;
	
public:
	World(Physics* physics);
	Cube3D* addStaticCube(Vec3f pos, Vec3f size, btQuaternion rot, Shader *s);
	Cube3D* addGoal(Vec3f pos, Vec3f size, btQuaternion rot, Shader *s);
	
};
