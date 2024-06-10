package;

import Texture.ETextureType;
import gltfTools.GLTFBuilder;
import lime.graphics.Image;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLUniformLocation;


typedef MaterialTextures = {
	var diffuse: Image;
	var normal: Image;
}

class Material {
	
	static private final textureCache: Map<Image, Texture> = [];
	static public function clearCache(): Void {
		for (texture in textureCache) {
			texture.dispose();
		}
		textureCache.clear();
	}
	
	static public function createFromGLTFBuilder(mat: gltf.types.Material, builder: GLTFBuilder): Material {
		
		var inst: Material = new Material(1, 256);
		
		var diffuse: Null<Image> = builder.getDiffuseTexture(mat);
		
		if (diffuse != null) {
			
			if (textureCache.exists(diffuse)) {
				inst.diffuse = textureCache[diffuse];
			}
			else {
				
				inst.diffuse = new Texture(ETextureType.diffuse);
				inst.diffuse.loadRGBA(diffuse);
				textureCache[diffuse] = inst.diffuse;
			}
		}
		
		var normal: Null<Image> = builder.getNormalTexture(mat);
		if (normal != null) {
			
			if (textureCache.exists(normal)) {
				inst.normal = textureCache[normal];
			}
			else {
				
				inst.normal = new Texture(ETextureType.normal);
				inst.normal.loadRGBA(normal);
				textureCache[normal] = inst.normal;
			}
		}
		else {
			inst.setNormalTexture(Texture.defaultNormalMap);
		}
		
		return inst;
	}
	
	
	public var specilarIntensity(default, null): Float;
	public var shininess(default, null): Float;
	
	private var gl(get, never): WebGL2RenderContext;
	private var diffuse: Null<Texture>;
	private var normal: Null<Texture>;
	
	public function new(specIntecity: Float = 0, shine: Float = 0) {
		
		specilarIntensity = specIntecity;
		shininess = shine;
		diffuse = null;
		normal = null;
	}
	
	public function dispose() {
		
		if (diffuse != null) {
			diffuse.dispose();
		}
		if (normal != null) {
			normal.dispose();
		}
	}
	
	public function use(specIntesityLoc: GLUniformLocation, shineLoc: GLUniformLocation): Void {
		
		gl.uniform1f(specIntesityLoc, specilarIntensity);
		gl.uniform1f(shineLoc, shininess);
		if (diffuse != null) {
			diffuse.use();
		}
		if (normal != null) {
			normal.use();
		}
	}
	
	public function unUse(): Void {
		
		if (diffuse != null) {
			diffuse.unUse();
		}
		if (normal != null) {
			normal.unUse();
		}
	}
	
	public function setDiffuseTexture(texture: Texture): Void {
		diffuse = texture;
	}
	
	public function setNormalTexture(texture: Texture): Void {
		normal = texture;
	}
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}
