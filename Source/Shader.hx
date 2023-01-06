package;

import lime.graphics.RenderContext;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Log;


class Shader {
	
	public var uniformModel(default, null): Null<GLUniformLocation>;
	public var uniformView(default, null): Null<GLUniformLocation>;
	public var uniformProjection(default, null): Null<GLUniformLocation>;
	public var uniformAmbientColor(default, null): Null<GLUniformLocation>;
	public var uniformAmbientIntensity(default, null): Null<GLUniformLocation>;
	public var uniformDirection(default, null): Null<GLUniformLocation>;
	public var uniformDiffuseIntensity(default, null): Null<GLUniformLocation>;
	public var uniformSpecularIntensity(default, null): Null<GLUniformLocation>;
	public var uniformSpecularShininess(default, null): Null<GLUniformLocation>;
	public var uniformCameraPosition(default, null): Null<GLUniformLocation>;
	
	private var program(default, null): GLProgram;
	private var gl(get, never): WebGL2RenderContext;
	
	public function new() {
		
		program = null;
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
		uniformAmbientColor = gl.getUniformLocation(program, "directionalLight.color");
		uniformAmbientIntensity = gl.getUniformLocation(program, "directionalLight.ambientIntensity");
		
		uniformDirection = gl.getUniformLocation(program, "directionalLight.direction");
		uniformDiffuseIntensity = gl.getUniformLocation(program, "directionalLight.diffIntensity");
		
		uniformSpecularIntensity = gl.getUniformLocation(program, "material.specularIntensity");
		uniformSpecularShininess = gl.getUniformLocation(program, "material.shininess");
		
		uniformCameraPosition = gl.getUniformLocation(program, "camPosition");
	}
	
	public function use(): Void {
		
		if (program == null) {
			Log.error('Error using shader program');
		}
		
		gl.useProgram(program);
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
	
	inline private function get_gl(): WebGL2RenderContext {
		return GraphicsContext.gl;
	}
}