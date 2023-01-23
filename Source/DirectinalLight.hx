package;

import lime.graphics.opengl.GLUniformLocation;
import mme.math.glmatrix.Vec3;

class DirectinalLight extends Light {
	
	public var direction: Vec3;
	
	public function new(r: Float, g: Float, b: Float, ambientIntensity: Float) {
		
		super(r, g, b, ambientIntensity);
		direction = Vec3.fromValues(0, -1, 0);
	}
	
	public function use(ambIntencityLoc: GLUniformLocation, ambColorLoc: GLUniformLocation,
		diffuseIntensityLoc: GLUniformLocation, directionLoc: GLUniformLocation): Void {
		
		gl.uniform3fv(ambColorLoc, color);
		gl.uniform1f(ambIntencityLoc, ambientIntensity);
		gl.uniform1f(diffuseIntensityLoc, diffuseIntensity);
		
		gl.uniform3fv(directionLoc, direction);
	}
}
