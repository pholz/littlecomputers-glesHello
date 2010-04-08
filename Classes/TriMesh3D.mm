/*
 *  TriMesh.cpp
 *  glesHello
 *
 *  Created by Peter Holzkorn on 08.04.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "TriMesh3D.h"

void TriMesh3D::init(){
	
}
void TriMesh3D::init(ci::TriMesh &mesh)
{
	scale = 1.0f;
	
	numInds = mesh.getNumIndices();
	numVerts = mesh.getNumVertices();
	
	const std::vector<ci::Vec3f>& verts = mesh.getVertices();
	const std::vector<ci::Vec3f>& norms = mesh.getNormals();
	const std::vector<size_t>& indsvec = mesh.getIndices();
	
	vertices = (vertexStruct*)malloc(numVerts * sizeof(vertexStruct));
	inds = (GLuint*)malloc(numInds * sizeof(GLuint));
	
	for(int i = 0; i < numInds; i++)
	{
		inds[i] = (GLuint)indsvec[i];
	}
	
	for(int j = 0; j < numVerts; j++)
	{
		vertices[j].position[0] = verts[j].x; vertices[j].position[1] = verts[j].y; vertices[j].position[2] = verts[j].z; vertices[j].position[3] = 1.0f;
		vertices[j].normal[0] = norms[j].x; vertices[j].normal[1] = norms[j].y; vertices[j].normal[2] = norms[j].z; //fullVertices[j].normal[3] = 1.0f;
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
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, numInds * sizeof(GLuint), inds, GL_STATIC_DRAW);
	//glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(inds), inds, GL_STATIC_DRAW);
	//	[renderer glerr:@"bfdata"];
	
	position = Vec3f(0.0,0.0,-6.0);
	velocity = Vec3f(0.0,0.0,0.0);
	acceleration = Vec3f(0.0,0.0,0.0);
	rx = ry = rz = 0.0f;
	
	esMatrixLoadIdentity(&tfMatrix);
}

void TriMesh3D::update(double dt)
{
	
}
void TriMesh3D::render(ESMatrix* p)
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
	esScale(&scaleMat, scale, scale, scale);
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
	
	glDrawElements(GL_TRIANGLES, numInds, GL_UNSIGNED_INT, (void*)0);
	//  glDrawElements(GL_TRIANGLES, numInds, GL_UNSIGNED_BYTE, (void*)0);
}