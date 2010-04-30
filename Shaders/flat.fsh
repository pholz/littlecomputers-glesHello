//
//  Shader.fsh
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

varying mediump vec4 colorVarying;
varying mediump vec3 normVarying;
varying mediump vec3 lightDirVarying;
varying mediump vec3 halfVecVarying;
varying mediump vec4 diffuseVarying, ambientVarying, specularVarying;
varying mediump float shininessVarying;

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
		halfV = normalize(halfVecVarying);
		NdotHV = max(dot(n,halfV),0.0);
		//color += specularVarying * pow(NdotHV, shininessVarying);
	
	} else {
		//color = vec4(0.0, 1.0, 0.0, 1.0);
	}
	gl_FragColor = color;
}
