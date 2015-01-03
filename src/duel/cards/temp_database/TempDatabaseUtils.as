package duel.cards.temp_database 
{
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.behaviour.TrapCardBehaviour;
	import duel.cards.Card;
	import duel.cards.CardType;
	import duel.Damage;
	import duel.DamageType;
	import duel.G;
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
		
		public static function doDestroyTrap( c:Card ):void
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
			Game.current.processes.prepend_AddToGrave( c );
		}
		
		static public function doPutInHand( c:Card, p:Player ):void
		{
			Game.current.processes.prepend_AddToHand( c, p );
		}
		
		static public function doPutInDeck( c:Card, p:Player, faceDown:Boolean, shuffle:Boolean ):void
		{
			Game.current.processes.prepend_AddToDeck( c, p, faceDown, shuffle );
		}
		
		static public function doForceAttack( c:Card, free:Boolean ):void
		{
			Game.current.processes.append_Attack( c, free );
		}
		
		static public function doDealDirectDamage( p:Player, amount:int, source:* ):void
		{
			Game.current.processes.prepend_DirectDamage( p, 
					new Damage( amount, DamageType.SPECIAL, source ) );
		}
		
		static public function doPutInHandTrapsRow( p:Player ):void
		{
			for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
			{
				if ( p.fieldsT.getAt( i ).isEmpty )
					continue;
				doPutInHand( p.fieldsT.getAt( i ).topCard, p )
			}
		}
		
		static public function doPutInHandCreaturesRow( p:Player ):void
		{
			for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
			{
				if ( p.fieldsC.getAt( i ).isEmpty )
					continue;
				doPutInHand( p.fieldsC.getAt( i ).topCard, p )
			}
		}
		
		static public function doKillCreaturesRow( p:Player ):void
		{
			for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
			{
				if ( p.fieldsC.getAt( i ).isEmpty )
					continue;
				doKill( p.fieldsC.getAt( i ).topCard );
			}
		}
		
		static public function doDestroyTrapsRow( p:Player ):void
		{
			for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
			{
				if ( p.fieldsT.getAt( i ).isEmpty )
					continue;
				doDestroyTrap( p.fieldsT.getAt( i ).topCard );
			}
		}
		
	}

}