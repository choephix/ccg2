package duel.cards
{
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.behaviour.TrapCardBehaviour;
	import duel.cards.Card;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardFactory
	{
		private static var uid:uint = 0;
		
		
		public static function produceCard( id:int ):Card
		{
			uid++;
			
			var c:Card = new Card();
			
			//
			c.id = id;
			c.name = "Spatula #"+uid;
			c.type = Math.random() < .67 ? CardType.CREATURE : CardType.TRAP;
			
			if ( c.type == CardType.CREATURE )
			{
				c.behaviour = new CreatureCardBehaviour();
			}
			else
			if ( c.type == CardType.TRAP )
			{
				c.behaviour = new TrapCardBehaviour();
			}
			
			//
			
			c.initialize();
			return c;
		}
		
	}

}