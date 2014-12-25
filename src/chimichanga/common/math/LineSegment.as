package chimichanga.common.math
{
	
	/**
	 * ...
	 * @author choephix
	 */
	public class LineSegment
	{
		private var a:Vector2D;
		private var b:Vector2D;
		
		public function LineSegment( a:Vector2D = null, b:Vector2D = null )
		{
			this.a = a == null ? new Vector2D() : a;
			this.b = b == null ? new Vector2D() : b;
		}
		
		public function setTo( aX:Number, aY:Number, bX:Number, bY:Number ):void
		{
			a.x = aX;
			a.y = aY;
			b.x = bX;
			b.y = bY;
		}
		
		/// STATIC
		
	}

}