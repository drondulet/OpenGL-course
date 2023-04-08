package;

import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLTexture;


class ShadowMap {
	
	public var shadowWidth(default, null): Int;
	public var shadowHeight(default, null): Int;
	public var shadowMap(default, null): GLTexture;
	
	private var fbo: GLFramebuffer;
	private var gl(get, never): WebGL2RenderContext;
	
	public function new() {
		
		fbo = null;
		shadowMap = null;
	}
	
	public function dispose(): Void {
		
		if (fbo != null) gl.deleteFramebuffer(fbo);
		if (shadowMap != null) gl.deleteTexture(shadowMap);
	}
	
	public function init(width: Int, height: Int): Bool {
		
		shadowWidth = width;
		shadowHeight = height;
		
		fbo = gl.createFramebuffer();
		shadowMap = gl.createTexture();
		
		gl.bindTexture(gl.TEXTURE_2D, shadowMap);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.DEPTH_COMPONENT32F, shadowWidth, shadowHeight, 0, gl.DEPTH_COMPONENT, gl.FLOAT, null);
		// gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, shadowWidth, shadowHeight, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
		// gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		// gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_COMPARE_MODE, gl.COMPARE_REF_TO_TEXTURE);
		
		gl.bindTexture(gl.TEXTURE_2D, null);
		
		gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.TEXTURE_2D, shadowMap, 0);
		// gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, shadowMap, 0);
		
		gl.drawBuffers([gl.NONE]);
		gl.readBuffer(gl.NONE);
		
		var status: Int = gl.checkFramebufferStatus(gl.FRAMEBUFFER);
		if (status != gl.FRAMEBUFFER_COMPLETE) {
			
			throw 'Error creating framebuffer: ${status}';
			return false;
		}
		
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		
		return true;
	}
	
	public function begin(): Void {
		gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
	}
	
	public function end(): Void {
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
	}
	
	public function activate(textureUnit: Int): Void {
		
		gl.activeTexture(textureUnit);
		gl.bindTexture(gl.TEXTURE_2D, shadowMap);
	}
	
	public function deactivate(textureUnit: Int): Void {
		
		gl.activeTexture(textureUnit);
		gl.bindTexture(gl.TEXTURE_2D, null);
	}
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}
