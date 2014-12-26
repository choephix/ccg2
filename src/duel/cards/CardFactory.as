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
			c.type = Math.random() < .67 ? CardType.CREATURE : CardType.TRAP;
			
			if ( c.type == CardType.CREATURE )
			{
				var b:CreatureCardBehaviour = new CreatureCardBehaviour();
				b.attack = 10 + Math.random() * 10;
				b.startFaceDown = Math.random() < .27;
				c.behaviour = b;
				c.name = "Creature "+uid+"";
				//c.name = "#" + uid + " Creature";
			}
			else
			if ( c.type == CardType.TRAP )
			{
				c.behaviour = new TrapCardBehaviour();
				c.name = "Trap "+uid+"";
				//c.name = "#" + uid + " Trap";
			}
			
			//
			
			c.initialize();
			return c;
		}
		
	}

}