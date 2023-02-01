package;

import lime.utils.Log;
import gltf.GLTF;
import scene.Scene3d;

using scene.Node3d;

class GLTFParser {
	
	static var cache: Map<AssetData, GLTF> = new Map<AssetData, GLTF>();
	
	static public function getNodeWithName(data: AssetData, name: String): Null<Node3d> {
		
		var gltfData: GLTF = getFromData(data);
		
		var node: Null<Node3d> = null;
		
		for (scene in gltfData.scenes) {
			
			for (gltfNode in scene.nodes) {
				
				if (gltfNode.name == name) {
					node = gltfNode.createFromGLTF();
				}
			}
		}
		
		if (node == null) {
			Log.warn('Node with name "${name}" not found in GLTF');
		}
		
		return node;
	}
	
	static public function parseScene(data: AssetData): Scene3d {
		
		var gltfData: GLTF = getFromData(data);
		
		var scene: Scene3d = new Scene3d();
		
		for (gltfScene in gltfData.scenes) {
			
		}
		
		return scene;
	}
	
	static private function getFromData(asset: AssetData): GLTF {
		
		var gltfData: GLTF;
		
		if (cache.exists(asset)) {
			gltfData = cache[asset];
		}
		else {
			
			gltfData = GLTF.parseAndLoadGLB(asset.data);
			cache[asset] = gltfData;
		}
		
		if (gltfData == null) {
			throw 'Error parsing GLTF data';
		}
		
		return gltfData;
	}
}
