package gltfTools;

import gltf.GLTF;
import gltf.schema.TAttributeType;
import gltf.schema.TComponentType;
import lime.utils.Log;
import scene.Scene3d;

using scene.Node3d;


class GLTFParser {
	
	static var cache: Map<AssetData, GLTF> = new Map<AssetData, GLTF>();
	
	static public function getByteSize(componentType: TComponentType): Int {
		return switch (componentType) {
			case BYTE: 1;
			case UNSIGNED_BYTE: 1;
			case SHORT: 2;
			case UNSIGNED_SHORT: 2;
			case UNSIGNED_INT: 4;
			case FLOAT: 4;
		}
	}
	
	static public function getComponentSize(type: TAttributeType): Int {
		return switch (type) {
			case SCALAR: 1;
			case VEC2: 2;
			case VEC3: 3;
			case VEC4: 4;
			case MAT2: 2 * 2;
			case MAT3: 3 * 3;
			case MAT4: 4 * 4;
		}
	}
	
	static public function getNodeWithName(data: AssetData, name: String): Null<Node3d> {
		
		var gltfData: GLTF = getFromData(data);
		
		var node: Null<Node3d> = null;
		
		for (scene in gltfData.scenes) {
			
			for (gltfNode in scene.nodes) {
				
				if (gltfNode.name == name) {
					node = Node3d.createFromGLTF(gltfNode);
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
