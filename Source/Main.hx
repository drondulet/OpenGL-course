package;

import haxe.Timer;
import lime.app.Application;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.RenderContext;
import lime.ui.Window;
import lime.utils.Assets;
import lime.utils.Float32Array;
import lime.utils.Log;

class Main extends Application {
	
	private var gl: WebGL2RenderContext;
	private var triangleBuffer: GLBuffer;
	private var currentProgram: GLProgram;
	
	private var triMoveIncrement: Float = 0.01;
	private var triMaxOffset: Float = 0.5;
	private var triOffset: Float = 0.0;
	private var moveDirection: Int = 1;
	
	private var uniformMoveX: GLUniformLocation;
	
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
		
		triangleBuffer = createTriangleBuffer();
		currentProgram = createProgram();
	}
	
	private function createTriangleBuffer(): GLBuffer {
		
		var vertecies: Float32Array = new Float32Array([
			-1.0, -1.0, 0.0,
			 1.0, -1.0, 0.0,
			 0.0,  1.0, 0.0
		]);
		
		// Создание буфера
		var vertexBuffer: GLBuffer = gl.createBuffer();
		// Активация буфера
		gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
		// Копировение статичных (не изменяемых) точек в буфер 
		gl.bufferData(gl.ARRAY_BUFFER, vertecies, gl.STATIC_DRAW);
		// Определяем 3 точки на координату, без оффсетов и прочих смещений
		gl.vertexAttribPointer(0, 3, gl.FLOAT, false, 0, 0);
		// Вкл индекса атрибута
		gl.enableVertexAttribArray(0);
		
		return vertexBuffer;
	}
	
	private function getVertexShader(): String {
		return
			"#version 300 es
			precision mediump float;
			
			layout (location = 0) in vec3 pos;
			
			uniform float moveX;
			
			void main()
			{
				gl_Position = vec4(0.5 * pos.x + moveX, 0.5 * pos.y, pos.z, 1.0);
			}";
	}
	
	private function getFragmentShader(): String {
		return
			"#version 300 es
			precision mediump float;
			
			out vec4 color;
			
			void main()
			{
				color = vec4(1.0, 0.0, 0.0, 1.0);
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
		
		uniformMoveX = gl.getUniformLocation(shaderProgram, "moveX");
		
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
				
				gl.viewport(0, 0, window.width, window.height);
				
				gl.clearColor(0.0, 0.0, 0.0, 1.0);
				gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT );
				
				gl.useProgram(currentProgram);
				gl.uniform1f(uniformMoveX, triOffset);
				gl.bindBuffer(gl.ARRAY_BUFFER, triangleBuffer);
				
				gl.drawArrays(gl.TRIANGLES, 0, 3);
				
				gl.bindBuffer(gl.ARRAY_BUFFER, null);
				gl.useProgram(null);
				
			default:
				Log.warn("Current render context not supported by this sample");
		}
	}
	
	/**
	
	 ****************************************************************
	
	**/
	
	// private function compile():Void {
		
	// 	var program = gl.createProgram();
	// 	var vertex = Assets.getText("assets/heroku.vert");
		
	// 	#if desktop
	// 	var fragment = "";
	// 	#else
	// 	var fragment = "precision mediump float;";
	// 	#end
		
	// 	fragment += Assets.getText("assets/" + fragmentShaders[currentIndex] + ".frag");
		
	// 	var vs = createShader(vertex, gl.VERTEX_SHADER);
	// 	var fs = createShader(fragment, gl.FRAGMENT_SHADER);
		
	// 	if(vs == null || fs == null) return;
		
	// 	gl.attachShader(program, vs);
	// 	gl.attachShader(program, fs);
		
	// 	gl.deleteShader(vs);
	// 	gl.deleteShader(fs);
		
	// 	gl.linkProgram(program);
		
	// 	if(gl.getProgramParameter(program, gl.LINK_STATUS) == 0) {
			
	// 		trace(gl.getProgramInfoLog(program));
	// 		trace("VALIDATE_STATUS: " + gl.getProgramParameter(program, gl.VALIDATE_STATUS));
	// 		trace("ERROR: " + gl.getError());
	// 		return;
			
	// 	}
		
	// 	if(currentProgram != null) {
			
	// 		gl.deleteProgram(currentProgram);
			
	// 	}
		
	// 	currentProgram = program;
		
	// 	positionAttribute = gl.getAttribLocation(currentProgram, "surfacePosAttrib");
	// 	gl.enableVertexAttribArray(positionAttribute);
		
	// 	vertexPosition = gl.getAttribLocation(currentProgram, "position");
	// 	gl.enableVertexAttribArray(vertexPosition);
		
	// 	timeUniform = gl.getUniformLocation(program, "time");
	// 	mouseUniform = gl.getUniformLocation(program, "mouse");
	// 	resolutionUniform = gl.getUniformLocation(program, "resolution");
	// 	backbufferUniform = gl.getUniformLocation(program, "backbuffer");
	// 	surfaceSizeUniform = gl.getUniformLocation(program, "surfaceSize");
		
	// 	startTime = Timer.stamp();
	// 	currentTime = startTime;
	// }
	
	// private function createShader(source:String, type:Int):GLShader {
		
	// 	var gl = window.context.webgl;
		
	// 	var shader = gl.createShader(type);
	// 	gl.shaderSource(shader, source);
	// 	gl.compileShader(shader);
		
	// 	if(gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0) {
			
	// 		trace(gl.getShaderInfoLog(shader));
	// 		trace(source);
	// 		return null;
			
	// 	}
	// 	return shader;
	// }
	
	// private function randomizeArray<T>(array:Array<T>):Array<T> {
		
	// 	var arrayCopy = array.copy();
	// 	var randomArray = new Array<T>();
		
	// 	while(arrayCopy.length > 0) {
			
	// 		var randomIndex = Math.round(Math.random() *(arrayCopy.length - 1));
	// 		randomArray.push(arrayCopy.splice(randomIndex, 1)[0]);
			
	// 	}
	// 	return randomArray;
	// }
	
	
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
