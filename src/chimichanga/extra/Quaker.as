package chimichanga.extra 
{
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	/**
	 * ...
	 * @author ...
	 */
	public class Quaker implements IAnimatable
	{
		private var target:DisplayObject;
		private var originalX:Number;
		private var originalY:Number;
		
		public var magX:Number = .0;
		public var magY:Number = .0;
		public var maxMagX:Number = 10.0;
		public var maxMagY:Number = 10.0;
		public var minMagX:Number = 1.0;
		public var minMagY:Number = 1.0;
		public var damper:Number = .98;
		
		public function Quaker( target:DisplayObject ) 
		{
			setTarget( target );
		}
		
		public function advanceTime(time:Number):void 
		{
			if ( magX > Number.MIN_VALUE )
			{
				target.x = originalX + ( 2.0 * Math.random() - 1.0 ) * magX;
				magX = magX < minMagX ? 0.0 : magX * damper;
			}
			if ( magY > Number.MIN_VALUE )
			{
				target.y = originalY + ( 2.0 * Math.random() - 1.0 ) * magY;
				magY = magY < minMagY ? 0.0 : magY * damper;
			}
		}
		
		private function setTarget(target:DisplayObject):void 
		{
			this.target = target;
			this.originalX = target.x;
			this.originalY = target.y;
		}
		
		public function quake( magX:Number, magY:Number = NaN ):void
		{
			if ( isNaN( magY ) )
				magY = magX;
			
			this.magX = Math.max( maxMagX, this.magX + magX );
			this.magY = Math.max( maxMagY, this.magY + magY );
		}
		
	}

}