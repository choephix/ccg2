package duel.cards.temp_database 
{
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.behaviour.TrapCardBehaviour;
	import duel.cards.Card;
	import duel.cards.CardType;
	import duel.Game;
	import duel.Player;
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
		
		static public function doDraw( p:Player, count:int ):void 
		{
			Game.current.processes.prepend_Draw( p, count );
		}
		
		static public function doDiscard( p:Player, c:Card ):void 
		{
			Game.current.processes.prepend_Discard( p, c );
		}
		
		static public function doPutToGrave( c:Card ):void
		{
			Game.current.processes.prepend_EnterGrave( c );
		}
		
		static public function doPutInHand( c:Card, p:Player ):void
		{
			Game.current.processes.prepend_EnterHand( c, p );
		}
		
		static public function doForceAttack( c:Card ):void
		{
			Game.current.processes.append_Attack( c );
		}
		
	}

}