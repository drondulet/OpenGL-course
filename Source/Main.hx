package;

#if js
import js.Browser;
import js.html.CanvasElement;
#end
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.graphics.WebGL2RenderContext;
import lime.utils.Assets;
import lime.utils.Float32Array;
import lime.utils.Log;
import lime.utils.UInt32Array;
import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Vec3;

using mme.math.glmatrix.Mat4Tools;
using mme.math.glmatrix.Vec3Tools;


class Main extends Application {
	
	private var gl: WebGL2RenderContext;
	private var currProgram: Shader;
	private var camera: Camera;
	
	private var model: Mat4;
	private var projection: Mat4;
	
	private var meshes: Array<Mesh> = [];
	private var brick: Texture;
	private var directionalLight: DirectinalLight;
	private var pointLights: Array<PointLight>;
	private var material: Material;
	
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
		
		// #if js
		// var canvas: CanvasElement = cast Browser.document.getElementById("content");
		// canvas.onclick = () -> canvas.requestPointerLock();
		// #end
		
		GraphicsContext.init(window);
		gl = GraphicsContext.gl;
		
		projection = Mat4Tools.perspective(45, window.width / window.height, 0.1, 100);
		
		createMeshes();
		
		currProgram = new Shader();
		currProgram.createFromString(getVertexShader(), getFragmentShader(), window.context);
		
		camera = new Camera(window, Vec3.fromValues(0, 2, 0), Vec3.fromValues(0, 1, 0), -90, 0);
		
		directionalLight = new DirectinalLight(1, 1, 1, 0.2);
		directionalLight.direction = Vec3.fromValues(1, -1, -1);
		directionalLight.diffuseIntensity = 0.1;
		
		var pointLight1 = new PointLight(0.0, 0.0, 1.0, 0.2);
		pointLight1.position = Vec3.fromValues(-5.0, 6.0, 0.0);
		
		var pointLight2 = new PointLight(0.0, 1.0, 0.0, 0.2);
		pointLight2.position = Vec3.fromValues(5.0, 6.0, 0.0);
		
		var pointLight3 = new PointLight(1.0, 1.0, 0.0, 0.2);
		pointLight3.position = Vec3.fromValues(0.0, -2.0, 0.0);
		
		pointLights = [pointLight1, pointLight2, pointLight3];
		
		for (light in pointLights) {
			
			light.diffuseIntensity = 1;
			light.exponent = 0.07;
			light.linear = 0.14;
			light.constant = 1;
		}
		
		brick = new Texture();
		brick.load(Assets.getImage("assets/brick.png"));
		
		material = new Material(1, 32);
	}
	
	private function createMeshes(): Void {
		
		// pyramid
		var indicies: UInt32Array = new UInt32Array([
			0, 1, 3,
			1, 2, 3,
			2, 0, 3,
			0, 2, 1
		]);
		
		var vertecies: Float32Array = new Float32Array([
			//	x	y	z		u	v		norm x y z
			-1.0, -1.0,  0.0,	0.0, 0.0,	0.0, 0.0, 0.0,
			 0.0, -0.5,  1.0,	0.0, 1.0,	0.0, 0.0, 0.0,
			 1.0, -1.0,  0.0,	1.0, 0.0,	0.0, 0.0, 0.0,
			 0.0,  1.0,  0.0,	0.5, 1.0,	0.0, 0.0, 0.0
		]);
		
		calcAvgNormals(indicies, vertecies, 8, 5);
		
		var mesh: Mesh = new Mesh();
		mesh.createMesh(vertecies, indicies);
		
		meshes.push(mesh);
		
		// plane
		var pIndicies = new UInt32Array([
			0, 3, 1,
			1, 3, 2
		]);
		
		var pVertecies = new Float32Array([
			//	x	y	z		u	v		norm x y z
			-10.0, -5.0, -10.0,	0.0, 5.0,	0.0, -1.0, 0.0,
			 10.0, -5.0, -10.0,	5.0, 5.0,	0.0, -1.0, 0.0,
			 10.0, -5.0, 10.0,	5.0, 0.0,	0.0, -1.0, 0.0,
			-10.0, -5.0, 10.0,	0.0, 0.0,	0.0, -1.0, 0.0,
		]);
		
		mesh = new Mesh();
		mesh.createMesh(pVertecies, pIndicies);
		
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
		
		currProgram.dispose();
		
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
		
		if (currProgram == null) {
			
			Log.warn("No shader program");
			return;
		}
		
		model = new Mat4();
		model.translate(Vec3.fromValues(0, 0, -5), model);
		
		gl.viewport(0, 0, window.width, window.height);
		gl.enable(gl.DEPTH_TEST);
		
		gl.clearColor(0.05, 0.05, 0.05, 1.0);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		
		gl.enable(gl.CULL_FACE);
		gl.cullFace(gl.BACK);
		
		currProgram.use();
		currProgram.useDirectionalLight(directionalLight);
		currProgram.usePointLights(pointLights);
		
		gl.uniformMatrix4fv(currProgram.uniformModel, false, model);
		gl.uniformMatrix4fv(currProgram.uniformView, false, camera.getViewMatrix());
		gl.uniformMatrix4fv(currProgram.uniformProjection, false, projection);
		gl.uniform3fv(currProgram.uniformCameraPosition, camera.position);
		
		brick.use();
		material.useMaterial(currProgram.uniformSpecularIntensity, currProgram.uniformSpecularShininess);
		for (mesh in meshes) {
			mesh.renderMesh();
		}
		brick.unUse();
		
		gl.useProgram(null);
		
		gl.disable(gl.DEPTH_TEST);
	}
	
	public override function update(deltaTime: Int):Void {
		
		if (camera != null) {
			camera.update(deltaTime / 1000);
		}
	}
	
	private function calcAvgNormals(indicies: UInt32Array, vertecies: Float32Array, vLength: Int, normalOffset: Int): Void {
		
		var i: Int = 0;
		while (i < indicies.length) {
			
			var in0: Int = indicies[i] * vLength;
			var in1: Int = indicies[i + 1] * vLength;
			var in2: Int = indicies[i + 2] * vLength;
			
			var v1: Vec3 = Vec3.fromValues(vertecies[in1] - vertecies[in0], vertecies[in1 + 1] - vertecies[in0 + 1], vertecies[in1 + 2] - vertecies[in0 + 2]);
			var v2: Vec3 = Vec3.fromValues(vertecies[in2] - vertecies[in0], vertecies[in2 + 1] - vertecies[in0 + 1], vertecies[in2 + 2] - vertecies[in0 + 2]);
			var normal: Vec3 = v1.cross(v2);
			normal.normalize(normal);
			
			in0 += normalOffset; in1 += normalOffset; in2 += normalOffset;
			vertecies[in0] += normal.x; vertecies[in0 + 1] += normal.y; vertecies[in0 + 2] += normal.z;
			vertecies[in1] += normal.x; vertecies[in1 + 1] += normal.y; vertecies[in1 + 2] += normal.z;
			vertecies[in2] += normal.x; vertecies[in2 + 1] += normal.y; vertecies[in2 + 2] += normal.z;
			
			i += 3;
		}
		
		for (i in 0 ... Std.int(vertecies.length / vLength)) {
			
			var nOffest: Int = i * vLength + normalOffset;
			var vec: Vec3 = Vec3.fromValues(vertecies[nOffest], vertecies[nOffest + 1], vertecies[nOffest + 2]).normalize();
			vertecies[nOffest] = vec.x; vertecies[nOffest + 1] = vec.y; vertecies[nOffest + 2] = vec.y;
		}
	}
}
