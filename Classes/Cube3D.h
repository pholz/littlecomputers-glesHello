//
//  Cube3D.h
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Obj3D.h"
#import "ES2Renderer.h"

@interface Cube3D : Obj3D {
	double accTime;
	ES2Renderer *renderer;
}

-(id) init:(ES2Renderer*)_renderer;
-(void) update:(double)dt pMatrix:(ESMatrix*)p;
-(void) render;


@end
