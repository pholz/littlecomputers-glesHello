//
// Book:      OpenGL(R) ES 2.0 Programming Guide
// Authors:   Aaftab Munshi, Dan Ginsburg, Dave Shreiner
// ISBN-10:   0321502795
// ISBN-13:   9780321502797
// Publisher: Addison-Wesley Professional
// URLs:      http://safari.informit.com/9780321563835
//            http://www.opengles-book.com
//

// ESUtil.c
//
//    A utility library for OpenGL ES.  This library provides a
//    basic common framework for the example applications in the
//    OpenGL ES 2.0 Programming Guide.
//

///
//  Includes
//
#include "esUtil.h"
#include <math.h>
#include <string.h>

#define PI 3.1415926535897932384626433832795f

void ESUTIL_API
esScale(ESMatrix *result, GLfloat sx, GLfloat sy, GLfloat sz)
{
    result->m[0][0] *= sx;
    result->m[0][1] *= sx;
    result->m[0][2] *= sx;
    result->m[0][3] *= sx;

    result->m[1][0] *= sy;
    result->m[1][1] *= sy;
    result->m[1][2] *= sy;
    result->m[1][3] *= sy;

    result->m[2][0] *= sz;
    result->m[2][1] *= sz;
    result->m[2][2] *= sz;
    result->m[2][3] *= sz;
}

void ESUTIL_API
esTranslate(ESMatrix *result, GLfloat tx, GLfloat ty, GLfloat tz)
{
    result->m[3][0] += (result->m[0][0] * tx + result->m[1][0] * ty + result->m[2][0] * tz);
    result->m[3][1] += (result->m[0][1] * tx + result->m[1][1] * ty + result->m[2][1] * tz);
    result->m[3][2] += (result->m[0][2] * tx + result->m[1][2] * ty + result->m[2][2] * tz);
    result->m[3][3] += (result->m[0][3] * tx + result->m[1][3] * ty + result->m[2][3] * tz);
}

void ESUTIL_API
esRotate(ESMatrix *result, GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
   GLfloat sinAngle, cosAngle;
   GLfloat mag = sqrtf(x * x + y * y + z * z);
      
   sinAngle = sinf ( angle * PI / 180.0f );
   cosAngle = cosf ( angle * PI / 180.0f );
   if ( mag > 0.0f )
   {
      GLfloat xx, yy, zz, xy, yz, zx, xs, ys, zs;
      GLfloat oneMinusCos;
      ESMatrix rotMat;
   
      x /= mag;
      y /= mag;
      z /= mag;

      xx = x * x;
      yy = y * y;
      zz = z * z;
      xy = x * y;
      yz = y * z;
      zx = z * x;
      xs = x * sinAngle;
      ys = y * sinAngle;
      zs = z * sinAngle;
      oneMinusCos = 1.0f - cosAngle;

      rotMat.m[0][0] = (oneMinusCos * xx) + cosAngle;
      rotMat.m[0][1] = (oneMinusCos * xy) - zs;
      rotMat.m[0][2] = (oneMinusCos * zx) + ys;
      rotMat.m[0][3] = 0.0F; 

      rotMat.m[1][0] = (oneMinusCos * xy) + zs;
      rotMat.m[1][1] = (oneMinusCos * yy) + cosAngle;
      rotMat.m[1][2] = (oneMinusCos * yz) - xs;
      rotMat.m[1][3] = 0.0F;

      rotMat.m[2][0] = (oneMinusCos * zx) - ys;
      rotMat.m[2][1] = (oneMinusCos * yz) + xs;
      rotMat.m[2][2] = (oneMinusCos * zz) + cosAngle;
      rotMat.m[2][3] = 0.0F; 

      rotMat.m[3][0] = 0.0F;
      rotMat.m[3][1] = 0.0F;
      rotMat.m[3][2] = 0.0F;
      rotMat.m[3][3] = 1.0F;

      esMatrixMultiply( result, &rotMat, result );
   }
}

