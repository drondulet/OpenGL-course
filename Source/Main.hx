package;

import lime.app.Application;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLVertexArrayObject;
import lime.graphics.RenderContext;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import lime.utils.Log;

class Main extends Application {
	
	private var gl: WebGL2RenderContext;
	private var triangleVAO: GLVertexArrayObject;
	private var triangleBuffer: GLBuffer;
	private var triangleIndexBuffer: GLBuffer;
	private var currentProgram: GLProgram;
	
	private var triMoveIncrement: Float = 0.01;
	private var triMaxOffset: Float = 0.5;
	private var triOffset: Float = 0.0;
	private var moveDirection: Int = 1;
	private var curRotation: Float = 0.0;
	private var curScale: Float = 0.4;
	
	private var uniformModel: GLUniformLocation;
	
	private var model: Matrix4;
	
	public function new() {
		super();
	}
	
	public override function onWindowCreate(): Void {
		
		switch(window.context.type) {
			
			case OPENGL, OPENGLES, WEBGL:
				Log.info('Render type: ${window.context.type} version: ${window.context.version}');
				
			default:
				Log.warn("Current render context not supported by this sample");
		}
	}
	
	public override function onPreloadComplete(): Void {
		init();
	}
	
	private function init(): Void {
		
		gl =
			switch (window.context.type) {
				
				case WEBGL: window.context.webgl2;
				case OPENGL: window.context.gl;
				case OPENGLES: window.context.gles3;
				
				default: null;
			};
		
		if (gl == null) {
			
			Log.error('Can not get render context');
			return;
		}
		
		model = new Matrix4();
		// model.appendRotation(90, new Vector4(0.0, 0.0, 1.0));
		
		
		createTriangleBuffers();
		currentProgram = createProgram();
		
	}
	
	private function createTriangleBuffers(): Void {
		
		var indicies: UInt16Array = new UInt16Array([
			0, 3, 1,
			1, 3, 2,
			2, 3, 0,
			0, 1, 2
		]);
		
		var vertecies: Float32Array = new Float32Array([
			-1.0, -1.0,  0.0,
			 0.0, -0.5,  1.0,
			 1.0, -1.0,  0.0,
			 0.0,  1.0,  0.0
		]);
		
		triangleVAO = gl.createVertexArray();
		gl.bindVertexArray(triangleVAO);
		
		// Создание идекс буфера
		triangleIndexBuffer = gl.createBuffer();
		// Активация индекс буфера
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleIndexBuffer);
		// Копирование статичных индексов
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indicies, gl.STATIC_DRAW);
		
		// Создание вертекс буфера
		var triangleBuffer: GLBuffer = gl.createBuffer();
		// Активация вертекс буфера
		gl.bindBuffer(gl.ARRAY_BUFFER, triangleBuffer);
		// Копировение статичных (не изменяемых) точек в буфер 
		gl.bufferData(gl.ARRAY_BUFFER, vertecies, gl.STATIC_DRAW);
		
		// Определяем 3 точки на координату, без оффсетов и прочих смещений
		gl.vertexAttribPointer(0, 3, gl.FLOAT, false, 0, 0);
		// Вкл индекса атрибута
		gl.enableVertexAttribArray(0);
		
		gl.bindBuffer(gl.ARRAY_BUFFER, null);
		gl.bindVertexArray(null);
		// After VAO
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
	}
	
	private function getVertexShader(): String {
		return
			"#version 300 es
			precision mediump float;
			
			layout (location = 0) in vec3 pos;
			
			out vec4 vertColor;
			
			uniform mat4 model;
			
			void main()
			{
				gl_Position = model * vec4(pos, 1.0f);
				vertColor = vec4(clamp(pos, 0.0f, 1.0f), 1.0f);
			}";
	}
	
	private function getFragmentShader(): String {
		return
			"#version 300 es
			precision mediump float;
			
			in vec4 vertColor;
			
			out vec4 color;
			
			void main()
			{
				color = vertColor;
			}";
	}
	
	private function createProgram(): GLProgram {
		
		var shaderProgram: GLProgram = GLProgram.fromSources(gl, getVertexShader(), getFragmentShader());
		
		if (shaderProgram == null) {
			Log.error('Error creating shader program');
		}
		
		var status: Dynamic = gl.getProgramParameter(shaderProgram, gl.VALIDATE_STATUS);
		var intStatus: Null<Int> = Std.parseInt(Std.string(status));
		var boolStatus: Bool = status;
		
		var hasError: Bool = window.context.type == WEBGL ? boolStatus : intStatus != null && intStatus == 0;
		
		if (status == null || hasError) {
			
			var message = "Unable to validate the shader program";
			message += "\n" + gl.getProgramInfoLog(shaderProgram);
			message += "\nerror code: " + gl.getError();
			Log.error(message);
		}
		
		uniformModel = gl.getUniformLocation(shaderProgram, "model");
		
		return shaderProgram;
	}
	
	public override function render(context: RenderContext): Void {
		
		switch(context.type) {
			
			case OPENGL, OPENGLES, WEBGL:
				
				if (currentProgram == null) {
					
					Log.warn("No shader program");
					return;
				}
				
				triOffset += moveDirection > 0 ? triMoveIncrement : triMoveIncrement * -1;
				
				if (Math.abs(triOffset) > triMaxOffset) {
					moveDirection *= -1;
				}
				
				curScale += 0.005 * moveDirection;
				
				curRotation += 1;
				if (curRotation > 360.0) {
					curRotation -= 360.0;
				}
				
				model = new Matrix4();
				
				// model.appendTranslation(triOffset - model.position.x, 0.0, 0.0);
				model.prependRotation(curRotation, new Vector4(0.0, 1.0, 0.0));
				// model.prependScale(curScale, curScale, 0.0);
				model.prependScale(0.5, 0.5, 0.5);
				
				gl.viewport(0, 0, window.width, window.height);
				gl.enable(gl.DEPTH_TEST);
				
				gl.clearColor(0.05, 0.05, 0.05, 1.0);
				gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
				
				gl.useProgram(currentProgram);
				gl.uniformMatrix4fv(uniformModel, false, model);
				
				gl.bindVertexArray(triangleVAO);
				
				gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, triangleIndexBuffer);
				gl.drawElements(gl.TRIANGLES, 12, gl.UNSIGNED_SHORT, 0);
				gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
				
				gl.bindVertexArray(null);
				
				gl.useProgram(null);
				
				gl.disable(gl.DEPTH_TEST);
				
			default:
				Log.warn("Current render context not supported by this sample");
		}
	}
	
	/**
	
	 ****************************************************************
	
	**/
	
	// public override function update(deltaTime:Int):Void {
		
	// 	if(currentTime > maxTime && fragmentShaders.length > 1) {
			
	// 		currentIndex++;
			
	// 		if(currentIndex > fragmentShaders.length - 1) {
				
	// 			currentIndex = 0;
				
	// 		}
			
	// 		compile();
	// 	}
	// }
}
