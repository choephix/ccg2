package duel.cards
{
	import duel.cards.Card;
	import duel.cards.temp_database.TempCardsDatabase;
	import duel.cards.temp_database.TokenCards;
	
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
			
			if ( id >= 0 )	/// BUILD CARD FROM DATABASE
				TempCardsDatabase.F[ id ]( c );
			else			// BUILD TOKEN CREATURE CARD
				TokenCards.setToTokenCreature( c );
			
			c.initialize();
			return c;
		}
		
		//
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}