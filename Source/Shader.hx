package;

import lime.graphics.RenderContext;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Log;
import mme.math.glmatrix.Mat4;

typedef DirectionalLightUniforms = {
	var color: Null<GLUniformLocation>;
	var ambientIntensity: Null<GLUniformLocation>;
	var diffuseIntensity: Null<GLUniformLocation>;
	var direction: Null<GLUniformLocation>;
}

typedef PointLightUniforms = {
	var color: Null<GLUniformLocation>;
	var ambientIntensity: Null<GLUniformLocation>;
	var diffuseIntensity: Null<GLUniformLocation>;
	var position: Null<GLUniformLocation>;
	var exponent: Null<GLUniformLocation>;
	var linear: Null<GLUniformLocation>;
	var constant: Null<GLUniformLocation>;
}

typedef SpotLightUniforms = {
	var color: Null<GLUniformLocation>;
	var ambientIntensity: Null<GLUniformLocation>;
	var diffuseIntensity: Null<GLUniformLocation>;
	var position: Null<GLUniformLocation>;
	var exponent: Null<GLUniformLocation>;
	var linear: Null<GLUniformLocation>;
	var constant: Null<GLUniformLocation>;
	var direction: Null<GLUniformLocation>;
	var edge: Null<GLUniformLocation>;
}

typedef TextureUniforms = {
	var diffuse: Null<GLUniformLocation>;
	var normal: Null<GLUniformLocation>;
}

class Shader {
	
	static final MAX_POINT_LIGHTS: Int = 3;
	static final MAX_SPOT_LIGHTS: Int = 3;
	
	public var uniformModel(default, null): Null<GLUniformLocation>;
	public var uniformView(default, null): Null<GLUniformLocation>;
	public var uniformProjection(default, null): Null<GLUniformLocation>;
	public var dirLightTransformUniformLoc(default, null): Null<GLUniformLocation>;
	
	public var uniformSpecularIntensity(default, null): Null<GLUniformLocation>;
	public var uniformSpecularShininess(default, null): Null<GLUniformLocation>;
	public var uniformCameraPosition(default, null): Null<GLUniformLocation>;
	
	public var vertexLightDir(default, null): Null<GLUniformLocation>;
	public var vertexViewPos(default, null): Null<GLUniformLocation>;
	
	public var textureUniformLoc(default, null): TextureUniforms;
	public var dirShadowMapUniformLoc(default, null): Null<GLUniformLocation>;
	
	private var directLightUniformLoc: DirectionalLightUniforms;
	private var pointLightsUniformLoc: Array<PointLightUniforms>;
	private var pointLightCountUniform: Null<GLUniformLocation>;
	private var spotLightsUniformLoc: Array<SpotLightUniforms>;
	private var spotLightCountUniform: Null<GLUniformLocation>;
	private var program: GLProgram;
	private var gl(get, never): WebGL2RenderContext;
	
	public function new() {
		
		program = null;
		uniformModel = null;
		uniformProjection = null;
	}
	
	public function dispose(): Void {
		
		if (program != null) {
			
			// gl.detachShader(program, vertex);
			// gl.detachShader(program, fragment);
			// gl.deleteShader(vertex);
			// gl.deleteShader(fragment);
			
			gl.deleteProgram(program);
			program = null;
		}
		
		uniformModel = null;
		uniformProjection = null;
	}
	
