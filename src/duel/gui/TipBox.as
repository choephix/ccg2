package duel.gui
{
	import duel.GameSprite;
	import starling.animation.IAnimatable;
	import starling.display.Quad;
	import starling.text.TextField;
	
	
	public class TipBox extends GameSprite implements IAnimatable
	{
		private var q:Quad;
		private var t:TextField;
		
		private var _visible:Boolean;
		
		public function TipBox( width:Number, height:Number )
		{
			q = new Quad( width, height, 0x88CCFF );
			q.alignPivot();
			q.alpha = .70;
			addChild( q );
			
			t = new TextField( q.width, q.height, "?" );
			t.format.font = "Calibri";
			t.format.size = 32;
			t.format.color = 0x0;
			t.format.bold = true;
			t.autoScale = true;
			t.alignPivot();
			addChild( t );
			
			alpha = .0;
		}
		
		public function advanceTime(time:Number):void 
		{
			alpha = lerp( alpha, _visible ? 1.0 : 0.0, .167 )
		}
		
		public function get color():uint
		{
			return q.color;
		}
		
		public function set color( value:uint ):void
		{
			q.color = value;
		}
		
		public function get textColor():uint
		{
			return t.format.color;
		}
		
		public function set textColor( value:uint ):void
		{
			t.format.color = value;
		}
		
		public function get text():String
		{
			return t.text;
		}
		
		public function set text( value:String ):void
		{
			t.text = value;
		}
		
		override public function get visible():Boolean
		{
			return _visible;
		}
		
		override public function set visible( value:Boolean ):void
		{
			_visible = value;
		}
		
		override public function get width():Number
		{
			return q.width;
		}
		
		override public function set width( value:Number ):void
		{
			q.width = value;
		}
		
		override public function get height():Number
		{
			return q.height;
		}
		
		override public function set height( value:Number ):void
		{
			q.height = value;
		}
	
	}

}