package;

import gltf.schema.TAttributeType;
import gltf.types.Accessor;
import gltf.types.BufferView;
import gltf.types.MeshPrimitive;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.utils.ArrayBufferView;
import lime.utils.Float32Array;
import lime.utils.Int16Array;
import lime.utils.Int8Array;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import lime.utils.UInt8Array;
import mme.math.glmatrix.Mat4;

typedef DataView = {
	var type: TAttributeType;
	var glComponentType: Int;
	var count: Int;
	var start: Int;
}

typedef VertexData = {
	var data: Bytes;
	var position: DataView;
	var normal: DataView;
	var textCoord: DataView;
	var tangent: DataView;
}

class Mesh {
	
	static public function createFromRawData(vertices: Float32Array, indices: UInt16Array): Mesh {
		
		var inst: Mesh = new Mesh();
		inst.createMesh(vertices, indices);
		
		return inst;
	}
	
	static public function createFromGLTF(mesh: gltf.types.Mesh): Mesh {
		
		var inst: Mesh = new Mesh();
		inst.name = mesh.name;
		
		var indices: ArrayBufferView;
		var vertexData: VertexData;
		
		var primitive: MeshPrimitive = mesh.primitives[0];
		inst.indexBufferType = primitive.indices.componentType;
		indices = extractIndices(primitive.indices);
		vertexData = extractVertexData(primitive.attributes);
		
		inst.createFromVertexData(vertexData, indices);
		
		return inst;
	}
	
