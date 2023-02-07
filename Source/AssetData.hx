package;

import haxe.io.Path;

class AssetData {
	
	public final path: String;
	public final directory: String;
	public final data: Dynamic;
	public final type: String;
	
	public function new(path: String, data: Dynamic) {
		
		this.path = path;
		this.data = data;
		
		var idx: Int = path.lastIndexOf(".");
		type = path.substr(idx + 1);
		
		directory = Path.directory(path);
	}
}
