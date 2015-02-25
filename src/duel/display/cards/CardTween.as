package duel.display.cards 
{
	import duel.display.CardSprite;
	import starling.animation.IAnimatable;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardTween implements IAnimatable
	{
		public var alpha:Number = 1.0;
		public var x:Number = .0;
		public var y:Number = .0;
		public var rotation:Number = 0.0;
		public var scale:Number = 1.0;
		
		public var dirtyness:Number = 1.0;
		public var subject:CardSprite = null;
		public var enabled:Boolean = true;
		
		public function advanceTime( time:Number ):void 
		{
			if ( !enabled ) return;
			if ( dirtyness < Number.MIN_VALUE ) return;
			
			if ( dirtyness < .02 )
			{
				subject.alpha = alpha;
				subject.x = x;
				subject.y = y;
				subject.rotation = rotation;
				subject.scaleX = scale;
				subject.scaleY = scale;
				dirtyness = 0.0;
				return;
			}
			
			dirtyness *= .90; 
			subject.alpha = lerp( subject.alpha, alpha, .17 );
			subject.x = lerp( subject.x, x, .15 );
			subject.y = lerp( subject.y, y, .30 );
			subject.rotation = lerp( subject.rotation, rotation, .25 );
			subject.scaleX = lerp( subject.scaleX, scale, .16 );
			subject.scaleY = lerp( subject.scaleY, scale, .22 );
		}
		
		public function to( x:Number, y:Number, rotation:Number = NaN, scale:Number = NaN ):void
		{
			this.x = x;
			this.y = y;
			
			if ( !isNaN( rotation ) )
				this.rotation = rotation;
			
			if ( !isNaN( scale ) )
				this.scale = scale;
			
			this.dirtyness = 1.0;
			this.enabled = true;
		}
		
		/** Returns interlpolated value between two other. **/
		public static function lerp( a:Number, b:Number, r:Number ):Number
		{ return a + r * ( b - a ) }
	}
}

//class TargetProps
//{
	//public var x:Number;
	//public var y:Number;
	//public var scale:Number;
	//public var rotation:Number;
//}