void ESUTIL_API
esFrustum(ESMatrix *result, float left, float right, float bottom, float top, float nearZ, float farZ)
{
    float       deltaX = right - left;
    float       deltaY = top - bottom;
    float       deltaZ = farZ - nearZ;
    ESMatrix    frust;

    if ( (nearZ <= 0.0f) || (farZ <= 0.0f) ||
         (deltaX <= 0.0f) || (deltaY <= 0.0f) || (deltaZ <= 0.0f) )
         return;

    frust.m[0][0] = 2.0f * nearZ / deltaX;
    frust.m[0][1] = frust.m[0][2] = frust.m[0][3] = 0.0f;

    frust.m[1][1] = 2.0f * nearZ / deltaY;
    frust.m[1][0] = frust.m[1][2] = frust.m[1][3] = 0.0f;

    frust.m[2][0] = (right + left) / deltaX;
    frust.m[2][1] = (top + bottom) / deltaY;
    frust.m[2][2] = -(nearZ + farZ) / deltaZ;
    frust.m[2][3] = -1.0f;

    frust.m[3][2] = -2.0f * nearZ * farZ / deltaZ;
    frust.m[3][0] = frust.m[3][1] = frust.m[3][3] = 0.0f;

    esMatrixMultiply(result, &frust, result);
}


void ESUTIL_API 
esPerspective(ESMatrix *result, float fovy, float aspect, float nearZ, float farZ)
{
   GLfloat frustumW, frustumH;
   
   frustumH = tanf( fovy / 360.0f * PI ) * nearZ;
   frustumW = frustumH * aspect;

   esFrustum( result, -frustumW, frustumW, -frustumH, frustumH, nearZ, farZ );
}

void ESUTIL_API
esOrtho(ESMatrix *result, float left, float right, float bottom, float top, float nearZ, float farZ)
{
    float       deltaX = right - left;
    float       deltaY = top - bottom;
    float       deltaZ = farZ - nearZ;
    ESMatrix    ortho;

    if ( (deltaX == 0.0f) || (deltaY == 0.0f) || (deltaZ == 0.0f) )
        return;

    esMatrixLoadIdentity(&ortho);
    ortho.m[0][0] = 2.0f / deltaX;
    ortho.m[3][0] = -(right + left) / deltaX;
    ortho.m[1][1] = 2.0f / deltaY;
    ortho.m[3][1] = -(top + bottom) / deltaY;
    ortho.m[2][2] = -2.0f / deltaZ;
    ortho.m[3][2] = -(nearZ + farZ) / deltaZ;

    esMatrixMultiply(result, &ortho, result);
}


void ESUTIL_API
esMatrixMultiply(ESMatrix *result, ESMatrix *srcA, ESMatrix *srcB)
{
    ESMatrix    tmp;
    int         i;

	for (i=0; i<4; i++)
	{
		tmp.m[i][0] =	(srcA->m[i][0] * srcB->m[0][0]) +
						(srcA->m[i][1] * srcB->m[1][0]) +
						(srcA->m[i][2] * srcB->m[2][0]) +
						(srcA->m[i][3] * srcB->m[3][0]) ;

		tmp.m[i][1] =	(srcA->m[i][0] * srcB->m[0][1]) + 
						(srcA->m[i][1] * srcB->m[1][1]) +
						(srcA->m[i][2] * srcB->m[2][1]) +
						(srcA->m[i][3] * srcB->m[3][1]) ;

		tmp.m[i][2] =	(srcA->m[i][0] * srcB->m[0][2]) + 
						(srcA->m[i][1] * srcB->m[1][2]) +
						(srcA->m[i][2] * srcB->m[2][2]) +
						(srcA->m[i][3] * srcB->m[3][2]) ;

		tmp.m[i][3] =	(srcA->m[i][0] * srcB->m[0][3]) + 
						(srcA->m[i][1] * srcB->m[1][3]) +
						(srcA->m[i][2] * srcB->m[2][3]) +
						(srcA->m[i][3] * srcB->m[3][3]) ;
	}
    memcpy(result, &tmp, sizeof(ESMatrix));
}

