//
//  Shader.fsh
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

varying highp vec4 colorVarying;
varying highp vec3 normVarying;
varying highp vec3 lightDirVarying;
varying highp vec3 halfVecVarying;
varying highp vec4 diffuseVarying, ambientVarying;

void main()
{
	highp vec3 n, l, halfV;
	highp float NdotL, NdotHV;
	highp vec4 color = ambientVarying;
	n = normalize(normVarying);
	l = normalize(lightDirVarying);
	NdotL = dot(n,l);
	
	if(NdotL > 0.0) {
		
		color += diffuseVarying * NdotL;
		//halfV = normalize(halfVecVarying);
		//NdotHV = max(dot(n,halfV),0.0);
		// add specular
	
	} else {
		//color = vec4(0.0, 1.0, 0.0, 1.0);
	}
	gl_FragColor = color;
}
