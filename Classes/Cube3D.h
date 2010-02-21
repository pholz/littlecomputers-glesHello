//
//  Cube3D.h
//  glesHello
//
//  Created by Peter Holzkorn on 21.02.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Obj3D.h"

@interface Cube3D : Obj3D {
	double accTime;
}

-(void) update:(double)dt mvpMatrix:(ESMatrix*)mvp pMatrix:(ESMatrix*)p;
-(void) render;


@end
