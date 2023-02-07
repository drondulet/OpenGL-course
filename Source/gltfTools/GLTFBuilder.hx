package gltfTools;

import Mesh;
import gltf.GLTF;
import gltf.schema.TGLTF;
import gltf.types.Accessor;
import gltf.types.BufferView;
import gltf.types.Material;
import gltf.types.MeshPrimitive;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.Path;
import lime.graphics.Image;
import lime.utils.ArrayBufferView;
import lime.utils.Assets;
import lime.utils.Log;
import scene.Node3d;

using gltfTools.GLTFBuilder;
using gltfTools.GLTFHelper;


class GLTFBuilder {
	
	static public function extracPrimitiveData(primitive: MeshPrimitive): GlMeshData {
		
		var indexType: Int = primitive.indices.componentType;
		var indicesBytes: ArrayBufferView = extractIndices(primitive.indices);
		var indexData: GlIndexBufferData = {indices: indicesBytes, componentType: indexType};
		
		var vertexData: GlVertexBufferData = extractVertexData(primitive.attributes);
		
		return {indices: indexData, vertices: vertexData};
	}
	
	static private function extractIndices(indices: Accessor): ArrayBufferView {
		
		var count: Int = indices.count * indices.componentType.getByteSize();
		var bytes: Bytes = extractBytesFromBufferView(indices.bufferView, count, indices.byteOffset);
		return bytes.toTypedArray(indices.componentType);
	}
	
	static private function extractBytesFromBufferView(bufferView: BufferView, size: Int = 0, offset: Int = 0): Bytes {
		
		if (bufferView.byteStride != 0) {
			throw 'Unsupported "bufferView.stride" property';
		}
		var dataSize: Int = size == 0 ? bufferView.byteLength : size;
		var result: Bytes = Bytes.alloc(dataSize);
		result.blit(0, bufferView.buffer.data, offset + bufferView.byteOffset, dataSize);
		
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
		var length: Int = byteBuffer.length; // after getBytes() buffer will die on static target
		bytes.blit(0, byteBuffer.getBytes(), 0, length); // need to cut spare buffer bytes
		
		return {
			data: bytes,
			position: posView,
			normal: normalView,
			textCoord: texCoords,
			tangent: tangent
		};
	}
	
	
	static public function getFromFile(path: String, ?binPath: String, ?texturesPath: String): GLTFBuilder {
		
		var inst: GLTFBuilder = new GLTFBuilder();
		
		inst.isGlb = Path.extension(path) == "glb";
		inst.texturePath = texturesPath != null ? texturesPath : Path.directory(path);
		
		if (inst.isGlb) {
			
			var rawGlb: Bytes = Assets.getBytes(path);
			inst.gltf = GLTF.parseAndLoadGLB(rawGlb);
		}
		else {
			
			var rawJson: String = Assets.getText(path);
			var json: TGLTF = GLTF.parse(rawJson);
			var bufferPath: String = binPath != null ? binPath : Path.directory(path);
			var binBuffers: Array<Bytes> = [];
			for (buffer in json.buffers) {
				binBuffers.push(Assets.getBytes('${bufferPath}/${buffer.uri}'));
			}
			inst.gltf = GLTF.parseAndLoad(rawJson, binBuffers);
		}
		
		inst.loadTextures();
		
		return inst;
	}
	
	
	public var isGlb(default, null): Bool;
	public var gltf(default, null): GLTF;
	public var textures(default, null): Vector<Image>;
	
	private var texturePath: String;
	
	private function new() {
		
	}
	
	public function dispose(): Void {
		
	}
	
	public function getNodeWithName(name: String): Null<Node3d> {
		
		var node: Null<Node3d> = null;
		
		for (scene in gltf.scenes) {
			
			for (gltfNode in scene.nodes) {
				
				if (gltfNode.name == name) {
					node = Node3d.createFromGLTFBuilder(gltfNode, this);
				}
			}
		}
		
		if (node == null) {
			Log.warn('Node with name "${name}" not found in GLTF');
		}
		
		return node;
	}
	
	public function getDiffuseTexture(mat: Material): Null<Image> {
		
		var result: Null<Image> = null;
		
		if (mat.pbrMetallicRoughness != null && mat.pbrMetallicRoughness.baseColorTexture != null) {
			result = textures[mat.pbrMetallicRoughness.baseColorTexture.index];
		}
		
		return result;
	}
	
	public function getNormalTexture(mat: Material): Null<Image> {
		
		var result: Null<Image> = null;
		
		if (mat.normalTexture != null) {
			result = textures[mat.normalTexture.index];
		}
		
		return result;
	}
	
	private function loadTextures(): Void {
		
		textures = new Vector(gltf.images.length);
		
		for (i in 0 ... gltf.images.length) {
			
			if (isGlb) {
				Image.loadFromBytes(extractBytesFromBufferView(gltf.images[i].bufferView)).onComplete(image -> textures[i] = image);
			}
			else {
				textures[i] = Assets.getImage('${texturePath}/${gltf.images[i].uri}');
			}
		}
	}
}
