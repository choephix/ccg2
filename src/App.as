package {
	import chimichanga.common.assets.AdvancedAssetManager;
	import flash.display.StageDisplayState;
	import flash.display.Stage;
	import flash.geom.Point;
	import global.CardsDataLoader;
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
		
		public static const FONT1:String = "font1_0";
		public static const FONT2:String = "font2_0";
		public static const FONT3:String = "font3_0";
		
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
				trace( nativeStage.displayState == isFullscreen ? "NORMAL" : "FULL_SCREEN_INTERACTIVE" );
				nativeStage.displayState = isFullscreen ? 
					StageDisplayState.NORMAL : 
					StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			static public function get isFullscreen():Boolean 
			{ return nativeStage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE }
		}
		
		/// STARLING SHIT
		
		public static var stage:starling.display.Stage;
		public static var root:StarlingMain;
		
		public static var initialized:Boolean;
		public static var assets:AdvancedAssetManager;
		public static var cardsData:CardsDataLoader;
		public static var globalMouseLocation:Point = new Point();
		
		public static function initialize( root:StarlingMain ):void {
			
			App.root = root;
			stage = root.stage;
			assets = new AdvancedAssetManager();
			cardsData = new CardsDataLoader();
		}
		
		public static function get W():int
		{ return 1920 }
		
		public static function get H():int
		{ return 1080 }
		
		public static function get WINDOW_W():int
		{ return 1280 }
		
		public static function get WINDOW_H():int
		{ return 720 }
		
		public static function get STAGE_W():int
		{ return stage.stageWidth }
		
		public static function get STAGE_H():int
		{ return stage.stageHeight }
		
		public static function get VERSION():String
		{ return Version.Major + "." + Version.Minor + "." + Version.Build + "." + Version.Revision }
	}
}