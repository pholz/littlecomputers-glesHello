/*
 *  Sphere3D.cpp
 *  glesHello
 *
 *  Created by Peter Holzkorn on 04.04.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Sphere3D.h"

void Sphere3D::init()
{
	scale = Vec3f(1.0f,1.0f,1.0f);
	remove = false;
	numInds = esGenSphere(24, 2.0f, &verts, &norms, NULL, &inds);
	int numParallels = 24 / 2;
	int numVerts = ( numParallels + 1 ) * ( 24 + 1 );
	vertices = (vertexStruct*)malloc(numVerts * sizeof(vertexStruct));
	
	for(int j = 0; j < numVerts; j++)
	{
		vertices[j].position[0] = verts[j*3]; vertices[j].position[1] = verts[j*3+1]; vertices[j].position[2] = verts[j*3+2]; vertices[j].position[3] = 1.0f;
		vertices[j].normal[0] = norms[j*3]; vertices[j].normal[1] = norms[j*3+1]; vertices[j].normal[2] = norms[j*3+2]; //fullVertices[j].normal[3] = 1.0f;
		//	fullVertices[i].tex = texs[i];
		vertices[j].color[0] = 1.0f; vertices[j].color[1] = 0.0f; vertices[j].color[2] = 0.0f; vertices[j].color[3] = 1.0f;
	}
	
	
	
	glGenBuffers(1, &vertexBuffer);
    glGenBuffers(1, &indexBuffer);
	//	[renderer glerr:@"genbf"];
	
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	//	[renderer glerr:@"bindbf"];
    glBufferData(GL_ARRAY_BUFFER, numVerts * sizeof(vertexStruct), vertices, GL_STATIC_DRAW);
	//glBufferData(GL_ARRAY_BUFFER, sizeof(fullVertices), fullVertices, GL_STATIC_DRAW);
	//	[renderer glerr:@"bfdata"];
	
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	//	[renderer glerr:@"bindbf"];
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numInds * sizeof(GLubyte), inds, GL_STATIC_DRAW);
	//glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(inds), inds, GL_STATIC_DRAW);
	//	[renderer glerr:@"bfdata"];
	
	position = Vec3f(0.0,0.0,-6.0);
	velocity = Vec3f(0.0,0.0,0.0);
	acceleration = Vec3f(0.0,0.0,0.0);
	rx = ry = rz = 0.0f;
	
	esMatrixLoadIdentity(&tfMatrix);
}

void Sphere3D::update(double dt)
{
	
}
void Sphere3D::render(ESMatrix* p)
{
	ESMatrix modelview;
	ESMatrix matrix;
	
	if(body){
		btTransform trans;
		body->getMotionState()->getWorldTransform(trans);
		
		trans.getOpenGLMatrix(&matrix.m[0][0]);
	} else {
		esTranslate(&matrix, position.x, position.y, position.z);
	}
	
	esMatrixLoadIdentity( &modelview );
	
	esMatrixMultiply(&modelview, &matrix, &modelview );
	ESMatrix scaleMat;
	esMatrixLoadIdentity(&scaleMat);
	esScale(&scaleMat, scale.x, scale.y, scale.z);
	esMatrixMultiply(&modelview, &scaleMat, &modelview);
	esMatrixMultiply(&modelview, &tfMatrix, &modelview);
	esMatrixMultiply(&mvpMatrix, &modelview, p );
	
	ESMatrix inv, tim;
	esMatrixInverse(&inv, &modelview);
	esMatrixTranspose(&tim, &inv);
	
	glUseProgram(shader.program);
	
	//	NSLog(@"render cube");
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	//	[renderer glerr:@"bindbf"];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	//	[renderer glerr:@"bindbf"];
	
	glEnableVertexAttribArray(shader.positionLoc);
	//	[renderer glerr:@"enableVAA"];
	glEnableVertexAttribArray(shader.colorLoc);
	//	[renderer glerr:@"enableVAA"];
	glEnableVertexAttribArray(shader.normLoc);
	
    glVertexAttribPointer(shader.positionLoc, 4, GL_FLOAT, GL_FALSE, sizeof(vertexStruct), (const void*)  0);
	//	[renderer glerr:@"VAAptr"];
	
	//	[renderer glerr:@"VAAptr"];
	glVertexAttribPointer(shader.colorLoc, 4, GL_FLOAT, GL_FALSE, sizeof(vertexStruct), (const void*) (4 * sizeof(GLfloat)));
    glVertexAttribPointer(shader.normLoc, 3, GL_FLOAT, GL_TRUE, sizeof(vertexStruct), (const void*) (8 * sizeof(GLfloat)));
	
	
	glUniformMatrix4fv( shader.mvpLoc, 1, GL_FALSE, (GLfloat*) &mvpMatrix.m[0][0] );
	glUniformMatrix4fv( shader.timLoc, 1, GL_FALSE, (GLfloat*) &tim.m[0][0] );
	glUniform4f(shader.lightPos, -0.5f, -0.5f, -1.0f, 0.0f);
	//	[renderer glerr:@"uniform"];
	
	glDrawElements(GL_TRIANGLES, numInds, GL_UNSIGNED_BYTE, (void*)0);
}