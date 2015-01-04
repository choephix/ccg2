package duel.table 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class CardLotType 
	{
		public static const CREATURE_FIELD:CardLotType	= new CardLotType();
		public static const TRAP_FIELD:CardLotType		= new CardLotType();
		public static const DECK:CardLotType			= new CardLotType();
		public static const HAND:CardLotType			= new CardLotType();
		public static const GRAVEYARD:CardLotType		= new CardLotType();
		public static const UNKNOWN:CardLotType			= new CardLotType();
		
		public function toString():String {
			switch( this ) {
				case CREATURE_FIELD : 	return "CREATURE FIELD"; break;
				case TRAP_FIELD : 		return "TRAP FIELD"; break;
				case DECK : 			return "DECK"; break;
				case GRAVEYARD : 		return "GRAVEYARD"; break;
				case HAND : 			return "HAND"; break;
			}
			return "?";
		}
		
		public function get isCreatureField():Boolean 	{ return this == CardLotType.CREATURE_FIELD }
		public function get isTrapField():Boolean 		{ return this == CardLotType.TRAP_FIELD }
		public function get isDeck():Boolean 			{ return this == CardLotType.DECK }
		public function get isGraveyard():Boolean 		{ return this == CardLotType.GRAVEYARD }
		public function get isHand():Boolean 			{ return this == CardLotType.HAND }
	}

}