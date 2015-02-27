package editor 
{
	import flash.globalization.Collator;
	import flash.globalization.CollatorMode;
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
			
			return CardType.toInt( b.data.type ) - CardType.toInt( a.data.type );
		}
		
		public static function byFaction( a:Card, b:Card ):int
		{
			if ( a.data.faction == b.data.faction )
				return byType( a, b );
			
			return Faction.toInt( a.data.faction ) - Faction.toInt( b.data.faction );
		}
		
		public static function byPower( a:Card, b:Card ):int
		{
			if ( a.data.type == CardType.TRAP_NORMAL ) return -1;
			if ( b.data.type == CardType.TRAP_NORMAL ) return  1;
			return a.data.power - b.data.power;
		}
		
		public static function byStars( a:Card, b:Card ):int
		{
			return a.data.stars - b.data.stars;
		}
		
		public static function byPriority( a:Card, b:Card ):int
		{
			return a.data.priority - b.data.priority;
		}
		
		public static function bySlug( a:Card, b:Card ):int
		{
			var sorter:Collator = new Collator( "fr-FR", CollatorMode.SORTING );
			return sorter.compare( b.data.slug, a.data.slug );
		}
		
		public static function byName( a:Card, b:Card ):int
		{
			var sorter:Collator = new Collator( "fr-FR", CollatorMode.SORTING );
			return sorter.compare( b.data.name, a.data.name );
		}
		
		public static function byID( a:Card, b:Card ):int
		{
			return a.data.id - b.data.id;
		}
		
		public static function byRandom( a:Card, b:Card ):int
		{
			return Math.random() >= .5 ? -1 : 1;
		}
	}

}