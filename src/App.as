package {
	import chimichanga.common.assets.AdvancedAssetManager;
	import starling.display.Stage;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class App {
		
		public static var stage:Stage;
		public static var root:StarlingMain;
		
		public static var initialized:Boolean;
		
		public static var assets:AdvancedAssetManager;
		
		public static function initialize( root:StarlingMain ):void {
			
			App.root = root;
			stage = root.stage;
			assets = new AdvancedAssetManager();
		}
		
		public static function get W():int {	
			return 1280;
		}
		
		public static function get H():int {	
			return 860;
		}
		
		public static function get VERSION():String {	
			return Version.Major + "." + Version.Minor + "." + Version.Build + "." + Version.Revision;
		}
	}
}