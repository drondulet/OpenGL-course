package scene;

import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Vec3;

using MathHelper;
using Mesh;
using mme.math.glmatrix.Mat4Tools;


@:allow(scene.Scene3d)
class Node3d {
	
	public var parent(default, null): Null<Node3d>;
	public var name(default, null): Null<String>;
	public var mesh(default, null): Null<Mesh>;
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
	}
	
	public function addChild(child: Node3d): Void {
		
		child.parent = this;
		children.push(child);
	}
	
	public function removeChild(child: Node3d): Void {
		
		child.parent = null;
		children.remove(child);
	}
	
	public function setMesh(mesh: Mesh): Void {
		this.mesh = mesh;
	}
	
	public function setMeshShader(shader: Shader, toChildMesh: Bool = true): Void {
		
		if (mesh != null) {
			mesh.setShader(shader);
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
		
		if (mesh != null) {
			if (parent == null) {
				mesh.renderMesh(transform);
			}
			else {
				mesh.renderMesh(parent.transform.multiply(transform));
			}
		}
		
		for (child in children) {
			if (child.visible) {
				child.draw();
			}
		}
	}
}
