package;

import Shader.DirectionalLightUniforms;
import lime.graphics.opengl.GLUniformLocation;
import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Mat4Tools;
import mme.math.glmatrix.Vec3;
import mme.math.glmatrix.Vec3Tools;

class DirectinalLight extends Light {
	
	public var direction: Vec3;
	public var shadowMap(default, null): ShadowMap;
	
	private var lightProj: Mat4;
	
	public function new(r: Float, g: Float, b: Float, ambientIntensity: Float) {
		
		super(r, g, b, ambientIntensity);
		direction = Vec3.fromValues(0.0, -1.0, -1.0);
		shadowMap = new ShadowMap();
		shadowMap.init(2048, 2048);
		lightProj = Mat4Tools.ortho(-20.0, 20.0, -20.0, 20.0, 0.1, 80.0);
	}
	
	public function calcLightTransform(): Mat4 {
		return Mat4Tools.multiply(lightProj, Mat4Tools.lookAt(Vec3Tools.negate(direction), Vec3.fromValues(0.0, 0.0, 0.0), Vec3.fromValues(0.0, 1.0, 0.0)));
	}
	
	public function use(light: DirectionalLightUniforms, vLightDir: GLUniformLocation): Void {
		
		gl.uniform3fv(light.color, color);
		gl.uniform1f(light.ambientIntensity, ambientIntensity);
		gl.uniform1f(light.diffuseIntensity, diffuseIntensity);
		
		gl.uniform3fv(light.direction, direction);
		
		gl.uniform3fv(vLightDir, direction);
	}
}
