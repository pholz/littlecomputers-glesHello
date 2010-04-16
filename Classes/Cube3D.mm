//
//  Cube3D.m
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Cube3D.h"



void Cube3D::init()
{
	setId("ob_cube");
	accTime = 0.0;
	scale = Vec3f(1.0f, 1.0f, 1.0f);
	
	vertices =	(vertexStruct*)	malloc(8 * sizeof(vertexStruct));
	indices =	(GLubyte*)		malloc(14 * sizeof(GLubyte));
	
	vertexStruct v0 = { { -0.5f, -0.5f,  0.5f, 1.0f }, {1.0f, 0.0f,   0, 1.0f}};	vertices[0] =  v0;
	vertexStruct v1 = { { 0.5f, -0.5f,  0.5f, 1.0f }, {0.0f, 1.0f,   0, 1.0f} };	vertices[1] =  v1;	// 1
	vertexStruct v2 = 	{{ -0.5f, 0.5f,  0.5f, 1.0f }, {1.0f, 1.0f,   0, 1.0f}};	vertices[2] =  v2;// 2
	vertexStruct v3 = 	{{ 0.5f, 0.5f,  0.5f, 1.0f }, {0.0f, 0.0f,   0, 1.0f}};	vertices[3] =  v3;// 3
	
	vertexStruct v4 = 	{{ -0.5f, -0.5f,  -0.5f, 1.0f }, {1.0f, 1.0f,   1.0f, 1.0f}};	vertices[4] =  v4;	// 4
	vertexStruct v5 = 	{{ 0.5f, -0.5f,  -0.5f, 1.0f }, {0.0f, 0.0f,   1.0f, 1.0f}};	vertices[5] =  v5;	// 5
	vertexStruct v6 = 	{{ -0.5f, 0.5f,  -0.5f, 1.0f }, {0.0f, 1.0f,   1.0f, 1.0f}};	vertices[6] =  v6;// 6
	vertexStruct v7 = 	{{ 0.5f, 0.5f,  -0.5f, 1.0f }, {1.0f, 0.0f,   1.0f, 1.0f}};	vertices[7] =  v7;// 7
	
	GLubyte _indices[] = { 0, 1, 2, 3,  7, 1, 5, 4,  7, 6, 2, 4,  0, 1};
	memcpy(indices, _indices, sizeof(_indices));
	
	for(int i = 0; i < 8; i++)
	{
		Vec3f nor = Vec3f(vertices[i].position[0],vertices[i].position[1],vertices[i].position[2]).norm();
		vertices[i].normal[0] = nor.x;
		vertices[i].normal[1] = nor.y;
		vertices[i].normal[2] = nor.z;
		
	}

	glGenBuffers(1, &vertexBuffer);
    glGenBuffers(1, &indexBuffer);
	
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 8 * sizeof(vertexStruct), vertices, GL_STATIC_DRAW);
	
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 14 * sizeof(GLubyte), indices, GL_STATIC_DRAW);
	
	position = Vec3f(0.0,0.0,-8.0);
	velocity = Vec3f(0.0,0.0,0.0);
	acceleration = Vec3f(0.0,0.0,0.0);
	rx = ry = rz = 0.0f;
	
	esMatrixLoadIdentity(&tfMatrix);
}

void Cube3D::update(double dt)
{

}

void Cube3D::render(ESMatrix* p)
{
	ESMatrix modelview;

	btTransform trans;
	body->getMotionState()->getWorldTransform(trans);
	ESMatrix matrix;
	trans.getOpenGLMatrix(&matrix.m[0][0]);
	
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
	
	glDrawElements(GL_TRIANGLE_STRIP, 14, GL_UNSIGNED_BYTE, (void*)0);
}

Cube3D::~Cube3D()
{
	free(vertices);
	free(indices);
}


