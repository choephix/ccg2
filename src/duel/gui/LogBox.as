package duel.gui 
{
	import chimichanga.common.display.Sprite;
	import starling.display.Quad;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class LogBox extends Sprite 
	{
		private var quad:Quad;
		private var t:TextField;
		
		private var lines:Array = [];
		private var linesMax:int = 20;
		private var fontSize:int = 13;
		
		public function LogBox() 
		{
			super();
			
			quad = new Quad( 1, 1, 0x000411 );
			quad.alpha = .6;
			addChild( quad );
			
			t = new TextField( 1, 1, "", "Consolas", fontSize, 0x0099CC, false );
			t.hAlign = "left";
			t.vAlign = "top";
			t.touchable = false;
			addChild( t );
			
			addEventListener( TouchEvent.TOUCH, onTouch );
		}
		
		private function onTouch(e:TouchEvent):void 
		{ alpha = e.getTouch( quad ) == null ? 1.0 : .0 }
		
		public function log( s:String ):void
		{
			lines.unshift( s );
			if ( lines.length > linesMax )
				lines.length = linesMax;
			t.text = lines.join( "\n" );
		}
		
		override public function get width():Number 
		{
			return quad.width;
		}
		
		override public function set width(value:Number):void 
		{
			quad.width = value;
			t.width = value;
		}
		
		override public function get height():Number 
		{
			return quad.height;
		}
		
		override public function set height(value:Number):void 
		{
			quad.height = value;
			t.height = value;
			linesMax = Math.ceil( value / fontSize );
		}
		
	}

}