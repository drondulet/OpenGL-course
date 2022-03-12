package;

import lime.math.Matrix4;
import lime.math.Vector4;
import lime.utils.Float32Array;


class MathHelper {
	
	inline static public function toRadians(value: Float): Float {
		return value * (Math.PI / 180);
	}
	
	// public static function getPerspective(fovY: Float, aspectRatio: Float, zNear: Float, zFar: Float): Matrix4 {
		
	// 	var rad: Float = toRadians(fovY);
	// 	var f: Float = 1.0 / Math.tan(rad / 2);
	// 	var t: Float = 1.0 / (zFar - zNear);
	// 	var mat: Matrix4 = new Matrix4(new Float32Array([
	// 		f / aspectRatio,
	// 		0.0,
	// 		0.0,
	// 		0.0,
			
	// 		0.0,
	// 		f,
	// 		0.0,
	// 		0.0,
			
	// 		0.0,
	// 		0.0,
	// 		(zFar + zNear) * t,
	// 		-1,
			
	// 		0.0,
	// 		0.0,
	// 		2 * zFar * zNear * t,
	// 		0.0]));
		
	// 	return mat;
	// }
	
	// public static function lookAt(eye: Vector4, center: Vector4, yAxis: Vector4, ?out: Matrix4 ): Matrix4 {
		
	// 	if( out == null ) out = new Matrix4();
	// 	var x0, x1, x2, y0, y1, y2, z0, z1, z2, len;
	// 	var eyex = eye.x;
	// 	var eyey = eye.y;
	// 	var eyez = eye.z;
	// 	var yAxisx = yAxis.x;
	// 	var yAxisy = yAxis.y;
	// 	var yAxisz = yAxis.z;
	// 	var centerx = center.x;
	// 	var centery = center.y;
	// 	var centerz = center.z;
	
	// 	if (Math.abs(eyex - centerx) < 0.000001 &&
	// 		Math.abs(eyey - centery) < 0.000001 &&
	// 		Math.abs(eyez - centerz) < 0.000001) {
	// 		out.identity();
	// 		return out;
	// 	}
	
	// 	z0 = eyex - centerx;
	// 	z1 = eyey - centery;
	// 	z2 = eyez - centerz;
	
	// 	len = 1 / Math.sqrt(z0 * z0 + z1 * z1 + z2 * z2);
	// 	z0 *= len;
	// 	z1 *= len;
	// 	z2 *= len;
	
	// 	x0 = yAxisy * z2 - yAxisz * z1;
	// 	x1 = yAxisz * z0 - yAxisx * z2;
	// 	x2 = yAxisx * z1 - yAxisy * z0;
	// 	len = Math.sqrt(x0 * x0 + x1 * x1 + x2 * x2);
	// 	if ( len == 0.0 ) {
	// 		x0 = 0;
	// 		x1 = 0;
	// 		x2 = 0;
	// 	} else {
	// 		len = 1 / len;
	// 		x0 *= len;
	// 		x1 *= len;
	// 		x2 *= len;
	// 	}
	
	// 	y0 = z1 * x2 - z2 * x1;
	// 	y1 = z2 * x0 - z0 * x2;
	// 	y2 = z0 * x1 - z1 * x0;
	
	// 	len = Math.sqrt(y0 * y0 + y1 * y1 + y2 * y2);
	// 	if ( len == 0.0 ) {
	// 		y0 = 0;
	// 		y1 = 0;
	// 		y2 = 0;
	// 	} else {
	// 		len = 1 / len;
	// 		y0 *= len;
	// 		y1 *= len;
	// 		y2 *= len;
	// 	}
	
	// 	out[0] = x0;
	// 	out[1] = y0;
	// 	out[2] = z0;
	// 	out[3] = 0;
	// 	out[4] = x1;
	// 	out[5] = y1;
	// 	out[6] = z1;
	// 	out[7] = 0;
	// 	out[8] = x2;
	// 	out[9] = y2;
	// 	out[10] = z2;
	// 	out[11] = 0;
	// 	out[12] = -(x0 * eyex + x1 * eyey + x2 * eyez);
	// 	out[13] = -(y0 * eyex + y1 * eyey + y2 * eyez);
	// 	out[14] = -(z0 * eyex + z1 * eyey + z2 * eyez);
	// 	out[15] = 1;
	
	// 	return out;
	// }
	
	// public static function lookAt(eye: Vector4, target: Vector4, up: Vector4): Matrix4 {
		
	// 	var zAxis: Vector4 = target.subtract(eye);
	// 	zAxis.normalize();
		
	// 	var xAxis: Vector4 = zAxis.crossProduct(up);
	// 	xAxis.normalize(); 
		
	// 	var yAxis: Vector4 = xAxis.crossProduct(zAxis);
		
	// 	var matrix = new Matrix4(); 
	// 	matrix.identity(); 
		
	// 	// matrix[0] = xAxis.x; 
	// 	// matrix[1] = xAxis.y; 
	// 	// matrix[2] = xAxis.z; 
	// 	// matrix[4] = yAxis.x; 
	// 	// matrix[5] = yAxis.y; 
	// 	// matrix[6] = yAxis.z; 
	// 	// matrix[8] = -zAxis.x; 
	// 	// matrix[9] = -zAxis.y; 
	// 	// matrix[10] = -zAxis.z; 
		
	// 	// matrix[3] = -xAxis.dotProduct(eye);
	// 	// matrix[7] = -yAxis.dotProduct(eye);
	// 	// matrix[11] = zAxis.dotProduct(eye);
		
	// 	matrix[0] = xAxis.x;
	// 	matrix[4] = xAxis.y;
	// 	matrix[8] = xAxis.z;
	// 	matrix[1] = yAxis.x;
	// 	matrix[5] = yAxis.y;
	// 	matrix[9] = yAxis.z;
	// 	matrix[2] = zAxis.x;
	// 	matrix[6] = zAxis.y;
	// 	matrix[10] = zAxis.z;
	// 	matrix[12] = -xAxis.dotProduct(eye);
	// 	matrix[13] = -yAxis.dotProduct(eye);
	// 	matrix[14] = -zAxis.dotProduct(eye);
		
	// 	return matrix;
	// }
}