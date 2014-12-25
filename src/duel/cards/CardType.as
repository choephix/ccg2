package duel.cards 
{
	import chimichanga.global.utils.Colors;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardType 
	{
		public static const CREATURE:CardType = new CardType();
		public static const TRAP:CardType = new CardType();
		
		//
		
		public function get name():String 
		{
			if ( this == CREATURE ) 	return "{C}";
			if ( this == TRAP ) 		return "{T}";
			return "{?}";
		}
		public function get color():uint 
		{
			if ( this == CREATURE ) 	return Colors.fromRGB( 1, .7+Math.random()*0.2, .4 );
			if ( this == TRAP ) 		return Colors.fromRGB( 1, .3, .3+Math.random()*0.2 );
			return 0xFFFFFF;
		}
	}
}