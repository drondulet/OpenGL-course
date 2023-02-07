package gltfTools;

import gltf.schema.TAttributeType;
import gltf.schema.TComponentType;
import haxe.io.Bytes;
import lime.utils.ArrayBufferView;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.utils.Int8Array;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import lime.utils.UInt8Array;


class GLTFHelper {
	
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
	
	static public function toTypedArray(bytes: Bytes, componentType: TComponentType): ArrayBufferView {
		
		var result: ArrayBufferView;
		
		#if js
		var data = bytes.getData();
		result = 
			switch (componentType) {
				case BYTE: new Int8Array(data);
				case SHORT: new Int16Array(data);
				case FLOAT: new Float32Array(data);
				case UNSIGNED_BYTE: new UInt8Array(data);
				case UNSIGNED_SHORT: new UInt16Array(data);
				case UNSIGNED_INT: new UInt32Array(data);
			}
		#else
		result = 
			switch (componentType) {
				case BYTE: new Int8Array(bytes);
				case SHORT: new Int16Array(bytes);
				case FLOAT: new Float32Array(bytes);
				case UNSIGNED_BYTE: new UInt8Array(bytes);
				case UNSIGNED_SHORT: new UInt16Array(bytes);
				case UNSIGNED_INT: new UInt32Array(bytes);
			}
		#end
		
		return result;
	}
}
