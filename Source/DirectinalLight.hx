package;

import Shader.DirectionalLightUniforms;
import lime.graphics.opengl.GLUniformLocation;
import mme.math.glmatrix.Vec3;

class DirectinalLight extends Light {
	
	public var direction: Vec3;
	
	public function new(r: Float, g: Float, b: Float, ambientIntensity: Float) {
		
		super(r, g, b, ambientIntensity);
		direction = Vec3.fromValues(0, -1, 0);
	}
	
	public function use(light: DirectionalLightUniforms, vLightDir: GLUniformLocation): Void {
		
		gl.uniform3fv(light.color, color);
		gl.uniform1f(light.ambientIntensity, ambientIntensity);
		gl.uniform1f(light.diffuseIntensity, diffuseIntensity);
		
		gl.uniform3fv(light.direction, direction);
		
		gl.uniform3fv(vLightDir, direction);
	}
}
