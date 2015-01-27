package {
	import chimichanga.common.assets.AdvancedAssetManager;
	import flash.display.StageDisplayState;
	import flash.display.Stage;
	import starling.display.Stage;
	
	CONFIG::desktop {
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	}
	/**
	 * ...
	 * @author choephix
	 */
	public class App {
		
		/// NATIVE SHIT
		
		public static var nativeStage:flash.display.Stage;
		
		CONFIG::desktop
		{
			public static var nativeWindow:NativeWindow;
			public static function get isMinimized():Boolean
			{ 
				if ( nativeWindow == null ) return false;
				if ( nativeWindow.closed ) return true;
				return nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED
			}
			public static function toggleFullScreen():void
			{ 
				if( nativeStage.displayState == StageDisplayState.NORMAL ) {
					nativeStage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				} else {
					nativeStage.displayState = StageDisplayState.NORMAL;
				}
			}
		}
		
		/// STARLING SHIT
		
		public static var stage:starling.display.Stage;
		public static var root:StarlingMain;
		
		public static var initialized:Boolean;
		
		public static var assets:AdvancedAssetManager;
		
		public static function initialize( root:StarlingMain ):void {
			
			App.root = root;
			stage = root.stage;
			assets = new AdvancedAssetManager();
		}
		
		public static function get W():int
		{ return 1280 }
		
		public static function get H():int
		{ return 860 }
		
		public static function get VERSION():String
		{ return Version.Major + "." + Version.Minor + "." + Version.Build + "." + Version.Revision }
	}
}