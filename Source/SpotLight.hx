package;

import lime.graphics.opengl.GLUniformLocation;
import mme.math.glmatrix.Vec3;

using MathHelper;
using mme.math.glmatrix.Vec3Tools;

class SpotLight extends PointLight {
	
	public var direction(default, set): Vec3;
	private function set_direction(value: Vec3): Vec3 {
		
		direction = value.normalize();
		return value;
	}
	
	public var edge(default, set): Float;
	private function set_edge(value: Float): Float {
		
		edge = value;
		procEdge = Math.cos(value.toRadians());
		return value;
	}
	
	private var procEdge: Float;
	
	public function new(r: Float, g: Float, b: Float, ambientIntensity: Float) {
		
		super(r, g, b, ambientIntensity);
		direction = Vec3.fromValues(0, 0, 1);
		edge = 90;
		procEdge = Math.cos(edge.toRadians());
	}
	
	public function useSpot(ambIntencityLoc: GLUniformLocation, ambColorLoc: GLUniformLocation,
		diffuseIntensityLoc: GLUniformLocation, positionLoc: GLUniformLocation, directionLoc: GLUniformLocation,
		expLoc: GLUniformLocation, linearLoc: GLUniformLocation, constLoc: GLUniformLocation, edgeLoc: GLUniformLocation): Void {
		
		gl.uniform3fv(ambColorLoc, color);
		gl.uniform1f(ambIntencityLoc, ambientIntensity);
		gl.uniform1f(diffuseIntensityLoc, diffuseIntensity);
		
		gl.uniform3fv(positionLoc, position);
		
		gl.uniform1f(expLoc, exponent);
		gl.uniform1f(linearLoc, linear);
		gl.uniform1f(constLoc, constant);
		
		gl.uniform3fv(directionLoc, direction);
		gl.uniform1f(edgeLoc, procEdge);
	}
}
