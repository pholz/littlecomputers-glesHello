attribute vec4 position;
attribute vec4 color;
attribute vec4 norm;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 tiMvpMatrix;
uniform vec4 lightPos;

varying vec4 colorVarying;
varying vec3 normVarying;
varying vec3 lightDirVarying;
varying vec3 halfVecVarying;
varying vec4 diffuseVarying, ambientVarying;

void main()
{
	vec4 diffuse = vec4(1.0, 0.0, 0.0, 1.0);
	vec4 ambient = vec4(0.0, 0.5, 0.0, 1.0);
	
	vec4 normal = normalize(tiMvpMatrix * norm);
	normVarying = normalize(normal.xyz);
	
	lightDirVarying = normalize(vec3(lightPos.x, lightPos.y, lightPos.z));
	vec3 eyeVec = vec3(0.0,0.0,1.0);
	halfVecVarying = normalize(lightDirVarying + eyeVec);

	diffuseVarying = diffuse * 1.0;
	ambientVarying = ambient * 1.0;
	
	gl_Position = modelViewProjectionMatrix * position;
	colorVarying = color;
}
