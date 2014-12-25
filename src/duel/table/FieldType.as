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
		
		public function toString():String {
			switch( this ) {
				case CREATURE : 	return "CREATURE"; break;
				case TRAP : 		return "TRAP"; break;
				case DECK : 		return "DECK"; break;
				case GRAVEYARD : 	return "GRAVEYARD"; break;
			}
			return null+"?";
		}
	}

}