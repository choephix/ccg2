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
		public static const TRAP:int = 4;
		
		public static function toColor( type:int ):uint
		{
			if ( type == TRAP ) return 0x52A087;
			if ( type == CREATURE_NORMAL ) return 0xCC9966;
			if ( type == CREATURE_FLIPPABLE ) return 0xCC6644;
			if ( type == CREATURE_GRAND ) return 0xEECC66;
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
	}
}