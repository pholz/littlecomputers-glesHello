//
//  Cube3D.h
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Obj3D.h"
#import "Shader.h"

class Cube3D : public Obj3D {
public:
	double accTime;
	
	/*
	vertexStruct	vertices[8];
	vertexFullStruct	fullVertices[24];
	GLubyte			indices[14];
	 */
	vertexStruct	*vertices;
	GLubyte			*indices;
	
	GLfloat *verts, *norms, *texs;
	GLubyte *inds;
	int numInds;
	
	GLuint    vertexBuffer;
	GLuint    indexBuffer;

	virtual void update(double dt);
	virtual void render(ESMatrix* p);
	virtual void init();
	~Cube3D();
};

