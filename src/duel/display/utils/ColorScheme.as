package duel.display.utils 
{
	import chimichanga.common.misc.Color;
	import chimichanga.global.utils.Colors;
	/**
	 * ...
	 * @author choephix
	 */
	public class ColorScheme 
	{
		
		private static function _( max:Number, on:Boolean ):Number
		{ return ( on ? Math.random() : .5 ) * max }
		
		// CARDS
		
		public static function getColorForTrap( rand:Boolean= true ):uint
		{ return ra( 0xAD6185, .10, .0, .15, rand ) }
		//{ return ra( 0x808080, .50, .50, .50, rand ) }
		
		public static function getColorForTrapPersistent( rand:Boolean= true ):uint
		{ return ra( 0x7657B7, .10, .0, .15, rand ) }
		//{ return ra( 0x808080, .50, .50, .50, rand ) }
		
		public static function getColorForCreature( rand:Boolean= true ):uint
		{ return ra( 0xEDBA6D, .10, .10, .0, rand ) }
		
		public static function getColorForCreatureNeedsTribute( rand:Boolean= true ):uint
		{ return ra( 0xFCEB8D, .10, .10, .0, rand ) }
		
		public static function getColorForCreatureFlippable( rand:Boolean= true ):uint
		{ return ra( 0xC1684A, .15, .10, .0, rand ) }
		
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
		
		//
		private static var sHelperColor1:Color = new Color();
		private static var sHelperColor2:Color = new Color();
		private static function ra( base:uint, r:Number, g:Number, b:Number, on:Boolean = true ):uint
		{
			sHelperColor1.setHex( base );
			sHelperColor2.setTo( _(r, on), _(g, on), _(b, on) );
			sHelperColor1.add( sHelperColor2 );
			return sHelperColor1.getHex();
		}
	}

}