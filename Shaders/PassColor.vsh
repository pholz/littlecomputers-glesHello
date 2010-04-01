attribute vec4 position;
attribute vec4 color;
attribute vec4 norm;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 tiMvpMatrix;
uniform vec4 lightPos;

varying vec4 colorVarying;

void main()
{
	gl_Position = modelViewProjectionMatrix * position;
	colorVarying = color;
}
