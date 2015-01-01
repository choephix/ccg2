package duel.cards.temp_database 
{
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.behaviour.TrapCardBehaviour;
	import duel.cards.Card;
	import duel.cards.CardType;
	import duel.Game;
	/**
	 * ...
	 * @author choephix
	 */
	public class TempDatabaseUtils 
	{
		
		public static function setToCreature( c:Card ):void
		{
			c.type = CardType.CREATURE;
			c.behaviour = new CreatureCardBehaviour();
		}
			
		public static function setToTrap( c:Card ):void
		{
			c.type = CardType.TRAP;
			c.behaviour = new TrapCardBehaviour();
		}
		
		// PROCESSES
		
		public static function doKill( c:Card ):void
		{
			Game.current.processes.prepend_Death( c );
		}
		
	}

}