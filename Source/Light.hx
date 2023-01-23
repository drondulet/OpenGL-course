package;

import lime.graphics.WebGL2RenderContext;
import mme.math.glmatrix.Vec3;


class Light {
	
	public var color: Vec3;
	public var ambientIntensity: Float;
	
	public var diffuseIntensity: Float;
	
	private var gl(get, never): WebGL2RenderContext;
	
	public function new(r: Float, g: Float, b: Float, ambientIntensity: Float) {
		
		this.color = Vec3.fromValues(r, g, b);
		this.ambientIntensity = ambientIntensity;
		
		diffuseIntensity = 1 - ambientIntensity;
	}
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}