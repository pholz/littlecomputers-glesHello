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
	ES2Renderer *renderer;
	
	vertexStruct	vertices[8];
	GLubyte			indices[14];
	
	GLuint    vertexBuffer;
	GLuint    indexBuffer;
	
	Shader *shader;
	
	virtual void update(double dt);
	virtual void render(ESMatrix* p);
	virtual void init();
};

