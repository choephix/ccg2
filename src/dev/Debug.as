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
		
		
		public static function markDOContainer( container:DisplayObjectContainer, x:Number, y:Number, color:uint = 0xCCFF00, time:Number = NaN ):Quad
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
		
	}

}