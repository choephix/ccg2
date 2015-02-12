package
{
	import chimichanga.common.display.Sprite;
	import editor.Space;
	import feathers.core.FocusManager;
	import other.Input;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.ResizeEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	
	CONFIG::air
	{
		import flash.filesystem.File;
	}
	
	/**
	 * ...
	 * @author choephix
	 */
	public class StarlingMain extends Sprite
	{
		private var loadingText:TextField;
		private var bg:Image;
		
		private var space:Space;
		
		public function StarlingMain()
		{
			blendMode = BlendMode.NORMAL;
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		private function onAddedToStage( e:Event = null ):void
		{
			removeEventListeners( Event.ADDED_TO_STAGE );
			App.initialize( this );
			
			enqueueAssets();
			Starling.juggler.delayCall( startLoadingAssets, .25 );
			
			stage.addEventListener( TouchEvent.TOUCH, onTouch );
			stage.addEventListener( ResizeEvent.RESIZE, onResize );
		}
		
		private function onResize(e:ResizeEvent):void 
		{
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			
			if ( space )
				space.onResize();
		}
		
		private function onTouch( e:TouchEvent ):void
		{
			var t:Touch = e.getTouch( stage );
			
			if ( t == null )
				return;
			
			t.getLocation( stage, App.mouseXY );
		}
		
		private function enqueueAssets():void
		{
			App.assets.enqueue( "assets/bg.jpg" );
			App.assets.enqueue( "assets/b.png" );
		}
		
		private function startLoadingAssets():void
		{
			loadingText = new TextField( stage.stageWidth, stage.stageHeight, "...", "Arial Black", 80, 0x304050, true );
			addChild( loadingText );
			
			App.assets.initialize( onLoadingAppProgress, onLoadingAppComplete );
		}
		
		private function onLoadingAppProgress( progress:Number ):void
		{
			loadingText.text = int( progress * 100 ) + "%";
			loadingText.width = stage.stageWidth;
			loadingText.height = stage.stageHeight;
		}
		
		private function onLoadingAppComplete():void
		{
			loadingText.removeFromParent( true );
			loadingText = null;
			
			bg = App.assets.generateImage( "bg", false, false );
			bg.alpha = .0;
			addChild( bg );
			Starling.juggler.tween( bg, .250, { alpha: 2.0 } );
			
			onResize( null );
			
			App.remote.load( onDataLoaded );
		}
		
		private function onDataLoaded( data:String ):void
		{
			FocusManager.setEnabledForStage( this.stage, true );
			Input.initialize();
			
			space = new Space();
			addChild( space );
			space.initialize( data );
		}
	}
}