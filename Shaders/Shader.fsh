//
//  Shader.fsh
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
	gl_FragColor = colorVarying;
}
