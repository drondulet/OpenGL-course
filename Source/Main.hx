package;

import lime.utils.Assets;
import lime.app.Application;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.RenderContext;
import lime.math.Matrix4;
import lime.math.Vector4;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;
import lime.utils.Log;


class Main extends Application {
	
	private var gl: WebGL2RenderContext;
	private var currentProgram: Shader;
	
	private var triMoveIncrement: Float = 0.01;
	private var triMaxOffset: Float = 0.5;
	private var triOffset: Float = 0.0;
	private var moveDirection: Int = 1;
	private var curRotation: Float = 0.0;
	private var curScale: Float = 0.4;
	
	private var model: Matrix4;
	private var projection: Matrix4;
	
	private var meshes: Array<Mesh> = [];
	
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
		
		projection = getPerspective(45, window.width / window.height, 0.1, 100);
		
		createMeshes();
		
		currentProgram = new Shader(gl);
		currentProgram.createFromString(getVertexShader(), getFragmentShader(), window.context);
	}
	
	private function createMeshes(): Void {
		
		var indicies: UInt32Array = new UInt32Array([
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
		
		var mesh: Mesh = new Mesh(gl);
		mesh.createMesh(vertecies, indicies);
		
		meshes.push(mesh);
	}
	
	private function getVertexShader(): String {
		return Assets.getText("assets/vertex.glsl");
	}
	
	private function getFragmentShader(): String {
		return Assets.getText("assets/fragment.glsl");
	}
	
	override public function onWindowClose(): Void {
		
		for (mesh in meshes) {
			mesh.dispose();
		}
		
		currentProgram.dispose();
		
		super.onWindowClose();
	}
	
	public override function render(context: RenderContext): Void {
		
		switch(context.type) {
			
			case OPENGL, OPENGLES, WEBGL:
				drawGl();
			
			default:
				Log.warn("Current render context not supported by this sample");
		}
	}
	
	private function drawGl(): Void {
		
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
		
		model.prependTranslation(triOffset, 0.0, -2.0);
		model.prependRotation(curRotation, new Vector4(0.0, 1.0, 0.0));
		// model.prependScale(curScale, curScale, 0.0);
		model.prependScale(0.5, 0.5, 0.5);
		
		gl.viewport(0, 0, window.width, window.height);
		gl.enable(gl.DEPTH_TEST);
		
		gl.clearColor(0.05, 0.05, 0.05, 1.0);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		
		currentProgram.use();
		gl.uniformMatrix4fv(currentProgram.uniformModel, false, model);
		gl.uniformMatrix4fv(currentProgram.uniformProjection, false, projection);
		
		meshes[0].renderMesh();
		
		gl.useProgram(null);
		
		gl.disable(gl.DEPTH_TEST);
	}
	
	public static function getPerspective(fovY: Float, aspectRatio: Float, zNear: Float, zFar: Float): Matrix4 {
		
		var rad: Float = fovY * (Math.PI / 180);
		var f: Float = 1.0 / Math.tan(rad / 2);
		var t: Float = 1.0 / (zFar - zNear);
		var mat: Matrix4 = new Matrix4(new Float32Array([
			f / aspectRatio,
			0.0,
			0.0,
			0.0,
			
			0.0,
			f,
			0.0,
			0.0,
			
			0.0,
			0.0,
			(zFar + zNear) * t,
			-1.0,
			
			0.0,
			0.0,
			2 * zFar * zNear * t,
			0.0]));
		
		return mat;
	}
	
	// public override function update(deltaTime: Int):Void {
		
	// }
}
