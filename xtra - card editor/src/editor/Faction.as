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
		public static const NEUTRAL:Faction = new Faction();
		
		//
		public static function toName( f:Faction ):String
		{
			if ( f == SCIENCE ) return "Tech";
			if ( f == NATURE ) return "Natural";
			if ( f == MAGIC ) return "Mystic";
			if ( f == NEUTRAL ) return "Neutral";
			return "N/A";
		}
		
		public static function toColor( f:Faction ):uint
		{
			if ( f == SCIENCE ) return 0x0060F0;
			if ( f == NATURE ) return 0x60F000;
			if ( f == MAGIC ) return 0xF00060;
			if ( f == NEUTRAL ) return 0x222222;
			return 0xFFFFFF;
		}
		
		public static function toInt( f:Faction ):int
		{
			if ( f == SCIENCE ) return 0;
			if ( f == NATURE ) return 1;
			if ( f == MAGIC ) return 2;
			if ( f == NEUTRAL ) return 3;
			return 4;
		}
		
		//
		static public function fromInt( f:int ):Faction
		{
			if ( f == 0 ) return SCIENCE;
			if ( f == 1 ) return NATURE;
			if ( f == 2 ) return MAGIC;
			if ( f == 3 ) return NEUTRAL;
			return null;
		}
	}
}