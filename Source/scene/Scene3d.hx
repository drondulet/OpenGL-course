package scene;

import gltf.types.Scene;

using scene.Node3d;

class Scene3d {
	
	static public function createFromGLTF(scene: Scene): Scene3d {
		
		var inst: Scene3d = new Scene3d();
		inst.name = scene.name;
		
		for (node in scene.nodes) {
			inst.addNode(node.createFromGLTF());
		}
		
		return inst;
	}
	
	
	public var name: Null<String>;
	private var nodes: Map<Node3d, Bool>;
	
	public function new() {
		nodes = [];
	}
	
	public function dispose(): Void {
		
		for (node in nodes.keys()) {
			node.dispose();
		}
		nodes.clear();
		nodes = null;
	}
	
	public function addNode(node: Node3d): Void {
		
		node.scene = this;
		nodes[node] = true;
	}
	
	public function removeNode(node: Node3d): Void {
		
		node.scene = null;
		nodes.remove(node);
	}
	
	public function draw(): Void {
		
		for (node in nodes.keys()) {
			if (node.visible) {
				node.draw();
			}
		}
	}
}
