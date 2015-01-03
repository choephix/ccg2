package duel.display.utils 
{
	import chimichanga.global.utils.Colors;
	/**
	 * ...
	 * @author choephix
	 */
	public class ColorScheme 
	{
		
		private static function r( max:Number, on:Boolean ):Number
		{ return ( on ? Math.random() : .5 ) * max }
		
		// CARDS
		
		public static function getColorForTrap( rand:Boolean= true ):uint
		{ return Colors.fromRGB( .7 + r( 0.2, rand ), .4, .5 + r( 0.3, rand ) ) }
		
		public static function getColorForCreature( rand:Boolean= true ):uint
		{ return Colors.fromRGB( 1, .7 + r( 0.15, rand ), .4 ) }
		
		public static function getColorForCreatureNeedsTribute( rand:Boolean= true ):uint
		{ return Colors.fromRGB( 1, .8 + r( 0.15, rand ), .7 ) }
		
		public static function getColorForCreatureFlippable( rand:Boolean= true ):uint
		{ return Colors.fromRGB( 1, .5 + r( 0.10, rand ), .3 ) }
		
		// FIELDS
		
		public static function getColorForCreatureField():uint
		//{ return Colors.fromRGB( .25, .15, .10 ) }
		//{ return Colors.fromRGB( .10, .14, .25 ) }
		{ return Colors.fromRGB( .20, .12, .08 ) }
		
		public static function getColorForTrapField():uint
		//{ return Colors.fromRGB( .25, .10, .20 ) }
		//{ return Colors.fromRGB( .20, .07, .11 ) }
		{ return Colors.fromRGB( .12, .08, .23 ) }
		
		public static function getColorForDeckField():uint
		{ return 0x222222 }
		
		public static function getColorForGraveField():uint
		{ return Colors.fromRGB( .12, .08, .19 ) }
		
	}

}