package duel.display 
{
	import chimichanga.common.display.Sprite;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldSpriteOverTip extends Sprite 
	{
		private var t:TextField;
		
		public function FieldSpriteOverTip() 
		{
			super();
			
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