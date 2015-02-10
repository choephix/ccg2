package editor 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class SortFunctions 
	{
		
		public static function byType( a:Card, b:Card ):int
		{
			if ( a.data.type == b.data.type )
				return byPower( a, b );
			
			return a.data.type - b.data.type;
		}
		
		public static function byFaction( a:Card, b:Card ):int
		{
			if ( a.data.faction == b.data.faction )
				return byType( a, b );
			
			return Faction.toInt( a.data.faction ) - Faction.toInt( b.data.faction );
		}
		
		public static function byPower( a:Card, b:Card ):int
		{
			return a.data.power - b.data.power;
		}
	}

}