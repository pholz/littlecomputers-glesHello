//
//  Obj3D.h
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ES2Renderer.h"


@interface Obj3D : NSObject 
{
	vertexStruct	*vertices;
	GLubyte			*indices;
	
	GLuint    vertexBuffer;
	GLuint    indexBuffer;
	
	// Attribute locations
	GLuint	  positionLoc, colorLoc;
	// Uniform locations
	GLuint  mvpLoc;
	
	GLuint program;
	
	ESMatrix  mvpMatrix;
	
	
}

-(void) update:(double)dt pMatrix:(ESMatrix*)p;
-(void) render;

@end
