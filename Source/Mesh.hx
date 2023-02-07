package;

import gltf.types.MeshPrimitive;
import haxe.io.Bytes;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.utils.ArrayBufferView;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import mme.math.glmatrix.Mat4;

using gltfTools.GLTFBuilder;


typedef GlBufferView = {
	var componentSize: Int;
	var componentType: Int;
	var normalized: Bool;
	var stride: Int;
	var count: Int;
	var start: Int;
}

typedef GlIndexBufferData = {
	var indices: ArrayBufferView;
	var componentType: Int;
}

typedef GlVertexBufferData = {
	var data: Bytes;
	var position: GlBufferView;
	var normal: GlBufferView;
	var textCoord: GlBufferView;
	var tangent: GlBufferView;
}

typedef GlMeshData = {
	var indices: GlIndexBufferData;
	var vertices: GlVertexBufferData;
}

class Mesh {
	
	static public function createFromGLTFBuilder(mesh: gltf.types.Mesh, builder: GLTFBuilder, primitive: Int = 0): Mesh {
		
		var inst: Mesh = new Mesh();
		inst.name = mesh.name;
		
		var primitive: MeshPrimitive = mesh.primitives[primitive];
		var data: GlMeshData = primitive.extracPrimitiveData();
		
		inst.createFromVertexBufferData(data.vertices, data.indices);
		
		inst.material = Material.createFromGLTFBuilder(builder.gltf.material.get(primitive.material), builder);
		
		return inst;
	}
	
	static public function createFromRawData(vertices: Float32Array, indices: UInt16Array, material: Material): Mesh {
		
		var inst: Mesh = new Mesh();
		inst.createMesh(vertices, indices);
		inst.material = material;
		
		return inst;
	}
	
	public var name: Null<String>;
	public var material(default, null): Material;
	
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
		material = null;
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
		
		if (material != null) {
			
			material.dispose();
			material = null;
		}
		
		indexCount = -1;
	}
	
	public function setShader(shader: Shader): Void {
		this.shader = shader;
	}
	
	public function renderMesh(transform: Mat4): Void {
		
		material.use(shader.uniformSpecularIntensity, shader.uniformSpecularShininess);
		
		gl.uniformMatrix4fv(shader.uniformModel, false, transform);
		
		gl.bindVertexArray(meshVAO);
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		
		for (idx in attributesIndices) gl.enableVertexAttribArray(idx);
		
		gl.drawElements(gl.TRIANGLES, indexCount, indexBufferType, 0);
		
		for (idx in attributesIndices) gl.disableVertexAttribArray(idx);
		
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
		gl.bindVertexArray(null);
		
		material.unUse();
	}
	
	private function createFromVertexBufferData(vertices: GlVertexBufferData, indices: GlIndexBufferData): Void {
		
		indexBufferType = indices.componentType;
		var indexBufferData: ArrayBufferView = indices.indices;
		#if js
		indexCount = untyped indexBufferData.length;
		var vertexBufferData: Float32Array = new js.lib.Float32Array(vertices.data.getData());
		#else
		indexCount = indexBufferData.length;
		var vertexBufferData: Float32Array = new Float32Array(vertices.data);
		#end
		
		meshVAO = gl.createVertexArray();
		gl.bindVertexArray(meshVAO);
		
		indexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indexBufferData, gl.STATIC_DRAW);
		
		vertexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, vertexBufferData, gl.STATIC_DRAW);
		
		function applyAttributeData(idx: Int, data: GlBufferView): Void {
			gl.vertexAttribPointer(idx, data.componentSize, data.componentType, data.normalized, data.stride, data.start);
		}
		
		attributesIndices = []; //TODO: get attribute pos from shader
		if (vertices.position != null) {
			
			attributesIndices.push(0);
			applyAttributeData(0, vertices.position);
		}
		if (vertices.textCoord != null) {
			
			attributesIndices.push(1);
			applyAttributeData(1, vertices.textCoord);
		}
		if (vertices.normal != null) {
			
			attributesIndices.push(2);
			applyAttributeData(2, vertices.normal);
		}
		if (vertices.tangent != null) {
			
			attributesIndices.push(3);
			applyAttributeData(3, vertices.tangent);
		}
		
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
		gl.bindVertexArray(null);
	}
	
	private function createMesh(vertices: Float32Array, indices: UInt16Array): Void {
		
		indexCount = indices.length;
		indexBufferType = gl.UNSIGNED_SHORT; // cause indices UInt16Array
		
		meshVAO = gl.createVertexArray();
		gl.bindVertexArray(meshVAO);
		
		indexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
		
		vertexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);
		
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
