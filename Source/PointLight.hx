package;

import lime.graphics.opengl.GLUniformLocation;
import mme.math.glmatrix.Vec3;

class PointLight extends Light {
	
	public var position: Vec3;
	public var exponent: Float;
	public var linear: Float;
	public var constant: Float;
	
	public function new(r: Float, g: Float, b: Float, ambientIntensity: Float) {
		
		super(r, g, b, ambientIntensity);
		
		exponent = 0.0;
		linear = 0.0;
		constant = 1.0;
	}
	
	public function use(ambIntencityLoc: GLUniformLocation, ambColorLocation: GLUniformLocation,
		diffIntecityLoc: GLUniformLocation, positionLoc: GLUniformLocation,
		expLoc: GLUniformLocation, linearLoc: GLUniformLocation, constLoc: GLUniformLocation): Void {
		
		gl.uniform3fv(ambColorLocation, color);
		gl.uniform1f(ambIntencityLoc, ambientIntensity);
		gl.uniform1f(diffIntecityLoc, diffuseIntensity);
		
		gl.uniform3fv(positionLoc, position);
		
		gl.uniform1f(expLoc, exponent);
		gl.uniform1f(linearLoc, linear);
		gl.uniform1f(constLoc, constant);
	}
}