	static private function extractIndices(indices: Accessor): ArrayBufferView {
		
		var result: ArrayBufferView;
		
		var bytes: Bytes = extractBytesFromBufferView(indices.bufferView);
		
		#if js
		var data = bytes.getData();
		result = 
			switch (indices.componentType) {
				case BYTE: new Int8Array(data);
				case SHORT: new Int16Array(data);
				case FLOAT: new Float32Array(data);
				case UNSIGNED_BYTE: new UInt8Array(data);
				case UNSIGNED_SHORT: new UInt16Array(data);
				case UNSIGNED_INT: new UInt32Array(data);
			}
		#else
		result = 
			switch (indices.componentType) {
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
	
	static private function extractBytesFromBufferView(bufferView: BufferView): Bytes {
		
		var result: Bytes = Bytes.alloc(bufferView.byteLength);
		result.blit(0, bufferView.buffer.data, bufferView.byteOffset, bufferView.byteLength);
		
		return result;
	}
	
	static private function extractVertexData(attributes: Vector<TAttribute>): VertexData {
		
		var result: VertexData;
		var posView: DataView = null;
		var normalView: DataView = null;
		var texCoords: DataView = null;
		var tangent: DataView = null;
		
		var rawData: Null<Bytes> = null;
		
		var byteBuffer: BytesBuffer = new BytesBuffer();
		var bufferView: BufferView;
		var accessor: Accessor;
		for (attrib in attributes) {
			
			if (rawData == null) {
				rawData = attrib.accessor.bufferView.buffer.data;
			}
			else if (rawData != attrib.accessor.bufferView.buffer.data) {
				throw 'Different buffers, shared expected';
			}
			
			accessor = attrib.accessor;
			bufferView = accessor.bufferView;
			
			var byteCount: Int = 
					switch (accessor.componentType) {
						case BYTE: 1;
						case UNSIGNED_BYTE: 1;
						case SHORT: 2;
						case UNSIGNED_SHORT: 2;
						case UNSIGNED_INT: 4;
						case FLOAT: 4;
					}
			
			var vertexData: DataView = {
				type: accessor.type,
				count: accessor.count,
				glComponentType: accessor.componentType,
				// start: Std.int(accessor.byteOffset / byteCount),
				start: byteBuffer.length,
				// length: bufferView.byteLength
			};
			
			switch (attrib.name) {
				case "POSITION": posView = vertexData;
				case "NORMAL": normalView = vertexData;
				case "TEXCOORD_0": texCoords = vertexData;
				case "TANGENT": tangent = vertexData;
			}
			
			if (bufferView.byteStride != 0) {
				
				var byteOffset: Int = accessor.byteOffset;
				var byteStride: Int = bufferView.byteStride;
				var count: Int = accessor.count;
				
				var dataSize: Int = 
					switch (accessor.type) {
						case SCALAR: 1 * byteCount;
						case VEC2: 2 * byteCount;
						case VEC3: 3 * byteCount;
						case VEC4: 4 * byteCount;
						case MAT2: 2 * 2 * byteCount;
						case MAT3: 3 * 3 * byteCount;
						case MAT4: 4 * 4 * byteCount;
					}
				
				for (i in 0 ... count) {
					byteBuffer.add(rawData.sub(byteOffset + i * byteStride, dataSize));
				}
			}
			else {
				byteBuffer.add(rawData.sub(bufferView.byteOffset, bufferView.byteLength));
			}
		}
		
		var bytes: Bytes = Bytes.alloc(byteBuffer.length);
		bytes.blit(0, byteBuffer.getBytes(), 0, byteBuffer.length);
		result = {
			data: bytes,
			position: posView,
			normal: normalView,
			textCoord: texCoords,
			tangent: tangent
		}
		
		return result;
	}
	
	public var name: Null<String>;
	
	private var meshVAO: GLVertexArrayObject;
	private var vertexBuffer: GLBuffer;
	private var indexBuffer: GLBuffer;
	private var indexBufferType: Int;
	private var indexCount: Int;
	private var attributesIndices: Array<Int>;
	private var shader: Shader;
	
	private var gl(get, never): WebGL2RenderContext;
	
	private function new() {
		
		meshVAO = null;
		vertexBuffer = null;
		indexBuffer = null;
		name = null;
		indexCount = -1;
	}
	
	public function dispose(): Void {
		
		if (indexBuffer != null) {
			
			gl.deleteBuffer(indexBuffer);
			indexBuffer = null;
		}
		
		if (vertexBuffer != null) {
			
			gl.deleteBuffer(vertexBuffer);
			vertexBuffer = null;
		}
		
		if (meshVAO != null) {
			
			gl.deleteVertexArray(meshVAO);
			meshVAO = null;
		}
		
		indexCount = -1;
	}
	
	public function setShader(shader: Shader): Void {
		this.shader = shader;
	}
	
	public function renderMesh(transform: Mat4): Void {
		
		gl.uniformMatrix4fv(shader.uniformModel, false, transform);
		
		gl.bindVertexArray(meshVAO);
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		
		for (idx in attributesIndices) gl.enableVertexAttribArray(idx);
		
		gl.drawElements(gl.TRIANGLES, indexCount, indexBufferType, 0);
		
		for (idx in attributesIndices) gl.disableVertexAttribArray(idx);
		
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
		gl.bindVertexArray(null);
	}
	
	private function createFromVertexData(vertices: VertexData, indices: ArrayBufferView): Void {
		
		#if js
		indexCount = untyped indices.length;
		#else
		indexCount = indices.length;
		#end
		
		meshVAO = gl.createVertexArray();
		gl.bindVertexArray(meshVAO);
		
		indexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
		
		#if js
		var data = vertices.data.getData();
		var vertexData: Float32Array = new js.lib.Float32Array(data);
		#else
		var vertexData: Float32Array = new Float32Array(vertices.data);
		#end
		
		vertexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, vertexData, gl.STATIC_DRAW);
		
		attributesIndices = [];
		if (vertices.position != null) {
			attributesIndices.push(0);
			gl.vertexAttribPointer(0, 3, vertices.position.glComponentType, false, Float32Array.BYTES_PER_ELEMENT * 3, vertices.position.start);
		}
		if (vertices.textCoord != null) {
			attributesIndices.push(1);
			gl.vertexAttribPointer(1, 2, vertices.textCoord.glComponentType, true, Float32Array.BYTES_PER_ELEMENT * 2, vertices.textCoord.start);
		}
		if (vertices.normal != null) {
			attributesIndices.push(2);
			gl.vertexAttribPointer(2, 3, vertices.normal.glComponentType, true, Float32Array.BYTES_PER_ELEMENT * 3, vertices.normal.start);
		}
		if (vertices.tangent != null) {
			attributesIndices.push(3);
			gl.vertexAttribPointer(3, 4, vertices.tangent.glComponentType, true, Float32Array.BYTES_PER_ELEMENT * 3, vertices.tangent.start);
		}
		
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
		gl.bindVertexArray(null);
	}
	
	private function createMesh(vertices: Float32Array, indices: UInt16Array): Void {
		
		indexCount = indices.length;
		indexBufferType = gl.UNSIGNED_SHORT; // cause indices UInt32Array
		
		meshVAO = gl.createVertexArray();
		gl.bindVertexArray(meshVAO);
		
		// Создание идекс буфера
		indexBuffer = gl.createBuffer();
		// Активация индекс буфера
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		// Копирование статичных индексов
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
		
		// Создание вертекс буфера
		vertexBuffer = gl.createBuffer();
		// Активация вертекс буфера
		gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
		// Копировение статичных (не изменяемых) точек в буфер
		gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
		
		// Определяем 3 точки на координату, без оффсетов и прочих смещений
		attributesIndices = [0, 1, 2];
		gl.vertexAttribPointer(0, 3, gl.FLOAT, false, Float32Array.BYTES_PER_ELEMENT * 8, 0);
		gl.vertexAttribPointer(1, 2, gl.FLOAT, true, Float32Array.BYTES_PER_ELEMENT * 8, Float32Array.BYTES_PER_ELEMENT * 3);
		gl.vertexAttribPointer(2, 3, gl.FLOAT, true, Float32Array.BYTES_PER_ELEMENT * 8, Float32Array.BYTES_PER_ELEMENT * 5);
		
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
		gl.bindVertexArray(null);
	}
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}
