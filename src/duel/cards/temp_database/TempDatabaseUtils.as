package duel.cards.temp_database 
{
	import duel.cards.Card;
	import duel.cards.properties.CreatureCardProperties;
	import duel.cards.properties.TrapCardProperties;
	import duel.cards.status.CreatureCardStatus;
	import duel.cards.status.TrapCardStatus;
	import duel.Damage;
	import duel.DamageType;
	import duel.G;
	import duel.Game;
	import duel.players.Player;
	import duel.processes.GameplayProcess;
	import duel.processes.gameprocessing;
	import duel.table.CreatureField;
	
	use namespace gameprocessing;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class TempDatabaseUtils 
	{
		public static function setToCreature( c:Card ):void
		{
			c.props = new CreatureCardProperties();
			c.status = new CreatureCardStatus();
		}
			
		public static function setToTrap( c:Card ):void
		{
			c.props = new TrapCardProperties();
			c.status = new TrapCardStatus();
		}
		
		// 
		
		public static function isInBattle( c:Card, p:GameplayProcess ):Boolean
		{
			var atker:Card = p.getAttacker();
			if ( c == atker ) return true;
			if ( c == atker.indexedField.opposingCreature ) return true;
			return false;
		}
		
		// PROCESSES
		
		public static function doKill( c:Card, cause:Card ):void
		{
			if ( c == null ) return;
			game.processes.prepend_Death( c, false, cause );
		}
		
		public static function doDestroyTrap( c:Card ):void
		{
			game.processes.prepend_DestroyTrap( c );
		}
		
		static public function doDraw( p:Player, count:int ):void 
		{
			game.processes.prepend_Draw( p, count );
		}
		
		static public function doDiscard( p:Player, c:Card ):void 
		{
			game.processes.prepend_Discard( p, c );
		}
		
		static public function doDiscardHand( p:Player ):void 
		{
			for ( var i:int = 0; i < p.hand.cardsCount; i++ )
				game.processes.prepend_Discard( p, p.hand.getCardAt( i ) );
		}
		
		static public function doPutToGrave( c:Card ):void
		{
			game.processes.prepend_AddToGrave( c );
		}
		
		static public function doPutInHand( c:Card, p:Player ):void
		{
			game.processes.prepend_AddToHand( c, p );
		}
		
		static public function doPutInDeck( c:Card, p:Player, faceDown:Boolean, shuffle:Boolean ):void
		{
			game.processes.prepend_AddToDeck( c, p, faceDown, shuffle );
		}
		
		static public function doForceAttack( c:Card, free:Boolean ):void
		{
			game.processes.append_Attack( c, free );
		}
		
		static public function doForceRelocate( c:Card, field:CreatureField, free:Boolean ):void 
		{
			game.processes.append_Relocation( c, field, free );
		}
		
		static public function doDealDirectDamage( p:Player, amount:int, source:* ):void
		{
			game.processes.prepend_DirectDamage( p, 
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
		
		static public function doKillCreaturesRow( p:Player, cause:Card ):void
		{
			for ( var i:int = 0; i < G.FIELD_COLUMNS; i++ ) 
			{
				if ( p.fieldsC.getAt( i ).isEmpty )
					continue;
				doKill( p.fieldsC.getAt( i ).topCard, cause );
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
		
		static public function doHeal( p:Player, amount:int ):void
		{
			p.heal( amount );
		}
		
		static public function doSpawnTokenCreatureIfEmpty( field:CreatureField ):void
		{
			if ( !field.isEmpty ) return;
			game.processes.append_SummonHere( game.produceCard( "token1" ), field, false );
		}
		
		static public function doSummonFromDeck( c:Card, field:CreatureField ):void 
		{
			game.processes.append_SummonHere( c, field, false );
		}
		
		static public function doResurrectCreature( c:Card, field:CreatureField ):void
		{
			game.processes.prepend_ResurrectHere( c, field );
		}
		
		static public function doEndCurrrentTurn():void
		{
			game.processes.append_TurnEnd( game.currentPlayer );
		}
		
		//
		static public function get game():Game { return Game.current }
	}
}