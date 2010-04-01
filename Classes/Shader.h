/*
 *  Shader.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 24.03.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#import "common.h"

@interface Shader : NSObject 
{
	
	
	NSString* name;
	int program, colorLoc, positionLoc, mvpLoc, normLoc, timLoc, lightPos;
	
	
	
}
@property(nonatomic,retain) NSString* name;
@property int program;
@property int colorLoc;
@property int positionLoc;
@property int mvpLoc;
@property int timLoc;
@property int normLoc;
@property int lightPos;

-(id)initWithName:(NSString*) _name;
@end