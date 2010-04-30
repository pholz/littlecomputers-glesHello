//
//  Obj3D.h
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "common.h"
#include <string>
#import "Shader.h"

class Obj3D
{
public:
	
	// Attribute locations
	GLuint	positionLoc, colorLoc;
	// Uniform locations
	GLuint  mvpLoc;
	
	GLuint program;
	
	ESMatrix  mvpMatrix;
	ESMatrix  tfMatrix;
	
	Vec3f position;
	Vec3f velocity, acceleration;
//	Matrix3fT rotation;
	float rx, ry, rz;
	
	btRigidBody *body;
	
	Vec3f scale;
	
	Shader *shader;
	std::string objId;
	
	bool remove;
	
	virtual void update(double dt) = 0;
	virtual void render(ESMatrix* p) = 0;
	virtual void init() = 0;
	void setId(std::string _id) {
		objId = _id;
	}
	
	std::string getId() {
		return objId;
	}
};


