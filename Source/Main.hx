package;

import Texture.ETextureType;
import gltfTools.GLTFBuilder;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.graphics.WebGL2RenderContext;
import lime.utils.Assets;
import lime.utils.Float32Array;
import lime.utils.Log;
import lime.utils.UInt16Array;
import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Vec2;
import mme.math.glmatrix.Vec3;
import mme.math.glmatrix.Vec4;
import scene.Node3d;
import scene.Scene3d;

using mme.math.glmatrix.Mat4Tools;
using mme.math.glmatrix.Vec3Tools;


class Main extends Application {
	
	private var gl: WebGL2RenderContext;
	private var currProgram: Shader;
	private var dirShadowShader: Shader;
	private var screenPlane: Shader;
	private var camera: Camera;
	
	private var model: Mat4;
	private var projection: Mat4;
	
	private var plane: Mesh;
	
	private var scene: Scene3d;
	private var directionalLight: DirectinalLight;
	private var pointLights: Array<PointLight>;
	private var spotLights: Array<SpotLight>;
	
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
	
	public override function update(deltaTime: Int):Void {
		
		if (camera != null) {
			camera.update(deltaTime / 1000);
		}
	}
	
	override public function onWindowClose(): Void {
		
		scene.dispose();
		currProgram.dispose();
		
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
	
	private function init(): Void {
		
		// #if js
		// var canvas: js.html.CanvasElement = cast js.Browser.document.getElementById("content");
		// canvas.onclick = () -> canvas.requestPointerLock();
		// #end
		
		GraphicsContext.init(window);
		gl = GraphicsContext.gl;
		
		projection = Mat4Tools.perspective(45, window.width / window.height, 0.1, 10000);
		
		
		currProgram = new Shader();
		currProgram.createFromString(getVertexShader(), getFragmentShader(), window.context);
		
		currProgram.use();
		gl.uniform1i(currProgram.textureUniformLoc.diffuse, 0);
		gl.uniform1i(currProgram.textureUniformLoc.normal, 1);
		currProgram.unUse();
		
		dirShadowShader = new Shader();
		dirShadowShader.createFromString(getShadowMapVertexShader(), getShadowMapFragmentShader(), window.context);
		
		screenPlane =  new Shader();
		screenPlane.createFromString(getPlaneVertexShader(), getPlaneFragmentShader(), window.context);
		screenPlane.use();
		gl.uniform1i(screenPlane.textureUniformLoc.diffuse, 0);
		gl.uniform1i(screenPlane.textureUniformLoc.normal, 1);
		screenPlane.unUse();
		
		createMeshes();
		
		
		camera = new Camera(window, Vec3.fromValues(0, 1, 7), Vec3.fromValues(0, 1, 0), -90, 0);
		
		
		directionalLight = new DirectinalLight(1, 1, 1, 0.1);
		directionalLight.direction = Vec3.fromValues(20, -20, -20);
		directionalLight.diffuseIntensity = 0.9;
		
		
		var pointLight1 = new PointLight(0.0, 0.0, 1.0, 0.2);
		pointLight1.position = Vec3.fromValues(-5.0, 10.0, 0.0);
		
		var pointLight2 = new PointLight(0.0, 1.0, 0.0, 0.2);
		pointLight2.position = Vec3.fromValues(5.0, 10.0, 0.0);
		
		var pointLight3 = new PointLight(1.0, 1.0, 0.0, 0.2);
		pointLight3.position = Vec3.fromValues(0.0, 3.0, 1.0);
		
		// pointLights = [pointLight1, pointLight2, pointLight3];
		pointLights = [];
		
		for (light in pointLights) {
			
			light.diffuseIntensity = 1;
			light.exponent = 0.07;
			light.linear = 0.14;
			light.constant = 1;
		}
		
		
		var spotLight1 = new SpotLight(0.0, 0.0, 1.0, 0.2);
		spotLight1.position = Vec3.fromValues(0.0, 10.0, -5.0);
		spotLight1.direction = Vec3.fromValues(0.0, -1.0, 0.0);
		spotLight1.edge = 20;
		
		spotLights = [spotLight1];
		
		for (light in spotLights) {
			
			light.diffuseIntensity = 1;
			light.exponent = 0.0075;
			light.linear = 0.045;
			light.constant = 1;
		}
	}
	
	private function createMeshes(): Void {
		
		scene = new Scene3d();
		
		// var brick: Texture = new Texture(ETextureType.diffuse);
		// brick.loadRGBA(Assets.getImage("assets/C01 008 Brick Wall 2048x2048.jpg"));
		
		// var brickNormal: Texture = new Texture(ETextureType.normal);
		// brickNormal.loadRGBA(Assets.getImage("assets/C01 008 Brick Wall 2048x2048 Normal Map.jpg"));
		
		// var material: Material = new Material(1, 32);
		// material.setDiffuseTexture(brick);
		// material.setNormalTexture(brickNormal);
		
		var grass: Texture = new Texture(ETextureType.diffuse);
		grass.loadRGBA(Assets.getImage("assets/Stylized_Stone_Floor_005_basecolor.jpg"));
		
		var grassNormal: Texture = new Texture(ETextureType.normal);
		grassNormal.loadRGBA(Assets.getImage("assets/Stylized_Stone_Floor_005_normal.jpg"));
		
		var material: Material = new Material(1, 32);
		material.setDiffuseTexture(grass);
		material.setNormalTexture(grassNormal);
		
		var mesh: Mesh;
		var model: Node3d;
		
		// screen plane
		var pPlaneIndicies = new UInt16Array([
			0, 3, 1,
			1, 3, 2
		]);
		
		var planeVertecies = new Float32Array([
			//	x	y	z		u	v		norm x y z
			-1.0,  1.0, 0.0,	0.0, 1.0,	0.0, 0.0, 1.0,
			 1.0,  1.0, 0.0,	1.0, 1.0,	0.0, 0.0, 1.0,
			 1.0, -1.0, 0.0,	1.0, 0.0,	0.0, 0.0, 1.0,
			-1.0, -1.0, 0.0,	0.0, 0.0,	0.0, 0.0, 1.0
		]);
		
		// plane = Mesh.createFromRawData(planeVertecies, pPlaneIndicies, material);
		
		// plane
		var pIndicies = new UInt16Array([
			0, 3, 1,
			1, 3, 2
		]);
		
		var meshBuilder: MeshBuilder = new MeshBuilder();
		meshBuilder.addPoint(Vec3.fromValues(-10, 0, -10), Vec3.fromValues(0, 1, 0), Vec2.fromValues(0, 5), Vec4.fromValues(-1, 0, 0, 1))
			.addPoint(Vec3.fromValues( 10, 0, -10), Vec3.fromValues(0, 1, 0), Vec2.fromValues(5, 5), Vec4.fromValues(-1, 0, 0, 1))
			.addPoint(Vec3.fromValues( 10, 0,  10), Vec3.fromValues(0, 1, 0), Vec2.fromValues(5, 0), Vec4.fromValues(-1, 0, 0, 1))
			.addPoint(Vec3.fromValues(-10, 0,  10), Vec3.fromValues(0, 1, 0), Vec2.fromValues(0, 0), Vec4.fromValues(-1, 0, 0, 1))
			.setupIndices(pIndicies);
		
		var meshData = meshBuilder.build();
		mesh = Mesh.createFromGLMeshData(meshData, material);
		model = new Node3d();
		model.setMesh(mesh);
		model.setScale(2);
		scene.addNode(model);
		// model.visible = false;
		
		var gltfBuilder: GLTFBuilder;
		var assetPath: String = "assets/glb/Lantern.glb";
		gltfBuilder = GLTFBuilder.getFromFile(assetPath);
		model = gltfBuilder.getNodeWithName("Lantern");
		model.setPosition(Vec3.fromValues(5.0, -0.1, 0.0));
		model.setScale(0.5);
		scene.addNode(model);
		
		assetPath = 'assets/glb/BoxTextured.glb';
		gltfBuilder = GLTFBuilder.getFromFile(assetPath);
		model = gltfBuilder.getNodeWithName(null);
		model.getChildAt(0).meshes[0].material.setNormalTexture(Texture.defaultNormalMap);
		model.resetTransform();
		model.setPosition(Vec3.fromValues(0.0, 1.0, 0.0));
		model.setScale(2);
		scene.addNode(model);
		
		assetPath = "assets/gltf/lantern/Lantern.gltf";
		gltfBuilder = GLTFBuilder.getFromFile(assetPath);
		model = gltfBuilder.getNodeWithName("Lantern");
		model.setPosition(Vec3.fromValues(-5.0, -0.1, -5.0));
		model.setRotation(180, Vec3.fromValues(0.0, 1.0, 0.0));
		model.setScale(0.5);
		scene.addNode(model);
		
		// assetPath = 'assets/gltf/sponza/Sponza.gltf';
		// gltfBuilder = GLTFBuilder.getFromFile(assetPath);
		// model = gltfBuilder.getNodeWithName(null);
		// model.setMeshShader(currProgram);
		// model.resetTransform();
		// model.setPosition(Vec3.fromValues(0.0, 0.0, -30.0));
		// model.setScale(0.02);
		// scene.addNode(model);
		
		// assetPath = "assets/gltf/postwar_city/scene.gltf";
		// gltfBuilder = GLTFBuilder.getFromFile(assetPath);
		// model = gltfBuilder.getNodeWithName("Sketchfab_model");
		// model.resetTransform();
		// model.setMeshShader(currProgram);
		// model.setPosition(Vec3.fromValues(0.0, 5.0, 0.0));
		// model.setRotation(-90, Vec3.fromValues(1.0, 0.0, 0.0));
		// model.setScale(10);
		// scene.addNode(model);
	}
	
	private function getVertexShader(): String {
		return Assets.getText("assets/vertex.glsl");
	}
	
	private function getFragmentShader(): String {
		return Assets.getText("assets/fragment.glsl");
	}
	
	private function getShadowMapVertexShader(): String {
		return Assets.getText("assets/dirShadowMapVert.glsl");
	}
	
	private function getShadowMapFragmentShader(): String {
		return Assets.getText("assets/dirShadowMapFrag.glsl");
	}
	
	private function getPlaneVertexShader(): String {
		return Assets.getText("assets/planeVert.glsl");
	}
	
	private function getPlaneFragmentShader(): String {
		return Assets.getText("assets/planeFrag.glsl");
	}
	
	private function drawGl(): Void {
		
		if (currProgram == null) {
			
			Log.warn("No shader program");
			return;
		}
		
		dirShadowMapPass(directionalLight);
		renderPass(projection, camera.getViewMatrix());
		// renderPass(directionalLight.calcLightTransform(), Mat4Tools.identity());
		// renderPlane();
	}
	
	private function dirShadowMapPass(dirLight: DirectinalLight): Void {
		
		dirShadowShader.use();
		dirLight.shadowMap.begin();
		
		gl.enable(gl.DEPTH_TEST);
		
		gl.viewport(0, 0, dirLight.shadowMap.shadowWidth, dirLight.shadowMap.shadowHeight);
		gl.clear(gl.DEPTH_BUFFER_BIT);
		
		dirShadowShader.setDirLightTransform(dirLight.calcLightTransform());
		
		scene.draw(dirShadowShader);
		
		gl.disable(gl.DEPTH_TEST);
		
		dirLight.shadowMap.end();
		dirShadowShader.unUse();
	}
	
	private function renderPass(proj: Mat4, view: Mat4): Void {
		
		currProgram.use();
		currProgram.useDirectionalLight(directionalLight);
		currProgram.usePointLights(pointLights);
		currProgram.useSpotLights(spotLights);
		
		gl.viewport(0, 0, window.width, window.height);
		gl.enable(gl.DEPTH_TEST);
		
		gl.clearColor(0.05, 0.05, 0.05, 1.0);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
		
		gl.enable(gl.CULL_FACE);
		gl.cullFace(gl.BACK);
		
		// calculate VP mat and put it to shader
		gl.uniformMatrix4fv(currProgram.uniformView, false, view);
		gl.uniformMatrix4fv(currProgram.uniformProjection, false, proj);
		gl.uniform3fv(currProgram.uniformCameraPosition, camera.position);
		gl.uniform3fv(currProgram.vertexViewPos, camera.position);
		
		currProgram.setDirLightTransform(directionalLight.calcLightTransform());
		directionalLight.shadowMap.activate(gl.TEXTURE2);
		currProgram.setDirShadowMapTextureUnit(2);
		
		scene.draw(currProgram);
		
		gl.disable(gl.CULL_FACE);
		gl.disable(gl.DEPTH_TEST);
		
		currProgram.unUse();
	}
	
	private function renderPlane(): Void {
		
		screenPlane.use();
		
		gl.viewport(0, 0, window.width, window.height);
		
		gl.clearColor(0.05, 0.05, 0.05, 1.0);
		gl.clear(gl.COLOR_BUFFER_BIT);
		
		directionalLight.shadowMap.activate(gl.TEXTURE2);
		screenPlane.setDirShadowMapTextureUnit(2);
		
		plane.renderMesh(Mat4Tools.identity(), screenPlane);
		
		screenPlane.unUse();
	}
	
	private function calcAvgNormals(indicies: UInt16Array, vertecies: Float32Array, vLength: Int, normalOffset: Int): Void {
		
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
