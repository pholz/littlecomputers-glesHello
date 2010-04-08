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
	

	//positionLoc = glGetAttribLocation ( renderer->program, "position" );
//	colorLoc = glGetAttribLocation ( renderer->program, "color" );
//	mvpLoc = glGetUniformLocation( renderer->program, "modelViewProjectionMatrix" );
	
	accTime = 0.0;
	scale = 1.0f;
	
	//vertices =	(vertexStruct*)	malloc(8 * sizeof(vertexStruct));
	//indices =	(GLubyte*)		malloc(14 * sizeof(GLubyte));
	
	vertexStruct v0 = { { -0.5f, -0.5f,  0.5f, 1.0f }, {1.0f, 0.0f,   0, 1.0f}};	vertices[0] =  v0;
	vertexStruct v1 = { { 0.5f, -0.5f,  0.5f, 1.0f }, {0.0f, 1.0f,   0, 1.0f} };	vertices[1] =  v1;	// 1
	vertexStruct v2 = 	{{ -0.5f, 0.5f,  0.5f, 1.0f }, {1.0f, 1.0f,   0, 1.0f}};	vertices[2] =  v2;// 2
	vertexStruct v3 = 	{{ 0.5f, 0.5f,  0.5f, 1.0f }, {0.0f, 0.0f,   0, 1.0f}};	vertices[3] =  v3;// 3
	
	vertexStruct v4 = 	{{ -0.5f, -0.5f,  -0.5f, 1.0f }, {1.0f, 1.0f,   1.0f, 1.0f}};	vertices[4] =  v4;	// 4
	vertexStruct v5 = 	{{ 0.5f, -0.5f,  -0.5f, 1.0f }, {0.0f, 0.0f,   1.0f, 1.0f}};	vertices[5] =  v5;	// 5
	vertexStruct v6 = 	{{ -0.5f, 0.5f,  -0.5f, 1.0f }, {0.0f, 1.0f,   1.0f, 1.0f}};	vertices[6] =  v6;// 6
	vertexStruct v7 = 	{{ 0.5f, 0.5f,  -0.5f, 1.0f }, {1.0f, 0.0f,   1.0f, 1.0f}};	vertices[7] =  v7;// 7
	
	GLubyte _indices[] = { 0, 1, 2, 3,  7, 1, 5, 4,  7, 6, 2, 4,  0, 1};
	memcpy(indices, _indices, sizeof(indices));
	
	/*
	std::vector<Vec3f>* normbuff = new std::vector<Vec3f>[8];

	
	for(int i = 0; i < 14; i+= 3){
		Vec3f p1 = Vec3f(vertices[indices[i]].position[0],vertices[indices[i]].position[1],vertices[indices[i]].position[2]);
		Vec3f p2 = Vec3f(vertices[indices[i+1]].position[0],vertices[indices[i+1]].position[1],vertices[indices[i+1]].position[2]);
		Vec3f p3 = Vec3f(vertices[indices[i+2]].position[0],vertices[indices[i+2]].position[1],vertices[indices[i+2]].position[2]);
		
		Vec3f v1 = p2 - p1;
		Vec3f v2 = p3 - p1;
		Vec3f normal = v1.cross(v2);
		normal = normal.norm();
		
		normbuff[indices[i]].push_back(normal);
		normbuff[indices[i+1]].push_back(normal);
		normbuff[indices[i+2]].push_back(normal);
	}
	
	for(int i = 0; i < 8; ++i)
	{
		for(int j = 0; j < normbuff[i].size(); ++j)
			vertices[i].normal = vertices[i].normal + normbuff[i][j];
		vertices[i].normal = vertices[i].normal / normbuff[i].size();
		vertices[i].normal = vertices[i].normal.norm();
	}
	 */
	 
	
	for(int i = 0; i < 8; i++)
	{
		Vec3f nor = Vec3f(vertices[i].position[0],vertices[i].position[1],vertices[i].position[2]).norm();
		vertices[i].normal[0] = nor.x;
		vertices[i].normal[1] = nor.y;
		vertices[i].normal[2] = nor.z;
		
	}
		
	/*
	
	numInds = esGenCube(1.0f, &verts, &norms, &texs, &inds);
	
	for(int j = 0; j < 24; j++)
	{
		fullVertices[j].position[0] = verts[j*3]; fullVertices[j].position[1] = verts[j*3+1]; fullVertices[j].position[2] = verts[j*3+2]; fullVertices[j].position[3] = 1.0f;
		fullVertices[j].normal[0] = norms[j*3]; fullVertices[j].normal[1] = norms[j*3+1]; fullVertices[j].normal[2] = norms[j*3+2]; //fullVertices[j].normal[3] = 1.0f;
	//	fullVertices[i].tex = texs[i];
		fullVertices[j].color[0] = 1.0f; fullVertices[j].color[1] = 0.0f; fullVertices[j].color[2] = 0.0f; fullVertices[j].color[3] = 1.0f;
	}
	 */
	
	glGenBuffers(1, &vertexBuffer);
    glGenBuffers(1, &indexBuffer);
	//	[renderer glerr:@"genbf"];
	
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	//	[renderer glerr:@"bindbf"];
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	//glBufferData(GL_ARRAY_BUFFER, sizeof(fullVertices), fullVertices, GL_STATIC_DRAW);
	//	[renderer glerr:@"bfdata"];
	
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	//	[renderer glerr:@"bindbf"];
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
	//glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(inds), inds, GL_STATIC_DRAW);
	//	[renderer glerr:@"bfdata"];
	
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
//	esTranslate(&matrix, position.x, position.y, position.z);
	
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
	
	glDrawElements(GL_TRIANGLE_STRIP, 14, GL_UNSIGNED_BYTE, (void*)0);
  //  glDrawElements(GL_TRIANGLES, numInds, GL_UNSIGNED_BYTE, (void*)0);
//	[renderer glerr:@"draw"];
}



