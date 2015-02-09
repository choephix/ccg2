package
{
	import chimichanga.common.display.Sprite;
	import editor.Card;
	import editor.CardGroup;
	import editor.Space;
	import flash.ui.Keyboard;
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
		}
		
		private function onTouch( e:TouchEvent ):void
		{
			var t:Touch = e.getTouch( stage );
			
			if ( t == null )
				return;
			
			t.getLocation( stage, App.mouseXY );
		
			//if ( t.phase == TouchPhase.ENDED )
			//if ( t.tapCount == 2 ) 
			//App.toggleFullScreen();
		}
		
		private function enqueueAssets():void
		{
			
			CONFIG::air
			{
				App.assets.enqueue( "assets/" );
				return;
			}
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
			CONFIG::development
			{
				stage.addEventListener( KeyboardEvent.KEY_DOWN, onkey );
			}
			
			loadingText.removeFromParent( true );
			loadingText = null;
			
			initialize();
		}
		
		private function initialize():void
		{
			bg = App.assets.generateImage( "bg", false, false );
			bg.alpha = .0;
			addChild( bg );
			Starling.juggler.tween( bg, .250, { alpha: 2.0 } );
			
			onResize( null );
			
			space = new Space();
			addChild( space );
		}
		
		CONFIG::development
		private function onkey( e:KeyboardEvent ):void
		{
			if ( e.keyCode == Keyboard.A )
				space.generateNewCard();
			else
			if ( e.keyCode >= Keyboard.NUMBER_1 && e.keyCode <= Keyboard.NUMBER_9 )
				space.setView( e.keyCode - Keyboard.NUMBER_1 );
		}
	}
}