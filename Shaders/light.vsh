attribute highp vec4 position;
attribute highp vec4 color;
attribute highp vec4 norm;

uniform mediump mat4 modelViewProjectionMatrix;
uniform mediump mat4 tiMvpMatrix;
uniform highp vec4 lightPos;

varying highp vec4 colorVarying;
varying highp vec3 normVarying;
varying highp vec3 lightDirVarying;
varying highp vec3 halfVecVarying;
varying highp vec4 diffuseVarying, ambientVarying;

void main()
{
	highp vec4 diffuse = vec4(1.0, 0.0, 0.0, 1.0);
	highp vec4 ambient = vec4(0.2, 0.0, 0.0, 1.0);
	
	highp vec4 normal = normalize(tiMvpMatrix * norm);
	normVarying = normalize(normal.xyz);
	
//	mediump vec4 light = normalize(modelViewProjectionMatrix * lightPos);
	lightDirVarying = -1.0 * lightPos.xyz; //vec3(light.x, light.y, light.z);
//	lightDirVarying = normalize(vec3(-1.0, -1.0, -1.0));
	highp vec3 eyeVec = vec3(0.0,0.0,1.0);
	halfVecVarying = normalize(lightDirVarying + eyeVec);

	diffuseVarying = diffuse * 1.0;
	ambientVarying = ambient * 1.0;
	
	gl_Position = modelViewProjectionMatrix * position;
	colorVarying = color;
}
