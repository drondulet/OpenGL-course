package;

import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLTexture;
import lime.utils.UInt8Array;

enum ETextureType {
	diffuse;
	normal;
}

class Texture {
	
	static public var defaultNormalMap(get, null): Texture = null;
	static private function get_defaultNormalMap(): Texture {
		if (defaultNormalMap == null) {
			
			var bitmap: UInt8Array = new UInt8Array([127, 127, 255, 255]);
			var buffer: ImageBuffer = new ImageBuffer(bitmap, 1, 1);
			var texture: Image = new Image(buffer);
			
			defaultNormalMap = new Texture(ETextureType.normal);
			defaultNormalMap.loadRGBA(texture);
		}
		return defaultNormalMap;
	}
	
	
	private var texture: GLTexture;
	private var type: ETextureType;
	
	private var gl(get, never): WebGL2RenderContext;
	
	public function new(type: ETextureType) {
		this.type = type;
	}
	
	public function loadRGBA(image: Image): Void {
		initTexture(image, gl.RGBA);
	}
	
	public function loadRGB(image: Image): Void {
		initTexture(image, gl.RGB);
	}
	
	public function use(): Void {
		
		var target: Int = 
			switch (type) {
				case diffuse: gl.TEXTURE0;
				case normal: gl.TEXTURE1;
			}
		gl.activeTexture(target);
		gl.bindTexture(gl.TEXTURE_2D, texture);
	}
	
	public function unUse(): Void {
		
		var target: Int = 
			switch (type) {
				case diffuse: gl.TEXTURE0;
				case normal: gl.TEXTURE1;
			}
		gl.activeTexture(target);
		gl.bindTexture(gl.TEXTURE_2D, null);
	}
	
	public function dispose(): Void {
		gl.deleteTexture(texture);
	}
	
	private function initTexture(image: Image, format: Int): Void {
		
		texture = gl.createTexture();
		
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, format, image.width, image.height, 0, format, gl.UNSIGNED_BYTE, image.data);
		
		gl.generateMipmap(gl.TEXTURE_2D);
		
		gl.bindTexture(gl.TEXTURE_2D, null);
	}
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}