	public function createFromString(vertexCode: String, fragmentCode: String, context: RenderContext): Void {
		
		program = GLProgram.fromSources(gl, vertexCode, fragmentCode);
		
		if (program == null) {
			Log.error('Error creating shader program');
		}
		
		// WebGL returns true/flase, OpenGL returns 1/0
		var status: Dynamic = gl.getProgramParameter(program, gl.VALIDATE_STATUS);
		var intStatus: Null<Int> = Std.parseInt(Std.string(status));
		var boolStatus: Bool = status;
		
		var hasError: Bool = context.type == WEBGL ? boolStatus : intStatus != null && intStatus == 0;
		
		if (status == null || hasError) {
			
			var message = "Unable to validate the shader program";
			message += "\n" + gl.getProgramInfoLog(program);
			message += "\nerror code: " + gl.getError();
			Log.error(message);
		}
		
		uniformModel = gl.getUniformLocation(program, "model");
		uniformView = gl.getUniformLocation(program, "view");
		uniformProjection = gl.getUniformLocation(program, "projection");
		
		vertexLightDir = gl.getUniformLocation(program, "lightDir");
		vertexViewPos = gl.getUniformLocation(program, "viewPos");
		
		directLightUniformLoc = {
			color: gl.getUniformLocation(program, "directionalLight.base.color"),
			ambientIntensity: gl.getUniformLocation(program, "directionalLight.base.ambientIntensity"),
			diffuseIntensity: gl.getUniformLocation(program, "directionalLight.base.diffIntensity"),
			direction: gl.getUniformLocation(program, "directionalLight.direction")
		};
		
		pointLightCountUniform = gl.getUniformLocation(program, "pointLightCount");
		
		pointLightsUniformLoc = [];
		for (i in 0 ... MAX_POINT_LIGHTS) {
			
			pointLightsUniformLoc.push({
				color: gl.getUniformLocation(program, 'pointLights[$i].base.color'),
				ambientIntensity: gl.getUniformLocation(program, 'pointLights[$i].base.ambientIntensity'),
				diffuseIntensity: gl.getUniformLocation(program, 'pointLights[$i].base.diffIntensity'),
				position: gl.getUniformLocation(program, 'pointLights[$i].position'),
				exponent: gl.getUniformLocation(program, 'pointLights[$i].exponent'),
				linear: gl.getUniformLocation(program, 'pointLights[$i].linear'),
				constant: gl.getUniformLocation(program, 'pointLights[$i].constant')
			});
		}
		
		spotLightCountUniform = gl.getUniformLocation(program, "spotLightCount");
		
		spotLightsUniformLoc = [];
		for (i in 0 ... MAX_SPOT_LIGHTS) {
			
			spotLightsUniformLoc.push({
				color: gl.getUniformLocation(program, 'spotLights[$i].base.base.color'),
				ambientIntensity: gl.getUniformLocation(program, 'spotLights[$i].base.base.ambientIntensity'),
				diffuseIntensity: gl.getUniformLocation(program, 'spotLights[$i].base.base.diffIntensity'),
				position: gl.getUniformLocation(program, 'spotLights[$i].base.position'),
				exponent: gl.getUniformLocation(program, 'spotLights[$i].base.exponent'),
				linear: gl.getUniformLocation(program, 'spotLights[$i].base.linear'),
				constant: gl.getUniformLocation(program, 'spotLights[$i].base.constant'),
				direction: gl.getUniformLocation(program, 'spotLights[$i].direction'),
				edge: gl.getUniformLocation(program, 'spotLights[$i].edge'),
			});
		}
		
		uniformSpecularIntensity = gl.getUniformLocation(program, "material.specularIntensity");
		uniformSpecularShininess = gl.getUniformLocation(program, "material.shininess");
		
		textureUniformLoc = {
			diffuse: gl.getUniformLocation(program, "diffuseTexture"),
			normal: gl.getUniformLocation(program, "normalTexture"),
		}
		
		dirShadowMapUniformLoc = gl.getUniformLocation(program, "dirShadowMapTexture");
		dirLightTransformUniformLoc = gl.getUniformLocation(program, "dirLightSpaceTransform");
		
		uniformCameraPosition = gl.getUniformLocation(program, "camPosition");
	}
	
	public function use(): Void {
		
		if (program == null) {
			Log.error('Error using shader program');
		}
		
		gl.useProgram(program);
	}
	
	public function unUse(): Void {
		gl.useProgram(null);
	}
	
	public function setDiffuseTextureUnit(textureUnit: Int): Void {
		gl.uniform1i(textureUniformLoc.diffuse, textureUnit);
	}
	
	public function setNormalTextureUnit(textureUnit: Int): Void {
		gl.uniform1i(textureUniformLoc.normal, textureUnit);
	}
	
	public function setDirShadowMapTextureUnit(textureUnit: Int): Void {
		gl.uniform1i(dirShadowMapUniformLoc, textureUnit);
	}
	
	public function setDirLightTransform(transform: Mat4): Void {
		gl.uniformMatrix4fv(dirLightTransformUniformLoc, false, transform);
	}
	
	public function useDirectionalLight(light: DirectinalLight): Void {
		light.use(directLightUniformLoc, vertexLightDir);
	}
	
	public function usePointLights(lights: Array<PointLight>): Void {
		
		var ligthCount: Int = lights.length > MAX_POINT_LIGHTS ? MAX_POINT_LIGHTS : lights.length;
		
		gl.uniform1i(pointLightCountUniform, ligthCount);
		
		for (i in 0 ... ligthCount) {
			
			lights[i].usePoint(pointLightsUniformLoc[i].ambientIntensity,
					pointLightsUniformLoc[i].color,
					pointLightsUniformLoc[i].diffuseIntensity,
					pointLightsUniformLoc[i].position,
					pointLightsUniformLoc[i].exponent,
					pointLightsUniformLoc[i].linear,
					pointLightsUniformLoc[i].constant);
		}
	}
	
	public function useSpotLights(lights: Array<SpotLight>): Void {
		
		var ligthCount: Int = lights.length > MAX_SPOT_LIGHTS ? MAX_SPOT_LIGHTS : lights.length;
		
		gl.uniform1i(spotLightCountUniform, ligthCount);
		
		for (i in 0 ... ligthCount) {
			
			lights[i].useSpot(spotLightsUniformLoc[i].ambientIntensity,
					spotLightsUniformLoc[i].color,
					spotLightsUniformLoc[i].diffuseIntensity,
					spotLightsUniformLoc[i].position,
					spotLightsUniformLoc[i].direction,
					spotLightsUniformLoc[i].exponent,
					spotLightsUniformLoc[i].linear,
					spotLightsUniformLoc[i].constant,
					spotLightsUniformLoc[i].edge);
		}
	}
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}
