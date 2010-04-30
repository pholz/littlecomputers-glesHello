//
//  Cube3D.m
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tri3D.h"



void Tri3D::init()
{
	setId("ob_tri");
	remove = false;
	lifetime = 0.0;
	maxLife = 5.0;
	accTime = 0.0;
	scale = Vec3f(1.0f, 1.0f, 1.0f);
	body = NULL;
	
	vertices =	(vertexStruct*)	malloc(4 * sizeof(vertexStruct));
	indices =	(GLubyte*)		malloc(4 * sizeof(GLubyte));
	
	vertexStruct v0 = { { -0.5f, -0.5f,  0.5f, 1.0f }, {1.0f, 0.0f,   0, 1.0f}};	vertices[0] =  v0;
	vertexStruct v1 = { { 0.5f, -0.5f,  0.5f, 1.0f }, {0.0f, 1.0f,   0, 1.0f} };	vertices[1] =  v1;	// 1
	vertexStruct v2 = 	{{ -0.5f, 0.5f,  0.5f, 1.0f }, {1.0f, 1.0f,   0, 1.0f}};	vertices[2] =  v2;// 2
	vertexStruct v3 = 	{{ 0.5f, 0.5f,  0.5f, 1.0f }, {0.0f, 0.0f,   0, 1.0f}};	vertices[3] =  v3;// 3
	
	
	GLubyte _indices[] = { 0, 1, 2, 3};
	memcpy(indices, _indices, sizeof(_indices));
	
	for(int i = 0; i < 4; i++)
	{
		Vec3f nor = Vec3f(0.0f, 0.0f, 1.0f);
		vertices[i].normal[0] = nor.x;
		vertices[i].normal[1] = nor.y;
		vertices[i].normal[2] = nor.z;
		
	}

	glGenBuffers(1, &vertexBuffer);
    glGenBuffers(1, &indexBuffer);
	
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 4 * sizeof(vertexStruct), vertices, GL_STATIC_DRAW);
	
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4 * sizeof(GLubyte), indices, GL_STATIC_DRAW);
	
	position = Vec3f(0.0,0.0,-8.0);
	velocity = Vec3f(0.0,0.0,0.0);
	acceleration = Vec3f(0.0,0.0,0.0);
	rx = ry = rz = 0.0f;
	
	esMatrixLoadIdentity(&tfMatrix);
}

void Tri3D::update(double dt)
{
	lifetime += dt;
	if(lifetime >= maxLife) remove = true;
}

void Tri3D::render(ESMatrix* p)
{
	ESMatrix modelview;
	esMatrixLoadIdentity( &modelview );

	ESMatrix matrix;
	if(false && body){
		btTransform trans;
		body->getMotionState()->getWorldTransform(trans);
		
		trans.getOpenGLMatrix(&matrix.m[0][0]);
	} else {
		esTranslate(&matrix, position.x, position.y, position.z);
	}
	
	esMatrixMultiply(&modelview, &matrix, &modelview );
	
	ESMatrix scaleMat;
	esMatrixLoadIdentity(&scaleMat);
	esScale(&scaleMat, scale.x, scale.y, scale.z);
	esMatrixMultiply(&modelview, &scaleMat, &modelview);
	//esMatrixMultiply(&modelview, &tfMatrix, &modelview);
	esMatrixMultiply(&mvpMatrix, &modelview, p );

	ESMatrix inv, tim;
	esMatrixInverse(&inv, &modelview);
	esMatrixTranspose(&tim, &inv);
	
	glUseProgram(shader.program);

	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	
	glEnableVertexAttribArray(shader.positionLoc);
	glEnableVertexAttribArray(shader.colorLoc);
	glEnableVertexAttribArray(shader.normLoc);
	
    glVertexAttribPointer(shader.positionLoc, 4, GL_FLOAT, GL_FALSE, sizeof(vertexStruct), (const void*)  0);
	glVertexAttribPointer(shader.colorLoc, 4, GL_FLOAT, GL_FALSE, sizeof(vertexStruct), (const void*) (4 * sizeof(GLfloat)));
    glVertexAttribPointer(shader.normLoc, 3, GL_FLOAT, GL_TRUE, sizeof(vertexStruct), (const void*) (8 * sizeof(GLfloat)));
	
	
	glUniformMatrix4fv( shader.mvpLoc, 1, GL_FALSE, (GLfloat*) &mvpMatrix.m[0][0] );
	glUniformMatrix4fv( shader.timLoc, 1, GL_FALSE, (GLfloat*) &tim.m[0][0] );
	glUniform4f(shader.lightPos, -0.5f, -0.5f, -1.0f, 0.0f);
	
	glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_BYTE, (void*)0);
}

Tri3D::Tri3D()
{
	free(vertices);
	free(indices);
}


