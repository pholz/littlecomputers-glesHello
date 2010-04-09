attribute highp vec4 position;
attribute highp vec4 color;
attribute highp vec4 norm;

uniform mediump mat4 modelViewProjectionMatrix;
uniform mediump mat4 tiMvpMatrix;
uniform highp vec4 lightPos;

varying mediump vec4 colorVarying;
varying mediump vec3 normVarying;
varying mediump vec3 lightDirVarying;
varying mediump vec3 halfVecVarying;
varying mediump vec4 diffuseVarying, ambientVarying, specularVarying;
varying mediump float shininessVarying;

void main()
{
	highp vec4 diffuse = vec4(1.0, 0.0, 0.0, 1.0);
	highp vec4 ambient = vec4(0.2, 0.0, 0.0, 1.0);
	highp vec4 specular = vec4(1.0, 1.0, 1.0, 1.0);
	highp float shininess = 5.0;
	
	highp vec4 normal = normalize(tiMvpMatrix * norm);
	normVarying = normalize(normal.xyz);
	
//	mediump vec4 light = normalize(modelViewProjectionMatrix * lightPos);
	lightDirVarying = -1.0 * lightPos.xyz; //vec3(light.x, light.y, light.z);
//	lightDirVarying = normalize(vec3(-1.0, -1.0, -1.0));
	highp vec3 eyeVec = vec3(0.0,0.0,1.0);
	halfVecVarying = normalize(lightDirVarying + eyeVec);

	diffuseVarying = diffuse * 1.0;
	ambientVarying = ambient * 1.0;
	specularVarying = specular * 1.0;
	shininessVarying = shininess * 1.0;
	
	gl_Position = modelViewProjectionMatrix * position;
	colorVarying = color;
}
