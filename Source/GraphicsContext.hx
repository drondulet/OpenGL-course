package;

import lime.graphics.WebGL2RenderContext;
import lime.ui.Window;
import lime.utils.Log;


class GraphicsContext {
	
	static public var gl(default, null): WebGL2RenderContext;
	
	static public function init(window: Window): Void {
		
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
	}
}