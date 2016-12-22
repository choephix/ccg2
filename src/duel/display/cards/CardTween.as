package duel.display.cards 
{
	import duel.display.cards.CardSprite;
	import starling.animation.IAnimatable;
	
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
		
		private var _zJumpMax:Number = 0.0;
		private var _zJump:Number;
		
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
			
			_zJump = isNaN( _zJumpMax ) ? 0.0 : _zJumpMax * Math.sin( dirtyness * dirtyness * dirtyness * Math.PI );
			
			dirtyness *= .90; 
			subject.alpha = lerp( subject.alpha, alpha, .17 );
			subject.x = lerp( subject.x, x, .15 );
			subject.y = lerp( subject.y, y, .30 ) - _zJump * 180;
			subject.rotation = lerp( subject.rotation, rotation, .25 );
			subject.scaleX = lerp( subject.scaleX, scale, .19 ) + _zJump;
			subject.scaleY = lerp( subject.scaleY, scale, .22 ) + _zJump;
		}
		
		public function to( x:Number, y:Number, rotation:Number = NaN, scale:Number = NaN, zJump:Number = NaN ):void
		{
			this.x = x;
			this.y = y;
			
			if ( !isNaN( rotation ) )
				this.rotation = rotation;
			
			if ( !isNaN( scale ) )
				this.scale = scale;
			
			_zJumpMax = zJump * .1;
			
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