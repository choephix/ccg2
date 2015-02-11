package editor 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class Faction 
	{
		public static const SCIENCE:Faction = new Faction();
		public static const NATURE:Faction 	= new Faction();
		public static const MAGIC:Faction 	= new Faction();
		
		//
		public static function toName( f:Faction ):String
		{
			if ( f == SCIENCE ) return "Tech";
			if ( f == NATURE ) return "Natural";
			if ( f == MAGIC ) return "Mystic";
			return "Neutral";
		}
		
		public static function toColor( f:Faction ):uint
		{
			if ( f == SCIENCE ) return 0x0080FF;
			if ( f == NATURE ) return 0x80FF00;
			if ( f == MAGIC ) return 0xFF0080;
			return 0x999999;
		}
		
		public static function toInt( f:Faction ):int
		{
			if ( f == SCIENCE ) return 0;
			if ( f == NATURE ) return 1;
			if ( f == MAGIC ) return 2;
			return 3;
		}
		
		//
		static public function fromInt( f:int ):Faction
		{
			if ( f == 0 ) return SCIENCE;
			if ( f == 1 ) return NATURE;
			if ( f == 2 ) return MAGIC;
			return null;
		}
	}
}