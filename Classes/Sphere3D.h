/*
 *  Sphere3D.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 04.04.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Obj3D.h"

class Sphere3D : public Obj3D {
public:
	GLfloat *verts, *norms, *texs;
	GLubyte *inds;
	int numInds;
	
	GLuint    vertexBuffer;
	GLuint    indexBuffer;
	
	vertexStruct* vertices;
	virtual void update(double dt);
	virtual void render(ESMatrix* p);
	virtual void init();
	
};