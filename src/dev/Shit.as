package dev 
{
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	/**
	 * ...
	 * @author choephix
	 */
	public class Shit 
	{
		
		public static function mark( o:DisplayObjectContainer, x:Number, y:Number ) 
		{
			var q:Quad;
			q = new Quad( 40, 40, 0xFF0000 );
			q.alignPivot();
			q.x = x;
			q.y = y;
			q.alpha = .25;
			o.addChild( q );
			q = new Quad( 4, 4, 0xFFFF00 );
			q.alignPivot();
			q.x = x;
			q.y = y;
			q.alpha = .5;
			o.addChild( q );
		}
		
	}

}