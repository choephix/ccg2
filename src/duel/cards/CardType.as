package duel.cards 
{
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
		
		public function get isCreature():Boolean { return this == CREATURE }
		public function get isTrap():Boolean { return this == TRAP }
	}
}