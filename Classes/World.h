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
#import <iostream>
#import "Obj3D.h"

class Physics;
class Cube3D;

struct actorGoalCallback : public btCollisionWorld::ContactResultCallback
{
	virtual	btScalar addSingleResult(btManifoldPoint& cp, const btCollisionObject* colObj0, int partId0, int index0, const btCollisionObject* colObj1, int partId1, int index1)
	{
		Obj3D* ob0;
		Obj3D* ob1;
		if(colObj0->getUserPointer()) ob0 = (Obj3D*) colObj0->getUserPointer();
		if(colObj1->getUserPointer()) ob1 = (Obj3D*) colObj1->getUserPointer();
		
		if(ob0 && ob1)
			std::cout << "GOAL " << ob0->getId() << " " << ob1->getId();
		
		return 0;
	}
};

class World {
	Physics *mPhysics;
	int mObjCounter;
	
public:
	World(Physics* physics);
	Cube3D* addStaticCube(Vec3f pos, Vec3f size, btQuaternion rot, Shader *s);
	Cube3D* addGoal(Vec3f pos, Vec3f size, btQuaternion rot, Shader *s);
	void setActor(Obj3D* o) { mActor = o; }
	Obj3D*	getActor() { return mActor; } 
	Obj3D*	getGoal() { return mGoal; } 
	btCollisionWorld::ContactResultCallback& getActorGoalCallback() {
		return mActorGoalCallback;
	}
	
	actorGoalCallback mActorGoalCallback;
	
private:
	Obj3D*	mActor;
	Obj3D*	mGoal;
	
};


