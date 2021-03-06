//
//  Cube3D.m
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Cube3D.h"



@implementation Cube3D

-(id) init:(ES2Renderer*) _renderer
{
	NSLog(@"init cube");
	renderer = _renderer;
	//positionLoc = glGetAttribLocation ( renderer->program, "position" );
//	colorLoc = glGetAttribLocation ( renderer->program, "color" );
//	mvpLoc = glGetUniformLocation( renderer->program, "modelViewProjectionMatrix" );
	
	accTime = 0.0;
	
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
	
	glGenBuffers(1, &vertexBuffer);
    glGenBuffers(1, &indexBuffer);
	//	[renderer glerr:@"genbf"];
	
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	//	[renderer glerr:@"bindbf"];
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	//	[renderer glerr:@"bfdata"];
	
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	//	[renderer glerr:@"bindbf"];
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
	//	[renderer glerr:@"bfdata"];
	
	position = Vec3f(0.0,0.0,-2.0);
	velocity = Vec3f(0.0,0.0,0.0);
	acceleration = Vec3f(0.0,0.0,0.0);
	rx = ry = rz = 0.0f;
	
	esMatrixLoadIdentity(&tfMatrix);
	
	return self;
}

-(void) update:(double)dt pMatrix:(ESMatrix*)p
{
//	NSLog(@"upd cube");
	ESMatrix modelview;
	
	accTime += dt;
	if(accTime >= 5.0) accTime = 0.0;
	
	esMatrixLoadIdentity( &modelview );
	esTranslate( &modelview, position.x, position.y, position.z );
	esMatrixMultiply(&modelview, &tfMatrix, &modelview);
	
//	esRotate( &modelview, 35.0f + accTime * (360.0/5.0) * 3.0, 0.0, 1.0, 0.0 );
//	esRotate( &modelview, rx, 1.0, 0.0, 0.0 );
//	esRotate( &modelview, ry, 0.0, 1.0, 0.0 );
	
//	NSLog(@"%f",vertices[4]);
	esMatrixMultiply( &mvpMatrix, &modelview, p );
}

-(void) render
{
//	NSLog(@"render cube");
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
//	[renderer glerr:@"bindbf"];
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
//	[renderer glerr:@"bindbf"];
	
	glEnableVertexAttribArray(renderer->positionLoc);
//	[renderer glerr:@"enableVAA"];
	glEnableVertexAttribArray(renderer->colorLoc);
//	[renderer glerr:@"enableVAA"];
	
    glVertexAttribPointer(renderer->positionLoc, 4, GL_FLOAT, GL_FALSE, sizeof(vertexStruct), (const void*)  0);
//	[renderer glerr:@"VAAptr"];
	glVertexAttribPointer(renderer->colorLoc, 4, GL_FLOAT, GL_FALSE, sizeof(vertexStruct), (const void*) (4 * sizeof(GLfloat)));
//	[renderer glerr:@"VAAptr"];
    
	
	glUniformMatrix4fv( renderer->mvpLoc, 1, GL_FALSE, (GLfloat*) &mvpMatrix.m[0][0] );
//	[renderer glerr:@"uniform"];
	
    glDrawElements(GL_TRIANGLE_STRIP, 14, GL_UNSIGNED_BYTE, (void*)0);
//	[renderer glerr:@"draw"];
}

-(void) dealloc
{
//	delete position;
//	delete velocity;
//	delete acceleration;
	[super dealloc];
}
@end
