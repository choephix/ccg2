package chimichanga.global.utils
{
	import starling.errors.AbstractClassError;
	
	
	public class Arrays
	{
		
		/** @private */
		public function Arrays() { throw new AbstractClassError(); }
		
		public static function randomElement( a:Array ):Object
		{
			return a[ MathF.randomInt( 0, a.length ) ];
		}
		
		public static function shuffle( a:Array ):void
		{
			a.sort( compareRandomly );
		}
		
		private static function compareRandomly( a:*, b:* ):int
		{
			return ( Math.random() >= 0.5 ) ? 1 : -1;
		}
	
	}

}