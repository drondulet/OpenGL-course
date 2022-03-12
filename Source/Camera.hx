package;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import mme.math.glmatrix.Mat4;
import mme.math.glmatrix.Vec3;

using Math;
using MathHelper;
using mme.math.glmatrix.Mat4Tools;
using mme.math.glmatrix.Vec3Tools;


class Camera {
	
	public var moveSpeed: Float;
	public var turnSpeed: Float;
	public var accelMultiplier: Float;
	
	private var up: Vec3;
	private var front: Vec3;
	private var right: Vec3;
	private var worldUp: Vec3;
	private var position: Vec3;
	private var newPosition: Vec3;
	
	private var yaw: Float;
	private var pitch: Float;
	
	private var window: Window;
	
	private var delta: Float;
	
	public function new(window: Window, pos: Vec3, upDirection: Vec3, yaw: Float, pitch: Float) {
		
		this.window = window;
		
		position = pos;
		newPosition = new Vec3();
		worldUp = upDirection;
		this.yaw = yaw.toRadians();
		this.pitch = pitch.toRadians();
		
		front = Vec3.fromValues(0.0, 0.0, 1.0);
		right = new Vec3();
		up = new Vec3();
		
		moveSpeed = 100;
		turnSpeed = 0.25;
		
		accelMultiplier = 3;
		
		singInputs();
		updateOrientation();
	}
	
	public function update(delta: Float): Void {
		this.delta = delta;
	}
	
	public function getViewMatrinx(): Mat4 {
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
		window.onMouseMoveRelative.add(onMouseMove);
	}
	
	private function onKeyDown(keyCode: KeyCode, modifier: KeyModifier): Void {
		
		function applyMove(forward: Int, strafe: Int): Void {
			
			var moveValue: Float = delta * moveSpeed * (modifier.shiftKey ? accelMultiplier : 1);
			
			if (forward != 0) {
				position.scaleAndAdd(front, moveValue * forward, position);
			}
			else if (strafe != 0) {
				position.scaleAndAdd(right, moveValue * strafe, position);
			}
			
			// position.x = Math.abs(position.x) > 0.000001 ? position.x : 0;
			// position.y = Math.abs(position.y) > 0.000001 ? position.y : 0;
			// position.z = Math.abs(position.z) > 0.000001 ? position.z : 0;
			
			// haxe.Log.trace('Position: ${position}');
		}
		
		switch (keyCode) {
			
			case W: applyMove(1, 0);
			case S: applyMove(-1, 0);
			case A: applyMove(0, -1);
			case D: applyMove(0, 1);
			case F: 
				window.fullscreen = !window.fullscreen;
				window.mouseLock = window.fullscreen;
			
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