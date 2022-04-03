package;

import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;


class Mesh {
	
	private var meshVAO: GLVertexArrayObject;
	private var vertexBuffer: GLBuffer;
	private var indexBuffer: GLBuffer;
	private var indexCount: Int;
	
	private var gl(get, never): WebGL2RenderContext;
	
	public function new() {
		
		meshVAO = null;
		vertexBuffer = null;
		indexBuffer = null;
		indexCount = -1;
	}
	
	public function createMesh(vertices: Float32Array, indices: UInt32Array): Void {
		
		indexCount = indices.length;
		
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
		gl.vertexAttribPointer(0, 3, gl.FLOAT, false, Float32Array.BYTES_PER_ELEMENT * 8, 0);
		gl.enableVertexAttribArray(0);// Вкл индекса атрибута
		gl.vertexAttribPointer(1, 2, gl.FLOAT, true, Float32Array.BYTES_PER_ELEMENT * 8, Float32Array.BYTES_PER_ELEMENT * 3);
		gl.enableVertexAttribArray(1);
		gl.vertexAttribPointer(2, 3, gl.FLOAT, true, Float32Array.BYTES_PER_ELEMENT * 8, Float32Array.BYTES_PER_ELEMENT * 5);
		gl.enableVertexAttribArray(2);
		
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
		gl.bindVertexArray(null);
		// After VAO
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
	}
	
	public function renderMesh(): Void {
		
		gl.bindVertexArray(meshVAO);
		
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		gl.drawElements(gl.TRIANGLES, indexCount, gl.UNSIGNED_INT, 0);
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
		
		gl.bindVertexArray(null);
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
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}
