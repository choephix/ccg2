package ui
{
	import chimichanga.common.display.Sprite;
	import feathers.controls.TextArea;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Stage;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class StringInput extends Sprite
	{
		static public const FORMAT:TextFormat = new TextFormat( "Lucida Console", 80, 0xCCDDEEE, true, null, null, null, null, "center" );
		private var d:Quad;
		private var q:Quad;
		private var t:TextArea;
		private var onDone:Function;
		
		public function initialize( onDone:Function ):void
		{
			this.onDone = onDone;
			
			const W:Number = 1000;
			const H:Number = 250;
			
			d = new Quad( 2560, 1920, 0x0 );
			d.alpha = .4;
			d.alignPivot();
			addChild( d );
			
			q = new Quad( W, H, 0x0 );
			q.alpha = .9;
			q.alignPivot();
			addChild( q );
			
			t = new TextArea();
			t.textEditorProperties.textFormat = FORMAT;
			t.width = W;
			t.height = FORMAT.size + 10;
			addChild( t );
			t.validate();
			t.alignPivot();
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKey );
			d.addEventListener( TouchEvent.TOUCH, onDimmerTouch );
			
			animateIn();
		}
		
		private function onDimmerTouch(e:TouchEvent):void 
		{
			if ( e.getTouch( d, TouchPhase.ENDED ) )
				animateOut();
		}
		
		private function animateIn():void
		{
			alpha = .0;
			Starling.juggler.tween( this, .220, { alpha: 1.0, onComplete: t.setFocus } );
		}
		
		private function animateOut():void
		{
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKey );
			d.removeEventListener( TouchEvent.TOUCH, onDimmerTouch );
			t.visible = false;
			
			Starling.juggler.tween( this, .220, { alpha: 0.0, onComplete: removeFromParent, onCompleteArgs: [ true ] } );
		}
		
		override public function dispose():void
		{
			q.removeFromParent( true );
			t.removeFromParent( true );
			onDone = null;
			
			super.dispose();
		}
		
		private function onKey( e:KeyboardEvent ):void
		{
			if ( e.keyCode == Keyboard.ENTER )
			{
				e.stopImmediatePropagation();
				t.text = t.text.replace( "\n", "" );
				if ( onDone != null )
					onDone( t.text );
				animateOut();
			}
			else
			if ( e.keyCode == Keyboard.ESCAPE )
				animateOut();
		}
		
		public function get text():String 
		{ return t.text }
		
		public function set text(value:String):void 
		{ t.text = value }
		
		//
		public static function generate( stage:Stage, onDone:Function, text:String="" ):StringInput
		{
			var o:StringInput = new StringInput();
			stage.addChild( o );
			o.x = .5 * stage.stageWidth;
			o.y = .5 * stage.stageHeight;
			o.initialize( onDone );
			o.text = text;
			return o;
		}
		
	}

}