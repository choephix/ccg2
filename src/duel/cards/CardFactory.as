package duel.cards
{
	import duel.cards.Card;
	import duel.cards.temp_database.TempDatabasePack1;
	import duel.cards.temp_database.TempDatabasePack2;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardFactory
	{
		static private var uid:uint = 0;
		
		public static function produceCard( id:int ):Card
		{
			uid++;
			
			var c:Card = new Card();
			
			c.id = id;
			
			if ( id >= 1000 )
				TempDatabasePack2.F[ id - 1000 ]( c );
			else
				TempDatabasePack1.F[ id ]( c );
			
			c.initialize();
			return c;
		}
		
		//
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}