package;

import lime.graphics.Image;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLTexture;

class Texture {
	
	private var texture: GLTexture;
	private var gl: WebGL2RenderContext;
	
	public function new(gl: WebGL2RenderContext) {
		this.gl = gl;
	}
	
	public function load(image: Image): Void {
		
		texture = gl.createTexture();
		
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, image.width, image.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.data);
		
		gl.generateMipmap(gl.TEXTURE_2D);
		
		gl.bindTexture(0, null);
	}
	
	public function use(): Void {
		gl.activeTexture(gl.TEXTURE0);
	}
	
	public function dispose(): Void {
		gl.deleteTexture(texture);
	}
}