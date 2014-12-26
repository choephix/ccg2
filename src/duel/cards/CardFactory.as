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
			c.type = chance( .67 ) ? CardType.CREATURE : CardType.TRAP;
			
			if ( c.type == CardType.CREATURE )
			{
				var b:CreatureCardBehaviour = new CreatureCardBehaviour();
				// true false
				b.haste		= chance( .3 );
				b.defender	= chance( .1 );
				b.immobile	= chance( .1 );
				b.swift		= chance( .1 );
				b.berserk	= chance( .2 );
				//
				b.attack = 10 + Math.random() * 10;
				b.startFaceDown = chance( .27 );
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
		
		private static function chance( value:Number ):Boolean { return Math.random() < value }
	}

}