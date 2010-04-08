//
//  ESRenderer.h
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderer <NSObject>

- (void) render;
- (void) update:(double)dt;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

- (void) singleTouchBegan:(CGPoint) loc;
- (void) singleTouchMoved:(CGPoint) loc;
- (void) singleTouchEnded;
- (void) setLastAccelerationX:(float)x Y:(float)y Z:(float)z;

@end
