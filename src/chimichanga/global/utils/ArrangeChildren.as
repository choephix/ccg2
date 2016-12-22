package chimichanga.global.utils 
{
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	public class ArrangeChildren 
	{
		public static function verticallyOnePerLine( parent:DisplayObjectContainer, spacing:Number = 0.0, vAlign:String="top" ):void
		{
			var o:DisplayObject;
			var currentY:Number = 0.0;
			for ( var i:int = 0, iMax:int = parent.numChildren; i < iMax; i++ )
			{
				o = parent.getChildAt(i);
				o.x = o.pivotX;
				o.y = o.pivotY + currentY;
				currentY += o.height + spacing;
			}
			switch( vAlign )
			{
				case "top":		parent.pivotY = 0.0; break;
				case "bottom":	parent.pivotY = currentY; break;
				case "center":	parent.pivotY = currentY * 0.5; break;
			}
		}
		
		public static function horisontallyOnePerColumn( parent:DisplayObjectContainer, spacing:Number = 0.0, hAlign:String="left" ):void
		{
			var o:DisplayObject;
			var currentX:Number = 0.0;
			for ( var i:int = 0, iMax:int = parent.numChildren; i < iMax; i++ )
			{
				o = parent.getChildAt(i);
				o.x = o.pivotX + currentX;
				o.y = o.pivotY;
				currentX += o.width + spacing;
			}
			switch( hAlign )
			{
				case "left":	parent.pivotX = 0.0; break;
				case "right":	parent.pivotX = currentX; break;
				case "center":	parent.pivotX = currentX * 0.5; break;
			}
		}
		
		public static function asList( parent:DisplayObjectContainer, widthMax:Number, spacingX:Number = 0.0, spacingY:Number = 0.0, hAlign:String="left", vAlign:String="top" ):void
		{
			var o:DisplayObject;
			var currentX:Number = 0.0;
			var currentY:Number = 0.0;
			var lineHeight:Number = 0.0;
			for ( var i:int = 0, iMax:int = parent.numChildren; i < iMax; i++ )
			{
				o = parent.getChildAt(i);
				if ( currentX + o.width > widthMax )
				{
					currentY += lineHeight + spacingY;
					currentX = 0.0;
					lineHeight = 0.0;
				}
				o.x = o.pivotX + currentX;
				o.y = o.pivotY + currentY;
				currentX += o.width + spacingX;
				if ( lineHeight < o.height )
					lineHeight = o.height;
			}
		}
		
	}
}