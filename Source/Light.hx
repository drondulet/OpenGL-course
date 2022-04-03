package;

import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLUniformLocation;
import mme.math.glmatrix.Vec3;


class Light {
	
	public var color: Vec3;
	public var ambientIntensity: Float;
	
	public var direction: Vec3;
	public var diffuseIntensity: Float;
	
	private var gl(get, never): WebGL2RenderContext;
	
	public function new(r: Float, g: Float, b: Float, ambientIntensity: Float) {
		
		this.color = Vec3.fromValues(r, g, b);
		this.ambientIntensity = ambientIntensity;
		
		direction = Vec3.fromValues(0, -1, 0);
		diffuseIntensity = 1 - ambientIntensity;
	}
	
	public function use(ambIntecityLoc: GLUniformLocation, ambColorLocation: GLUniformLocation,
						diffIntecityLoc: GLUniformLocation, directionLoc: GLUniformLocation): Void {
		
		gl.uniform3fv(ambColorLocation, color);
		gl.uniform1f(ambIntecityLoc, ambientIntensity);
		
		gl.uniform3fv(directionLoc, direction);
		gl.uniform1f(diffIntecityLoc, diffuseIntensity);
	}
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}