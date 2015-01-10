package duel.controllers 
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.GameEntity;
	import duel.players.Player;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	/**
	 * ...
	 * @author choephix
	 */
	public class PlayerControllerFAQ extends GameEntity
	{
		static private var err:String = "There was an error";
		
		//public function PlayerControllerFAQ() {}
		
		public function _( text:String ):String
		{
			return text;
		}
		
		// QUESTIONS :: PLAYER MANA ACTIONS
		
		public function canSummonCreatureOn( c:Card, field:IndexedField, isManual:Boolean ):String
		{ 
			if ( c == null || field == null || c.isInPlay )
				return err;
			
			if ( isManual && c.controller.mana.current < c.cost )
				return _( "You don't have enough mana to summon " + c.name )
			
			if ( c.controller != field.owner )
				return _( "You can only summon creatures on your side of the table." );
			
			if ( !( field is CreatureField ) )
				return _( "You can only summon a creature on a creature field." );
			
			if ( field.isLocked )
				return _( "You cannot place creatures on a locked field." );
			
			if ( c.statusC.needTribute )
			{
				if ( field.isEmpty )
					return _( "You need to replace another creature to summon a Grand creature." )
			}
			else
			{
				if ( !field.isEmpty )
					return _( "You cannot summon this creature ontop of another." )
			}
			
			if ( !c.statusC.maySummonOn( field ) )
				return _( "You may not summon " + c.name + " here at this time." )
			
			return null;
		}
		
		public function canSetTrapOn( c:Card, field:IndexedField, isManual:Boolean ):String
		{
			if ( c == null || field == null || c.isInPlay )
				return err;
			
			if ( isManual && c.controller.mana.current < c.cost )
				return _( "You don't have enough mana to set " + c.name )
			
			if ( c.controller != field.owner )
				return _( "You can only set traps on your side of the table." );
			
			if ( !( field is TrapField ) )
				return _( "You can only set a trap on a trap field." );
			
			if ( field.isLocked )
				return _( "You cannot place traps on a locked field." );
			
			return null;
		}
		
		public function canDrawCard( p:Player, isManual:Boolean ):String
		{
			if ( p == null )
				return err;
			
			if ( isManual && p.mana.current < 1 )
				return _( "You don't have enough mana to draw a card" )
			
			return null;
		}
		
		// QUESTIONS :: PLAYER IN-PLAY ACTIONS
		
		public function canCreatureRelocateTo( c:Card, field:IndexedField, isManual:Boolean ):String
		{ 
			if ( c == null || field == null || !c.isInPlay )
				return err;
			
			if ( c.controller != field.owner )
				return _( "You cannot move creatures to your opponent's side of the table." );
			
			if ( c.indexedField.isLocked )
				return _( "You cannot move creatures on a locked field." );
			
			if ( !( field is CreatureField ) )
				return _( "You can only move a creature to another creature field." );
			
			if ( field.isLocked )
				return _( "You cannot move creatures to a locked field." );
			
			if ( isManual && c.exhausted )
				return _( c.name + " is exhausted." )
			
			if ( isManual && !c.canRelocate )
				return _( c.name + " cannot move right now." )
			
			if ( !field.isEmpty )
				return _( c.name + " can only be moved to another empty field." );
			
			return null;
		}
		
		public function canCreatureAttack( c:Card, isManual:Boolean ):String
		{ 
			if ( c == null || !c.isInPlay )
				return err;
			
			if ( c.indexedField.isLocked )
				return _( "You cannot use creatures ontop a locked field." );
			
			if ( isManual && c.exhausted )
				return _( c.name + " is exhausted." )
			
			if ( isManual && !c.canAttack )
				return _( c.name + " cannot attack right now." )
			
			return null;
		}
		
		public function canCreatureSafeFlip( c:Card, isManual:Boolean ):String
		{ 
			if ( c == null || !c.isInPlay )
				return err;
			
			if ( !c.statusC.isFlippable )
				return _( "You cannot safeflip this card." );
			
			if ( c.indexedField.isLocked )
				return _( "You cannot use creatures ontop a locked field." );
			
			if ( isManual && c.exhausted )
				return _( c.name + " is exhausted." )
			
			return null;
		}
		
	}

}
