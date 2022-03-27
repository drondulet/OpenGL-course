package;

import lime.utils.Assets;
import lime.app.Application;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.RenderContext;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;
import lime.utils.Log;
import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Vec3;

using mme.math.glmatrix.Mat4Tools;


class Main extends Application {
	
	private var gl: WebGL2RenderContext;
	private var currentProgram: Shader;
	private var camera: Camera;
	
	private var model: Mat4;
	private var projection: Mat4;
	
	private var meshes: Array<Mesh> = [];
	private var brick: Texture;
	private var light: Light;
	
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
		
		GraphicsContext.init(window);
		gl = GraphicsContext.gl;
		
		projection = Mat4Tools.perspective(45, window.width / window.height, 0.1, 100);
		
		createMeshes();
		
		currentProgram = new Shader();
		currentProgram.createFromString(getVertexShader(), getFragmentShader(), window.context);
		
		camera = new Camera(window, Vec3.fromValues(0, 0, 0), Vec3.fromValues(0, 1, 0), -90, 0);
		
		light = new Light(1, 1, 1, 0.2);
	}
	
	private function createMeshes(): Void {
		
		var indicies: UInt32Array = new UInt32Array([
			0, 3, 1,
			1, 3, 2,
			2, 3, 0,
			0, 1, 2
		]);
		
		var vertecies: Float32Array = new Float32Array([
			-1.0, -1.0,  0.0,	0.0, 0.0,
			 0.0, -0.5,  1.0,	0.0, 1.0,
			 1.0, -1.0,  0.0,	1.0, 0.0,
			 0.0,  1.0,  0.0,	0.5, 1.0
		]);
		
		var mesh: Mesh = new Mesh();
		mesh.createMesh(vertecies, indicies);
		
		meshes.push(mesh);
		
		brick = new Texture();
		brick.load(Assets.getImage("assets/brick.png"));
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
		
		brick.dispose();
		
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
		
		model = new Mat4();
		model.translate(Vec3.fromValues(0, 0, -5), model);
		
		gl.viewport(0, 0, window.width, window.height);
		gl.enable(gl.DEPTH_TEST);
		
		gl.clearColor(0.05, 0.05, 0.05, 1.0);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		
		currentProgram.use();
		
		light.use(currentProgram.uniformAmbientIntensity, currentProgram.uniformAmbientColor);
		
		gl.uniformMatrix4fv(currentProgram.uniformModel, false, model);
		gl.uniformMatrix4fv(currentProgram.uniformView, false, camera.getViewMatrinx());
		gl.uniformMatrix4fv(currentProgram.uniformProjection, false, projection);
		
		brick.use();
		for (mesh in meshes) {
			mesh.renderMesh();
		}
		
		gl.useProgram(null);
		
		gl.disable(gl.DEPTH_TEST);
	}
	
	
	public override function update(deltaTime: Int):Void {
		
		if (camera != null) {
			camera.update(deltaTime / 1000);
		}
	}
}
