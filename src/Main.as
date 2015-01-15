package {
	import chimichanga.debug.logging.log;
	import chimichanga.global.app.Platform;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import starling.core.Starling;
	
	//[SWF(width="640", height="960", backgroundColor="#000000", frameRate="60")]
	[SWF(width="1280",height="860",backgroundColor="#0",frameRate="60")]
	//[SWF(width="1280",height="720",backgroundColor="#0",frameRate="60")]
	//[SWF( width="800",height="480",backgroundColor="#000000",frameRate="60" )]
	//[SWF(width="400",height="240",backgroundColor="#00000",frameRate="60")]
	
	public class Main extends Sprite {
		
		public static var iOS:Boolean = false;
		private var starling:Starling;
		
		private var mStage3D:Stage3D;
		private var viewRect:Rectangle;
		
		public function Main():void
		{
			trace( 12345 );
			
			if ( stage == null ) {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage );
			} else {
				onAddedToStage( null );
			}
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			viewRect = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			Starling.multitouchEnabled = true; // useful on mobile devices
			Starling.handleLostContext = !Platform.isIOS(); // not necessary on iOS. Saves a lot of memory!
			
			stage.addEventListener(Event.ACTIVATE, activate );
			stage.addEventListener(Event.DEACTIVATE, deactivate );
			stage.addEventListener(Event.RESIZE, onStageResize );
			
			mStage3D = stage.stage3Ds[ 0 ];
			
			mStage3D.addEventListener( Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true );
			mStage3D.requestContext3D();
			
		}
		
		CONFIG::air
		private function onRightClick( e:MouseEvent ):void {
			
			//dispatchAppEvent( AppEvents.RIGHT_CLICK );
			
		}
		
		private function onContextCreated( event:Event ):void {
			
			mStage3D.context3D.configureBackBuffer( stage.stageWidth, stage.stageHeight, 0, false );
			
			if ( !starling ) {
				
				initStarling();
				
			}
			
		}
		
		private function initStarling():void {
			
			starling = new Starling( StarlingMain, stage, viewRect );
			starling.addEventListener( "rootCreated", onStarlingReady );
			
			starling.antiAliasing = 0;
			starling.simulateMultitouch = true;
			starling.enableErrorChecking = true;
			starling.showStats = CONFIG::development;
			starling.showStats = true;
			starling.showStatsAt( "left", "bottom" );
			
			//starling.start();
			
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		
		}
		
		private function onStageResize(e:Event):void {
			
			if ( starling ) {
				viewRect.width = stage.stageWidth;
				viewRect.height = stage.stageHeight;
				mStage3D.context3D.configureBackBuffer( viewRect.width, viewRect.height, 0, false );
			}
			
		}
		
		private function onStarlingReady( e:* = null ):void {
			
			starling.removeEventListener( "rootCreated", onStarlingReady );
			
			log( "Starling v" + Starling.VERSION + " ready" );
			
			starling.start();
			
		}
		
		private function onEnterFrame( e:Event ):void {
			
			if ( starling.isStarted ) {
				mStage3D.context3D.clear();
				starling.nextFrame()
				mStage3D.context3D.present();
			}
		
		}
		
		private function deactivate( e:Event ):void {
			
			//if ( starling )
				//starling.stop();
			
		}
		
		private function activate( e:Event ):void {
			
			//if ( starling )
				//starling.start();
			
		}
		
	}

}