package dev 
{
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	/**
	 * ...
	 * @author ...
	 */
	public class Debug 
	{
		
		public static var publicArray:Array = new Array();
		
		
		public static function markSpot( container:DisplayObjectContainer, x:Number, y:Number, color:uint = 0xCCFF00, time:Number = NaN ):Quad
		{
			var q:Quad = new Quad( 8, 8, color );
			q.alignPivot();
			q.rotation = Math.PI * .25;
			q.x = x;
			q.y = y;
			container.addChild( q );
			
			if ( !isNaN( time ) )
			{
				Starling.juggler.tween( q, time,
					{
						alpha : 0.0,
						transition : Transitions.EASE_IN,
						onComplete : q.removeFromParent,
						onCompleteArgs : [true]
					} );
			}
			
			return q;
		}
		
		
		public static function markArea( container:DisplayObjectContainer, x1:Number, y1:Number, x2:Number, y2:Number, color:uint = 0xCCFF00, time:Number = NaN ):Quad
		{
			var q:Quad;
			if ( x1 < x2 )
			{
				q = new Quad( x2 - x1, y2 - y1, color );
				q.x = x1;
				q.y = y1;
			}
			else
			{
				q = new Quad( x1 - x2, y1 - y2, color );
				q.x = x2;
				q.y = y2;
			}
			container.addChild( q );
			
			if ( !isNaN( time ) )
			{
				Starling.juggler.tween( q, time,
					{
						alpha : 0.0,
						transition : Transitions.EASE_IN,
						onComplete : q.removeFromParent,
						onCompleteArgs : [true]
					} );
			}
			
			return q;
		}
		
	}

}