package;

import gltf.GLTF;
import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Vec3;

using MathHelper;
using mme.math.glmatrix.Mat4Tools;

class Model {
	
	static public function createFromGLB(data: Dynamic): Model {
		
		var inst: Model = new Model();
		
		var glbModel: GLTF = GLTF.parseAndLoadGLB(data);
		
		if (glbModel == null) {
			throw 'Error parsing gltf data';
		}
		
		for (mesh in glbModel.meshes) {
			
			for (primitive in mesh.primitives) {
				
			}
		}
		
		return inst;
	}
	
	static public function createFromMesh(mesh: Mesh, ?texture: Null<Texture>): Model {
		
		var inst: Model = new Model();
		inst.meshes.push(mesh);
		if (texture != null) {
			inst.textures[mesh] = texture;
		}
		
		return inst;
	}
	
	
	public var transform(default, null): Mat4;
	
	private var meshes: Array<Mesh>;
	private var textures: Map<Mesh, Texture>;
	
	private function new() {
		
		transform = new Mat4();
		meshes = [];
		textures = [];
	}
	
	public function setPosition(pos: Vec3): Void {
		transform.translate(pos);
	}
	
	public function setRotation(angleDeg: Float, axis: Vec3): Void {
		transform.rotate(angleDeg.toRadians(), axis);
	}
	
	public function setScale(scale: Float): Void {
		transform.scale(Vec3.fromValues(scale, scale, scale));
	}
	
	public function setScaleX(scaleX: Float): Void {
		transform.scale(Vec3.fromValues(scaleX, 1.0, 1.0));
	}
	
	public function setScaleY(scaleY: Float): Void {
		transform.scale(Vec3.fromValues(1.0, scaleY, 1.0));
	}
	
	public function setScaleZ(scaleZ: Float): Void {
		transform.scale(Vec3.fromValues(1.0, 1.0, scaleZ));
	}
	
	public function render(): Void {
		
		for (mesh in meshes) {
			
			if (textures.exists(mesh)) {
				textures[mesh].use();
			}
			
			mesh.renderMesh();
			
			if (textures.exists(mesh)) {
				textures[mesh].unUse();
			}
		}
	}
	
	public function dispose(): Void {
		
		for (mesh in meshes) {
			mesh.dispose();
		}
		
		for (texture in textures) {
			texture.dispose();
		}
		
		meshes = null;
		textures = null;
	}
}
