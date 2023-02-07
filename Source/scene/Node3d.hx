package scene;

import gltf.types.Node;
import gltfTools.GLTFBuilder;
import haxe.ds.Vector;
import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Vec3;

using MathHelper;
using Mesh;
using mme.math.glmatrix.Mat4Tools;


@:allow(scene.Scene3d)
class Node3d {
	
	static public function createFromGLTFBuilder(node: Node, builder: GLTFBuilder): Node3d {
		
		var inst: Node3d = new Node3d(Mat4.fromArray(node.matrix.toArray()));
		
		if (node.mesh != null) {
			
			var count: Int = node.mesh.primitives.length;
			inst.meshes = new Vector(count);
			for (i in 0...count) {
				inst.meshes[i] = node.mesh.createFromGLTFBuilder(builder, i);
			}
		}
		
		for (child in node.children) {
			inst.addChild(Node3d.createFromGLTFBuilder(child, builder));
		}
		
		return inst;
	}
	
	public var parent(default, null): Null<Node3d>;
	public var name(default, null): Null<String>;
	public var meshes(default, null): Vector<Mesh>;
	public var visible: Bool;
	
	private var children: Array<Node3d>;
	private var scene: Null<Scene3d>;
	private var transform: Mat4;
	
	public function new(?transform: Null<Mat4>) {
		
		children = [];
		visible = true;
		this.transform = transform != null ? transform : Mat4Tools.identity();
	}
	
	public function dispose(): Void {
		
		for (child in children) {
			child.dispose();
		}
		
		if (meshes != null) {
			for (mesh in meshes) {
				mesh.dispose();
			}
		}
	}
	
	public function addChild(child: Node3d): Void {
		
		child.parent = this;
		children.push(child);
	}
	
	public function removeChild(child: Node3d): Void {
		
		child.parent = null;
		children.remove(child);
	}
	
	public function setMesh(mesh: Mesh, disposeOld: Bool = true): Void {
		setMeshes([mesh], disposeOld);
	}
	
	public function setMeshes(newMeshes: Array<Mesh>, disposeOld: Bool = true): Void {
		
		if (disposeOld && meshes != null) {
			for (mesh in meshes) {
				mesh.dispose();
			}
		}
		
		meshes = new Vector(newMeshes.length);
		for (i in 0...newMeshes.length) {
			meshes[i] = newMeshes[i];
		}
	}
	
	public function setMeshShader(shader: Shader, toChildMesh: Bool = true): Void {
		
		if (meshes != null) {
			
			for (mesh in meshes) {
				mesh.setShader(shader);
			}
		}
		
		if (toChildMesh) {
			for (child in children) {
				child.setMeshShader(shader);
			}
		}
	}
	
	public function setPosition(pos: Vec3): Void {
		transform.translate(pos, transform);
	}
	
	public function setRotation(angleDeg: Float, axis: Vec3): Void {
		transform.rotate(angleDeg.toRadians(), axis, transform);
	}
	
	public function setScale(scale: Float): Void {
		transform.scale(Vec3.fromValues(scale, scale, scale), transform);
	}
	
	public function setScaleX(scaleX: Float): Void {
		transform.scale(Vec3.fromValues(scaleX, 1.0, 1.0), transform);
	}
	
	public function setScaleY(scaleY: Float): Void {
		transform.scale(Vec3.fromValues(1.0, scaleY, 1.0), transform);
	}
	
	public function setScaleZ(scaleZ: Float): Void {
		transform.scale(Vec3.fromValues(1.0, 1.0, scaleZ), transform);
	}
	
	public function resetTransform(): Void {
		transform.identity();
	}
	
	private function draw(): Void {
		
		if (meshes != null) {
			
			for (mesh in meshes) {
				
				if (parent == null) {
					mesh.renderMesh(transform);
				}
				else {
					mesh.renderMesh(parent.transform.multiply(transform)); // TODO: make it right way
				}
			}
		}
		
		for (child in children) {
			if (child.visible) {
				child.draw();
			}
		}
	}
}
