package;

import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLUniformLocation;


class Material {
	
	public var specilarIntensity(default, null): Float;
	public var shininess(default, null): Float;
	
	private var gl(get, never): WebGL2RenderContext;
	
	public function new(specIntecity: Float = 0, shine: Float = 0) {
		
		specilarIntensity = specIntecity;
		shininess = shine;
	}
	
	public function useMaterial(specIntesityLoc: GLUniformLocation, shineLoc: GLUniformLocation): Void {
		
		gl.uniform1f(specIntesityLoc, specilarIntensity);
		gl.uniform1f(shineLoc, shininess);
	}
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}