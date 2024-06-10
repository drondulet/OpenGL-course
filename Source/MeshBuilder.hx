package;

import Mesh.GlBufferView;
import Mesh.GlIndexBufferData;
import Mesh.GlMeshData;
import Mesh.GlVertexBufferData;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import mme.math.glmatrix.Vec2;
import mme.math.glmatrix.Vec3;
import mme.math.glmatrix.Vec4;


private typedef PointData = {
	var coords: Vec3;
	var normal: Vec3;
	var texCoords: Vec2;
	var tangent: Vec4;
}

class MeshBuilder {
	
	private var points: Array<PointData>;
	private var indices: UInt16Array;
	private var data: Bytes;
	
	public function new() {
		points = [];
	}
	
	public function addPoint(coords: Vec3, normal: Vec3, texCoords: Vec2, tangent: Vec4): MeshBuilder {
		
		points.push({
			coords: coords,
			normal: normal,
			texCoords: texCoords,
			tangent: tangent
		});
		
		return this;
	}
	
	public function setupIndices(indices: UInt16Array): MeshBuilder {
		
		this.indices = indices;
		return this;
	}
	
	public function build(): GlMeshData {
		
		var result: GlMeshData = {
			indices: getIndexData(),
			vertices: getVertexData()
		}
		
		return result;
	}
	
	private function getVertexData(): GlVertexBufferData {
		
		data = toBytes();
		
		var result: GlVertexBufferData;
		
		var pointsCount: Int = points.length;
		var floatSize: Int = Float32Array.BYTES_PER_ELEMENT;
		var stride: Int = floatSize * 3 + floatSize * 2 + floatSize * 3 + floatSize * 4;
		
		var coordsBufferView: GlBufferView = {
			componentSize: 3,
			componentType: GraphicsContext.gl.FLOAT,
			start: 0,
			count: pointsCount,
			stride: stride,
			normalized: false,
		};
		
		var texCoordsBufferView: GlBufferView = {
			componentSize: 2,
			componentType: GraphicsContext.gl.FLOAT,
			start: floatSize * 3,
			count: pointsCount,
			stride: stride,
			normalized: false
		};
		
		var normalBufferView: GlBufferView = {
			componentSize: 3,
			componentType: GraphicsContext.gl.FLOAT,
			start: floatSize * 3 + floatSize * 2,
			count: pointsCount,
			stride: stride,
			normalized: true
		};
		
		var tangentBufferView: GlBufferView = {
			componentSize: 4,
			componentType: GraphicsContext.gl.FLOAT,
			start: floatSize * 3 + floatSize * 2 + floatSize * 3,
			count: pointsCount,
			stride: stride,
			normalized: true
		};
		
		result = {
			data: data,
			position: coordsBufferView,
			textCoord: texCoordsBufferView,
			normal: normalBufferView,
			tangent: tangentBufferView
		}
		
		return result;
	}
	
	private function getIndexData(): GlIndexBufferData {
		
		var result: GlIndexBufferData;
		
		result = {
			indices: indices,
			componentType: GraphicsContext.gl.UNSIGNED_SHORT
		};
		
		return result;
	}
	
	private function toBytes(): Bytes {
		
		var byteBuffer = new BytesBuffer();
		
		for (point in points) {
			byteBuffer.add(cast(point.coords, Float32Array).toBytes());
			byteBuffer.add(cast(point.texCoords, Float32Array).toBytes());
			byteBuffer.add(cast(point.normal, Float32Array).toBytes());
			byteBuffer.add(cast(point.tangent, Float32Array).toBytes());
		}
		
		// TODO: make some ByteHelper for this
		var length: Int = byteBuffer.length; // after getBytes() buffer will die on static target
		var bytes: Bytes = Bytes.alloc(length);
		bytes.blit(0, byteBuffer.getBytes(), 0, length); // need to cut spare buffer bytes in js target
		
		return bytes;
	}
}
