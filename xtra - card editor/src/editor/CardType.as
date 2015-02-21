package editor 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class CardType 
	{
		public static const CREATURE_NORMAL:int = 1;
		public static const CREATURE_FLIPPABLE:int = 2;
		public static const CREATURE_GRAND:int = 3;
		public static const TRAP_NORMAL:int = 4;
		public static const TRAP_PERSISTENT:int = 5;
		
		public static function toColor( type:int ):uint
		{
			if ( type == CREATURE_NORMAL ) return 0xCC9966;
			if ( type == CREATURE_FLIPPABLE ) return 0xCC6644;
			if ( type == CREATURE_GRAND ) return 0xEECC66;
			if ( type == TRAP_NORMAL ) return 0x52A087;
			if ( type == TRAP_PERSISTENT ) return 0x52959F;
			return 0xFFFFFF;
		}
		
		static public function toInt( type:int ):int 
		{
			return type;
		}
		
		static public function fromInt( type:int ):int
		{
			return type;
		}
		
		static public function isTrap( type:int ):Boolean 
		{ return type == TRAP_NORMAL || type == TRAP_PERSISTENT }
		
		static public function isCreature( type:int ):Boolean 
		{ return !isTrap( type ) }
	}
}