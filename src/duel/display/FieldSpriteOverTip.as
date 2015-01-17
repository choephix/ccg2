package duel.display 
{
	import chimichanga.common.display.Sprite;
	import duel.GameSprite;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldSpriteOverTip extends GameSprite 
	{
		private const Q_PADDING:Number = 4;
		private var q:Quad;
		private var q1:Quad;
		private var t:TextField;
		
		private var btn:Button;
		
		public function FieldSpriteOverTip() 
		{
			super();
			
			btn = new Button( assets.getTexture( "btn" ), "" );
			btn.fontColor = color;
			btn.fontBold = true;
			btn.alignPivot();
			btn.touchable = false;
			addChild( btn );
		}
		
		public function get color():uint 
		{
			return btn.fontColor;
		}
		
		public function set color(value:uint):void 
		{
			btn.fontColor = value;
		}
		
		public function get text():String 
		{
			return btn.text;
		}
		
		public function set text(value:String):void 
		{
			btn.text = value;
		}
		
	}

}