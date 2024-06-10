package;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Vec2;
import mme.math.glmatrix.Vec3;

using Math;
using MathHelper;
using mme.math.glmatrix.Mat4Tools;
using mme.math.glmatrix.Vec3Tools;


class Camera {
	
	public var moveSpeed: Float;
	public var turnSpeed: Float;
	public var accelMultiplier: Float;
	
	public var position(default, null): Vec3;
	
	private var up: Vec3;
	private var front: Vec3;
	private var right: Vec3;
	private var worldUp: Vec3;
	
	private var yaw: Float;
	private var pitch: Float;
	
	private var movingDirection: Vec2;
	private var currentAccel: Float;
	
	private var window: Window;
	
	private var delta: Float;
	
	public function new(window: Window, pos: Vec3, upDirection: Vec3, yaw: Float, pitch: Float) {
		
		this.window = window;
		
		position = pos;
		worldUp = upDirection;
		this.yaw = yaw.toRadians();
		this.pitch = pitch.toRadians();
		
		front = Vec3.fromValues(0.0, 0.0, 1.0);
		right = new Vec3();
		up = new Vec3();
		
		moveSpeed = 15;
		turnSpeed = 0.25;
		
		accelMultiplier = 3;
		currentAccel = 1;
		
		delta = 0;
		
		movingDirection = Vec2.fromValues(0, 0);
		
		singInputs();
		updateOrientation();
	}
	
	public function update(delta: Float): Void {
		
		this.delta = delta;
		
		if (movingDirection.x != 0 || movingDirection.y != 0) {
			
			var moveValue: Float = delta * moveSpeed * currentAccel;
			position.scaleAndAdd(front, moveValue * movingDirection.x, position);
			position.scaleAndAdd(right, moveValue * movingDirection.y, position);
		}
	}
	
	public function getViewMatrix(): Mat4 {
		return Mat4Tools.lookAt(position, position.add(front), worldUp);
	}
	
	private function updateOrientation(): Void {
		
		front.x = yaw.cos() * pitch.cos();
		front.y = pitch.sin();
		front.z = yaw.sin() * pitch.cos();
		front.normalize(front);
		
		front.cross(worldUp, right);
		right.normalize(right);
		
		right.cross(front, up);
		up.normalize(up);
	}
	
	private function singInputs(): Void {
		
		window.onKeyDown.add(onKeyDown);
		window.onKeyUp.add(onKeyUp);
		// #if js
		// var canvas: CanvasElement = cast Browser.document.getElementById("content");
		// canvas.onmousemove = onMouseMove;
		// #else
		window.onMouseMoveRelative.add(onMouseMove);
		// #end
	}
	
	private function onKeyDown(keyCode: KeyCode, modifier: KeyModifier): Void {
		
		switch (keyCode) {
			
			case W: movingDirection.x = 1;
			case S: movingDirection.x = -1;
			case A: movingDirection.y = -1;
			case D: movingDirection.y = 1;
			case LEFT_SHIFT: currentAccel = accelMultiplier;
			case F: 
				window.fullscreen = !window.fullscreen;
				window.mouseLock = window.fullscreen;
			
			default:
		}
	}
	
	private function onKeyUp(keyCode: KeyCode, modifier: KeyModifier): Void {
		
		switch (keyCode) {
			
			case W | S: movingDirection.x = 0;
			case A | D: movingDirection.y = 0;
			case LEFT_SHIFT: currentAccel = 1;
			
			default:
		}
	}
	
	private function onMouseMove(x: Float, y: Float): Void {
		
		x *= turnSpeed * delta;
		y *= -turnSpeed * delta;
		
		yaw += x;
		pitch += y;
		
		if (yaw > 360.toRadians()) {
			yaw -= 360.toRadians();
		}
		
		if (yaw < 0) {
			yaw += 360.toRadians();
		}
		
		if (pitch > 89.toRadians()) {
			pitch = 89.toRadians();
		}
		
		if (pitch < -89.toRadians()) {
			pitch = -89.toRadians();
		}
		
		updateOrientation();
	}
}