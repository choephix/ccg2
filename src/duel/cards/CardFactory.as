package duel.cards
{
	import duel.cards.Card;
	import duel.cards.temp_database.TempCardsDatabase;
	
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
				setToTokenCreature( c );
			
			c.initialize();
			return c;
		}
		
		static private function setToTokenCreature(c:Card):void 
		{
			setToCreature( c );
			c.behaviourC.attack = 0;
		}
		
		//
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}