package duel.display 
{
	import chimichanga.common.display.Sprite;
	import starling.display.Quad;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldSpriteOverTip extends Sprite 
	{
		private const Q_PADDING:Number = 4;
		private var q:Quad;
		private var q1:Quad;
		private var t:TextField;
		
		public function FieldSpriteOverTip() 
		{
			super();
			
			q = new Quad( 1, 1, 0x0 );
			q.alignPivot();
			q.width  = 96;
			q.height = 96;
			q.alpha = .40;
			q.touchable = false;
			addChild( q );
			
			q1 = new Quad( 1, 1, 0x0 );
			q1.alignPivot();
			q1.width  = 100;
			q1.height = 100;
			q1.alpha = .40;
			q1.touchable = false;
			addChild( q1 );
			
			t = new TextField( 500, 500, "", "Arial", 18, 0xFFFFFF, false );
			t.alignPivot();
			t.hAlign = "center";
			t.vAlign = "center";
			t.touchable = false;
			addChild( t );
		}
		
		public function get color():uint 
		{
			return t.color;
		}
		
		public function set color(value:uint):void 
		{
			t.color = value;
		}
		
		public function get text():String 
		{
			return t.text;
		}
		
		public function set text(value:String):void 
		{
			t.text = value;
		}
		
	}

}