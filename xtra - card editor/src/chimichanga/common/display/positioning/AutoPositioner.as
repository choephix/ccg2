package chimichanga.common.display.positioning {
	import flash.display.GraphicsTrianglePath;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	/**
	 * ...
	 * @author choephix
	 */
	public class AutoPositioner 
	{
		private var mBounds:Rectangle;
		private var mSubjects:Vector.<TargetPositionPair>;
		private var mSubjectsCount:int = 0;
		
		public function AutoPositioner( xLeft:Number, xRight:Number, yTop:Number, yBottom:Number )
		{
			mBounds = new Rectangle();
			mSubjects = new Vector.<TargetPositionPair>();
			setTo( xLeft, xRight, yTop, yBottom );
		}
		
		public function setTo( xLeft:Number, xRight:Number, yTop:Number, yBottom:Number ):void 
		{
			mBounds.setTo( xLeft, yTop, xRight - xLeft, yBottom - yTop );
			updateSubjects();
		}
		
		public function registerSubject( subject:DisplayObject, xRatio:Number = 0.5, yRatio:Number = 0.5, xOffset:Number = 0.0, yOffset:Number = 0.0 ):void
		{
			var o:TargetPositionPair = new TargetPositionPair( subject, xRatio, yRatio, xOffset, yOffset );
			mSubjectsCount = mSubjects.push( o );
			updateSubject( o );
		}
		
		private function updateSubject( o:TargetPositionPair ):void 
		{
			o.subject.x = o.xOffset + left + o.subject.pivotX + ( width - o.subject.width ) * o.xRatio;
			o.subject.y = o.yOffset + top + o.subject.pivotY + ( height - o.subject.height ) * o.yRatio;
		}
		
		public function getXAtRatio( xRatio:Number ):Number
		{
			return left + width * xRatio;
		}
		
		public function getYAtRatio( yRatio:Number ):Number
		{
			return top + height * yRatio;
		}
		
		public function updateSubjects():void {
			for (var i:int = 0; i < mSubjectsCount; i++) 
				updateSubject( mSubjects[ i ] );
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
		
		public static function fromObjectBounds( target:DisplayObject, paddingX:Number = 0.0, paddingY:Number = 0.0 ):AutoPositioner
		{
			var rect:Rectangle = target.bounds;
			return new AutoPositioner( rect.left + paddingX, rect.right - paddingX, rect.top + paddingY, rect.bottom - paddingY );
		}
		
	}

}

import starling.display.DisplayObject;

class TargetPositionPair
{
	public var subject:DisplayObject;
	public var xRatio:Number;
	public var yRatio:Number;
	public var xOffset:Number;
	public var yOffset:Number;
	public function TargetPositionPair( target:DisplayObject, xRatio:Number = 0.5, yRatio:Number = 0.5, xOffset:Number = 0.0, yOffset:Number = 0.0 )
	{
		this.subject = target;
		this.xRatio = xRatio;
		this.yRatio = yRatio;
		this.xOffset = xOffset;
		this.yOffset = yOffset;
	}
}



