/*
 *  TriMesh.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 08.04.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Obj3D.h"
#include "cinder/TriMesh.h"

class TriMesh3D : public Obj3D {
public:
	GLfloat *verts, *norms, *texs;
	GLushort *inds;
	int numInds, numVerts;
	
	GLuint    vertexBuffer;
	GLuint    indexBuffer;
	
	vertexStruct* vertices;
	virtual void update(double dt);
	virtual void render(ESMatrix* p);
	void init(ci::TriMesh &mesh);
	virtual void init();
	
};