void ESUTIL_API
esMatrixInverse(ESMatrix *result, ESMatrix *src)
{
	ESMatrix dummy;
	
	double		det_1;
	double		pos, neg, temp;
	
	pos = neg = 0.0;
	temp =  src->_m[0] * src->_m[5] * src->_m[10];
	if(temp >= 0.0) pos += temp; else neg += temp;
	temp =  src->_m[4] * src->_m[9] * src->_m[2];
	if(temp >= 0.0) pos += temp; else neg += temp;
	temp =  src->_m[8] * src->_m[1] * src->_m[6];
	if(temp >= 0.0) pos += temp; else neg += temp;
	temp = -src->_m[8] * src->_m[5] * src->_m[2];
	if(temp >= 0.0) pos += temp; else neg += temp;
	temp = -src->_m[4] * src->_m[1] * src->_m[10];
	if(temp >= 0.0) pos += temp; else neg += temp;
	temp = -src->_m[0] * src->_m[9] * src->_m[6];
	if(temp >= 0.0) pos += temp; else neg += temp;
	det_1 = pos + neg;
	
	if ((det_1 == 0.0) || (abs(det_1 / (pos - neg)) < 1.0e-15))
	{
        /* Matrix M has no inverse */
  //      printf("Matrix has no inverse : singular matrix\n");
        return;
    }
	else
	{
		det_1 = 1.0 / det_1;
        dummy._m[ 0] =   ( src->_m[ 5] * src->_m[10] - src->_m[ 9] * src->_m[ 6] ) * (float)det_1;
        dummy._m[ 1] = - ( src->_m[ 1] * src->_m[10] - src->_m[ 9] * src->_m[ 2] ) * (float)det_1;
        dummy._m[ 2] =   ( src->_m[ 1] * src->_m[ 6] - src->_m[ 5] * src->_m[ 2] ) * (float)det_1;
        dummy._m[ 4] = - ( src->_m[ 4] * src->_m[10] - src->_m[ 8] * src->_m[ 6] ) * (float)det_1;
        dummy._m[ 5] =   ( src->_m[ 0] * src->_m[10] - src->_m[ 8] * src->_m[ 2] ) * (float)det_1;
        dummy._m[ 6] = - ( src->_m[ 0] * src->_m[ 6] - src->_m[ 4] * src->_m[ 2] ) * (float)det_1;
        dummy._m[ 8] =   ( src->_m[ 4] * src->_m[ 9] - src->_m[ 8] * src->_m[ 5] ) * (float)det_1;
        dummy._m[ 9] = - ( src->_m[ 0] * src->_m[ 9] - src->_m[ 8] * src->_m[ 1] ) * (float)det_1;
        dummy._m[10] =   ( src->_m[ 0] * src->_m[ 5] - src->_m[ 4] * src->_m[ 1] ) * (float)det_1;
		
		dummy._m[12] = - ( src->_m[12] * dummy._m[ 0] + src->_m[13] * dummy._m[ 4] + src->_m[14] * dummy._m[ 8] );
        dummy._m[13] = - ( src->_m[12] * dummy._m[ 1] + src->_m[13] * dummy._m[ 5] + src->_m[14] * dummy._m[ 9] );
        dummy._m[14] = - ( src->_m[12] * dummy._m[ 2] + src->_m[13] * dummy._m[ 6] + src->_m[14] * dummy._m[10] );
		
        /* Fill in last row */
        dummy._m[ 3] = 0.0f;
		dummy._m[ 7] = 0.0f;
		dummy._m[11] = 0.0f;
        dummy._m[15] = 1.0f;
	}
	
	*result = dummy;
}

void ESUTIL_API
esMatrixTranspose(ESMatrix *result, ESMatrix* src)
{
	ESMatrix	tmp;
	
	tmp._m[ 0]=src->_m[ 0];	tmp._m[ 4]=src->_m[ 1];	tmp._m[ 8]=src->_m[ 2];	tmp._m[12]=src->_m[ 3];
	tmp._m[ 1]=src->_m[ 4];	tmp._m[ 5]=src->_m[ 5];	tmp._m[ 9]=src->_m[ 6];	tmp._m[13]=src->_m[ 7];
	tmp._m[ 2]=src->_m[ 8];	tmp._m[ 6]=src->_m[ 9];	tmp._m[10]=src->_m[10];	tmp._m[14]=src->_m[11];
	tmp._m[ 3]=src->_m[12];	tmp._m[ 7]=src->_m[13];	tmp._m[11]=src->_m[14];	tmp._m[15]=src->_m[15];
	
	*result = tmp;
}


void ESUTIL_API
esMatrixLoadIdentity(ESMatrix *result)
{
    memset(result, 0x0, sizeof(ESMatrix));
    result->m[0][0] = 1.0f;
    result->m[1][1] = 1.0f;
    result->m[2][2] = 1.0f;
    result->m[3][3] = 1.0f;
}

