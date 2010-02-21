//
//  Cube3D.m
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Cube3D.h"



@implementation Cube3D

-(id) init
{
	accTime = 0.0;
	
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
	memcpy(*indices, _indices, sizeof(*indices));
	
	glGenBuffers(1, &vertexBuffer);
    glGenBuffers(1, &indexBuffer);
	//	[self glerr:@"genbf"];
	
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	///	[self glerr:@"bindbf"];
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	//	[self glerr:@"bfdata"];
	
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	//	[self glerr:@"bindbf"];
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
	//	[self glerr:@"bfdata"];
	
}

-(void) update:(double)dt mvpMatrix:(ESMatrix*)mvp pMatrix:(ESMatrix*)p
{
	ESMatrix modelview;
	float    aspect;
	
	accTime += dt;
	if(accTime >= 5.0) accTime = 0.0;
	
	aspect = (GLfloat) backingWidth / (GLfloat) backingHeight;
	
	esMatrixLoadIdentity( &modelview );
	esTranslate( &modelview, 0.0, 0.0, -2.0 );
	esRotate( &modelview, 35.0f + accTime * (360.0/5.0) * 3.0, 0.0, 1.0, 0.0 );
	
	esMatrixMultiply( mvp, &modelview, p );
}

-(void) render
{
	
}

@end
