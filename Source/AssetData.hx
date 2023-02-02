package;

import lime.utils.Bytes;

class AssetData {
	
	public final path: String;
	public final data: Bytes;
	public final type: String;
	
	public function new(path: String, data: Bytes) {
		
		this.path = path;
		this.data = data;
		
		var idx: Int = path.lastIndexOf(".");
		type = path.substr(idx + 1);
	}
}
