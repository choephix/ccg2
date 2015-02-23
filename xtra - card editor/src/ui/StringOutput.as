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
	public class StringOutput extends Sprite
	{
		static public const FORMAT:TextFormat = new TextFormat( "Lucida Console", 16, 0xCCDDEEE, true, null, null, null, null, "center" );
		private var d:Quad;
		private var q:Quad;
		private var t:TextArea;
		
		public function initialize():void
		{
			const W:Number = stage.stageWidth - 100;
			const H:Number = stage.stageHeight - 100;
			
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
			t.height = H;
			addChild( t );
			t.validate();
			t.alignPivot();
			
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
			d.removeEventListener( TouchEvent.TOUCH, onDimmerTouch );
			t.visible = false;
			Starling.juggler.tween( this, .220, { alpha: 0.0, onComplete: removeFromParent, onCompleteArgs: [ true ] } );
		}
		
		override public function dispose():void
		{
			q.removeFromParent( true );
			t.removeFromParent( true );
			super.dispose();
		}
		
		public function get text():String 
		{ return t.text }
		
		public function set text(value:String):void 
		{ t.text = value }
		
		//
		public static function generate( stage:Stage, text:String ):StringOutput
		{
			var o:StringOutput = new StringOutput();
			stage.addChild( o );
			o.x = .5 * stage.stageWidth;
			o.y = .5 * stage.stageHeight;
			o.initialize();
			o.text = text;
			return o;
		}
		
	}

}