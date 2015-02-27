package ui
{
	import chimichanga.common.display.Sprite;
	import feathers.controls.TextArea;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class MenuInput extends Sprite
	{
		static public const FORMAT:TextFormat = new TextFormat( "Lucida Console", 80, 0xCCDDEEE, true, null, null, null, null, "center" );
		private var d:Quad;
		private var con:Sprite;
		private var func:Function;
		private var nameArgPairs:Object;
		
		public function initialize( nameArgPairs:Object, func:Function ):void
		{
			this.func = func;
			this.nameArgPairs = nameArgPairs;
			
			d = new Quad( 2560, 1920, 0x0 );
			d.alpha = .4;
			d.alignPivot();
			addChild( d );
			
			con = new Sprite()
			addChild( con );
			var b:Button;
			for ( var name:String in nameArgPairs ) 
			{
				b = new Button( App.assets.getTexture( "btn" ), name );
				b.fontColor = 0xFFFFFF;
				b.fontSize = 28;
				b.fontBold = true;
				b.x = -150;
				b.y = con.numChildren == 0 ? 0 : con.height + 5;
				b.addEventListener( Event.TRIGGERED, onB );
				con.addChild( b );
			}
			con.alignPivot();
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKey );
			d.addEventListener( TouchEvent.TOUCH, onDimmerTouch );
			
			animateIn();
		}
		
		private function onB( e:Event ):void 
		{
			const b:Button = e.currentTarget as Button;
			func( nameArgPairs[ b.text ] );
			animateOut();
		}
		
		private function onDimmerTouch(e:TouchEvent):void 
		{
			if ( e.getTouch( d, TouchPhase.ENDED ) )
				animateOut();
		}
		
		private function animateIn():void
		{
			alpha = .0;
			Starling.juggler.tween( this, .220, { alpha: 1.0 } );
		}
		
		private function animateOut():void
		{
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKey );
			d.removeEventListener( TouchEvent.TOUCH, onDimmerTouch );
			
			Starling.juggler.tween( this, .220, { alpha: 0.0, onComplete: removeFromParent, onCompleteArgs: [ true ] } );
		}
		
		override public function dispose():void
		{
			d.removeFromParent( true );
			con.removeFromParent( true );
			func = null;
			nameArgPairs = null;
			super.dispose();
		}
		
		private function onKey( e:KeyboardEvent ):void
		{
			if ( e.keyCode == Keyboard.ESCAPE )
				animateOut();
		}
		
		//
		public static function generate( stage:Stage, nameArgPairs:Object, func:Function ):MenuInput
		{
			var o:MenuInput = new MenuInput();
			stage.addChild( o );
			o.x = .5 * stage.stageWidth;
			o.y = .5 * stage.stageHeight;
			o.initialize( nameArgPairs, func );
			return o;
		}
		
	}

}