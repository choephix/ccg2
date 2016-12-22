package chimichanga.global.utils
{
	import starling.errors.AbstractClassError;
	
	
	public class MathF
	{
		
		public static const PI:Number	= Math.PI;
		public static const PI2:Number	= Math.PI * 2.0;
		
        /** @private */
        public function MathF() { throw new AbstractClassError(); }
		
		//{ RANDOM
		
		/** Get a random number between 0 <= value < 1.0 **/
		public static function get rand():Number
		{
			return Math.random();
		}
		
		/** Returns either 1.0 or -1.0, chosen at random **/
		public static function get randSign():Number
		{
			return rand >= 0.5 ? 1.0 : -1.0;
		}
		
		/** Get a random number between min and max
		 * @param	max inclusive
		 * @param	min exclusive
		 * @return	random number between min and max
		 */
		public static function random( max:Number = 1.0, min:Number = 0.0 ):Number
		{
			return min + rand * ( max - min );
		}
		
		/** Get a random integer between min (incl) and max (incl)
		 * @param	min inclusive
		 * @param	max inclusive
		 * @return	random integer between min (incl) and max (incl)
		 */
		public static function randomInt( max:Number = 1, min:Number = 0 ):int
		{
			return min + rand * ( max - min + 1 );
		}
		
		/** Returns true or false, determined at random from chance, specified from 0 to 1
		 * (0 for always false, 1 for always true) **/
		public static function chance( percent:Number ):Boolean
		{
			return rand * 100 <= percent;
		}
		
		//}
		
		//{ 1D
		
		/** Returns the value clipped between min and max. **/
		public static function clip( value:Number, max:Number = 1.0, min:Number = 0.0 ):Number
		{
			if ( value >= max )
				return max;
			if ( value <= min )
				return min;
			return value;
		}
		
		/** Returns interlpolated value between two other. **/
		public static function lerp( from:Number, to:Number, ratio:Number ):Number
		{
			return from + ratio * ( to - from );
		}
		
		static public function sum( a:Array ):Number 
		{
			var r:Number = 0.0;
			for ( var i:int = 0, iMax:int = a.length; i < iMax; i++ ) 
			{
				r += a[i];
			}
			return r;
		}
		
		//}
		
		//{ 2D
		
		/** Determine the distance between (ax,ay) and (bx,by) without the Point class. **/
		public static function getDistance2D( ax:Number, ay:Number, bx:Number, by:Number ):Number
		{
			var deltaX:Number = Math.abs( bx - ax );
			var deltaY:Number = Math.abs( by - ay );
			return Math.sqrt( deltaX * deltaX + deltaY * deltaY );
		}
		
		/** Determine whether the distance between (ax,ay) and (bx,by) is within the specified range.
		 * Using this function should be faster than calculating the actual distance and comparing
		 * it to the range value (skips using the sqrt function). */
		public static function isInRange2D( ax:Number, ay:Number, bx:Number, by:Number, range:Number ):Boolean
		{
			var deltaX:Number = Math.abs( bx - ax );
			var deltaY:Number = Math.abs( by - ay );
			return deltaX * deltaX + deltaY * deltaY <= range * range;
		}
		
		//}
		
	}

}