package chimichanga.common.display.positioning {
	import flash.display.GraphicsTrianglePath;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	
	public class Positioner 
	{
		private var mBounds:Rectangle;
		
		public function Positioner( xLeft:Number, xRight:Number, yTop:Number, yBottom:Number )
		{
			mBounds = new Rectangle();
			setTo( xLeft, xRight, yTop, yBottom );
		}
		
		public function setTo( xLeft:Number, xRight:Number, yTop:Number, yBottom:Number ):void 
		{
			mBounds.setTo( xLeft, yTop, xRight-xLeft, yBottom-yTop );
		}
		
		public function positionAtRatios( target:DisplayObject, xRatio:Number = 0.5, yRatio:Number = 0.5 ):void
		{
			positionAtRatioX( target, xRatio );
			positionAtRatioY( target, yRatio );
		}
		
		public function positionAtRatioX( target:DisplayObject, xRatio:Number = 0.5 ):Number
		{
			return target.x = left + target.pivotX + ( width - target.width ) * xRatio;
		}
		
		public function positionAtRatioY( target:DisplayObject, yRatio:Number = 0.5 ):Number
		{
			return target.y = top + target.pivotY + ( height - target.height ) * yRatio;
		}
		
		public function getXAtRatio( xRatio:Number ):Number
		{
			return left + width * xRatio;
		}
		
		public function getYAtRatio( yRatio:Number ):Number
		{
			return top + height * yRatio;
		}
		
		// ACCESSORS
		
		public function get centerX():Number { 	return mBounds.left + mBounds.width * 0.5; }
		public function get centerY():Number { 	return mBounds.top + mBounds.height * 0.5; }
		
		public function get width():Number { 	return mBounds.width; }
		public function get height():Number { 	return mBounds.height; }
		
		public function get left():Number { 	return mBounds.left; }
		public function get top():Number { 		return mBounds.top; }
		public function get right():Number { 	return mBounds.right; }
		public function get bottom():Number { 	return mBounds.bottom; }
		
		public function get topLeft():Point { return mBounds.topLeft; }
		public function get bottomRight():Point { return mBounds.bottomRight; }
		
		// STATIC
		
		public static function fromObjectBounds( target:DisplayObject, paddingX:Number = 0.0, paddingY:Number = 0.0 ):Positioner
		{
			var rect:Rectangle = target.bounds;
			return new Positioner( rect.left + paddingX, rect.right - paddingX, rect.top + paddingY, rect.bottom - paddingY );
		}
		
	}

}