package gltfTools;

import Mesh;
import gltf.schema.TComponentType;
import gltf.types.Accessor;
import gltf.types.BufferView;
import gltf.types.MeshPrimitive;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import lime.utils.ArrayBufferView;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.utils.Int8Array;
import lime.utils.Log;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import lime.utils.UInt8Array;

using gltfTools.GLTFBuilder;
using gltfTools.GLTFParser;


class GLTFBuilder {
	
	static public function extracMeshData(mesh: gltf.types.Mesh): GlMeshData {
		
		if (mesh.primitives.length > 1) {
			Log.warn('Multiple primitives, only first is processing.');
		}
		
		var primitive: MeshPrimitive = mesh.primitives[0];
		
		var indexType: Int = primitive.indices.componentType;
		var indicesBytes: ArrayBufferView = extractIndices(primitive.indices);
		var indexData: GlIndexBufferData = {indices: indicesBytes, componentType: indexType};
		
		var vertexData: GlVertexBufferData = extractVertexData(primitive.attributes);
		
		return {indices: indexData, vertices: vertexData};
	}
	
	static private function extractIndices(indices: Accessor): ArrayBufferView {
		
		var bytes: Bytes = extractBytesFromBufferView(indices.bufferView);
		return bytes.toTypedArray(indices.componentType);
	}
	
	static private function extractBytesFromBufferView(bufferView: BufferView): Bytes {
		
		var result: Bytes = Bytes.alloc(bufferView.byteLength);
		result.blit(0, bufferView.buffer.data, bufferView.byteOffset, bufferView.byteLength);
		
		return result;
	}
	
	static private function extractVertexData(attributes: Vector<TAttribute>): GlVertexBufferData {
		
		var posView: GlBufferView = null;
		var normalView: GlBufferView = null;
		var texCoords: GlBufferView = null;
		var tangent: GlBufferView = null;
		
		var rawData: Null<Bytes> = null;
		
		var byteBuffer: BytesBuffer = new BytesBuffer(); //TODO: calculate beforehand and use bytes?
		var startOffset: Int = 0;
		var accessor: Accessor;
		
		for (attrib in attributes) {
			
			if (rawData == null) {
				rawData = attrib.accessor.bufferView.buffer.data;
			}
			else if (rawData != attrib.accessor.bufferView.buffer.data) {
				throw 'Different buffers, shared expected';
			}
			
			accessor = attrib.accessor;
			
			var componentCount: Int = accessor.count;
			var componentSize: Int = accessor.type.getComponentSize();
			var byteOffset: Int = accessor.byteOffset + accessor.bufferView.byteOffset;
			var dataSize: Int = componentSize * accessor.componentType.getByteSize();
			var pos: Int = 0;
			for (i in 0 ... componentCount) {
				
				pos = byteOffset + i * dataSize;
				byteBuffer.add(rawData.sub(pos, dataSize));
			}
			
			var vertexData: GlBufferView = {
				componentSize: componentSize,
				componentType: accessor.componentType,
				normalized: true,
				stride: dataSize,
				count: componentCount,
				start: startOffset
			};
			
			switch (attrib.name) {
				case "POSITION": posView = vertexData; posView.normalized = false;
				case "NORMAL": normalView = vertexData;
				case "TEXCOORD_0": texCoords = vertexData;
				case "TANGENT": tangent = vertexData;
			}
			
			startOffset = byteBuffer.length;
		}
		
		var bytes: Bytes = Bytes.alloc(byteBuffer.length);
		bytes.blit(0, byteBuffer.getBytes(), 0, byteBuffer.length); // need to cut spare buffer bytes
		
		return {
			data: bytes,
			position: posView,
			normal: normalView,
			textCoord: texCoords,
			tangent: tangent
		};
	}
	
	static private function toTypedArray(bytes: Bytes, componentType: TComponentType): ArrayBufferView {
		
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
