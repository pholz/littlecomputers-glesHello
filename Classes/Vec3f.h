
/*
 *  Vec3f.h
 *  glesHello
 *
 *  Created by Peter Holzkorn on 25.02.10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#include <math.h>

class Vec3f
{
public:

	float x,y,z;

	
	
	
	
	Vec3f(){
		x = y = z = 0.0f;
	}
	
	Vec3f(float _x, float _y, float _z) {
		x = _x; y = _y; z = _z;
	}
	~Vec3f() { };
	
	Vec3f operator+ (Vec3f v) {
		return Vec3f(x+v.x, y+v.y, z+v.z);
	}
	
	Vec3f operator- (Vec3f v) {
		return Vec3f(x-v.x, y-v.y, z-v.z);
	}
	
	Vec3f operator* (float f) {
		return Vec3f(x*f, y*f, z*f);
	}
	
	Vec3f operator/ (float f) {
		return Vec3f(x/f, y/f, z/f);
	}
	
	float length() {
		return sqrt(x*x + y*y + z*z);
	}
	
	Vec3f norm() {
		float len = length();
		return Vec3f(x/len,y/len,z/len);
	}
	
	float dot(Vec3f v) {
		return (x*v.x + y*v.y + z*v.z);
	}
	
	Vec3f cross(Vec3f v) {
		return Vec3f(y*v.z - z*v.y, z*v.x - x*v.z, x*v.y - y*v.x);
	}
	

	
	
};