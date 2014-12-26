package duel.table 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class FieldType 
	{
		public static const CREATURE:FieldType	= new FieldType();
		public static const TRAP:FieldType		= new FieldType();
		public static const DECK:FieldType		= new FieldType();
		public static const GRAVEYARD:FieldType	= new FieldType();
		public static const UNKNOWN:FieldType	= new FieldType();
		
		public function toString():String {
			switch( this ) {
				case CREATURE : 	return "CREATURE"; break;
				case TRAP : 		return "TRAP"; break;
				case DECK : 		return "DECK"; break;
				case GRAVEYARD : 	return "GRAVEYARD"; break;
				case UNKNOWN : 		return "UNKNOWN"; break;
			}
			return null+"?";
		}
		
		public function get isCreatureField():Boolean 	{ return this == FieldType.CREATURE }
		public function get isTrapField():Boolean 		{ return this == FieldType.TRAP }
		public function get isDeck():Boolean 			{ return this == FieldType.DECK }
		public function get isGraveyard():Boolean 		{ return this == FieldType.GRAVEYARD }
	}

}