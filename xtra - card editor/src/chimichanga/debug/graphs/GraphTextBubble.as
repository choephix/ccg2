package chimichanga.debug.graphs
{
	import chimichanga.common.display.LinearGradientQuad;
	import flash.text.TextFieldAutoSize;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class GraphTextBubble extends Sprite
	{
		
		private var _background:LinearGradientQuad;
		private var _textfield:TextField;
		
		public function GraphTextBubble( width:Number = 250, height:Number = 100 )
		{
			super();
			
			_background = new LinearGradientQuad( 0x000022, 0x001133, 0.75, 0.5 );
			_background.width = width;
			_background.height = height;
			addChild( _background );
			
			_textfield = new TextField( _background.width, _background.height, "", "Consolas", 13, 0xBbDdFf, true );
			_textfield.hAlign = HAlign.LEFT;
			_textfield.vAlign = VAlign.TOP;
			_textfield.autoSize = TextFieldAutoSize.LEFT;
			addChild( _textfield );
			
			touchable = false;
		}
		
		public function set color( value:uint ):void
		{
			_background.color1 = value;
			_background.color2 = value;
		}
		
		public function get color():uint
		{
			return _background.color1;
		}
		
		public function set text( value:String ):void
		{
			_textfield.text = value;
			_textfield.height = Math.max( _textfield.textBounds.height + 10.0, 100 );
			_background.width = _textfield.width;
			_background.height = _textfield.height;
		}
		
		public function get text():String
		{
			return _textfield.text;
		}
	
	}

}