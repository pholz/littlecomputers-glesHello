//
//  Shader.fsh
//  glesHello
//
//  Created by Peter Holzkorn on 19.02.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

varying vec4 colorVarying;
varying vec3 normVarying;
varying vec3 lightDirVarying;
varying vec3 halfVecVarying;
varying vec4 diffuseVarying, ambientVarying;

void main()
{
	vec3 n, halfV;
	float NdotL, NdotHV;
	vec4 color = ambient;
	n = normalize(normVarying);
	NdotL = max(dot(n,lightDirVarying),0.0);
	
	if(NdotL > 0.0) {
		
		color += diffuse * NdotL;
		halfV = normalize(halfVecVarying);
		NdotHV = max(dot(n,halfV),0.0);
		// add specular
	
	}

	gl_FragColor = color;
}
