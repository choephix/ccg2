package duel.processes 
{
	import duel.cards.Card;
	import duel.Damage;
	import duel.players.Player;
	import duel.table.CreatureField;
	import duel.table.IndexedField;
	
	use namespace gameprocessgetter;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class GameplayProcess extends Process 
	{
		/// p:Player
		static public const TURN_END:String		= "turnEnd";
		/// p:Player
		static public const TURN_START:String	= "turnStart";
		/// p:Player
		static public const TURN_START_COMPLETE:String	= "turnStartComplete";
		
		/// p:Player
		static public const DRAW_CARD:String	= "drawCard";
		/// p:Playe c:Card
		static public const DRAW_CARD_COMPLETE:String = "drawCardComplete";
		/// p:Playe c:Card
		static public const DISCARD_CARD:String = "discardCard";
		/// p:Playe c:Card
		static public const DISCARD_CARD_COMPLETE:String = "discardCardComplete";
		
		/// c:Card, field:CreatureField
		static public const SUMMON:String = "summon";
		/// c:Card, field:CreatureField
		static public const SUMMON_COMPLETE:String = "summonComplete";
		/// c:Card, field:CreatureField
		static public const RELOCATE:String = "relocate";
		/// c:Card, field:CreatureField
		static public const RELOCATE_COMPLETE:String = "relocateComplete";
		/// c:Card
		static public const ATTACK:String = "attack";
		/// c:Card
		static public const ATTACK_COMPLETE:String = "attackComplete";
		/// c:Card
		static public const ATTACK_ABORT:String = "attackAbort";
		/// c:Card, dmg:Damage
		static public const CREATURE_DAMAGE:String = "creatureDamage";
		/// c:Card, dmg:Damage
		static public const CREATURE_DAMAGE_COMPLETE:String = "creatureDamageComplete";
		/// p:Player, dmg:Damage
		static public const DIRECT_DAMAGE:String = "directDamage";
		/// p:Player, dmg:Damage
		static public const DIRECT_DAMAGE_COMPLETE:String = "directDamageComplete";
		/// c:Card, fromCombat:Boolean
		static public const DIE:String = "die";
		/// c:Card, fromCombat:Boolean
		static public const DIE_COMPLETE:String = "dieComplete";
		/// c:Card, field:CreatureField
		static public const RESURRECT:String = "resurrect";
		/// c:Card, field:CreatureField
		static public const RESURRECT_COMPLETE:String = "resurrectComplete";
		
		/// c:Card, field:TrapField
		static public const SET_TRAP:String = "setTrap";
		/// c:Card, field:TrapField
		static public const SET_TRAP_COMPLETE:String = "setTrapComplete";
		/// c:Card
		static public const ACTIVATE_TRAP:String = "activateTrap";
		/// c:Card
		static public const ACTIVATE_TRAP_COMPLETE:String = "activateTrapComplete";
		/// c:Card
		static public const ACTIVATE_SPECIAL:String = "activateSpecial";
		/// c:Card
		static public const ACTIVATE_SPECIAL_COMPLETE:String = "activateSpecialComplete";
		/// c:Card
		static public const DEACTIVATE_TRAP:String = "deactivateTrap";
		/// c:Card
		static public const DEACTIVATE_TRAP_COMPLETE:String = "deactivateTrapComplete";
		
		///  c:Card
		static public const COMBAT_FLIP:String = "combatFlip";
		/// c:Card
		static public const COMBAT_FLIP_COMPLETE:String = "combatFlipComplete";
		/// c:Card
		static public const COMBAT_FLIP_EFFECT:String = "combatFlipEffect";
		/// c:Card
		static public const COMBAT_FLIP_EFFECT_COMPLETE:String = "combatFlipEffectComplete";
		
		/// c:Card
		static public const SAFE_FLIP:String = "safeFlip";
		/// c:Card
		static public const SAFE_FLIP_COMPLETE:String = "safeFlipComplete";
		/// c:Card
		static public const SAFE_FLIP_EFFECT:String = "safeFlipEffect";
		/// c:Card
		static public const SAFE_FLIP_EFFECT_COMPLETE:String = "safeFlipEffectComplete";
		
		///  c:Card
		static public const SILENT_FLIP:String = "silentFlip";
		/// c:Card
		static public const SILENT_FLIP_COMPLETE:String = "silentFlipComplete";
		
		///  c:Card, p:Player
		static public const ENTER_DECK:String = "enterDeck";
		/// c:Card, p:Player
		static public const ENTER_DECK_COMPLETE:String = "enterDeckComplete";
		/// c:Card, p:Player
		static public const ENTER_HAND:String = "enterHand";
		/// c:Card, p:Player
		static public const ENTER_HAND_COMPLETE:String = "enterHandComplete";
		/// c:Card
		static public const ENTER_GRAVE:String = "enterGrave";
		/// c:Card
		static public const ENTER_GRAVE_COMPLETE:String = "enterGraveComplete";
		/// c:Card
		static public const ENTER_PLAY:String = "enterPlay";
		/// c:Card, field:IndexedField
		static public const ENTER_PLAY_COMPLETE:String = "enterPlayComplete";
		
		///  c:Card, field:IndexedField
		static public const ENTER_INDEXED_FIELD:String = "enterIndexedField";
		///  c:Card, field:IndexedField
		static public const ENTER_INDEXED_FIELD_COMPLETE:String = "enterIndexedFieldComplete";
		///  c:Card, field:IndexedField
		static public const LEAVE_INDEXED_FIELD:String = "leaveIndexedField";
		///  c:Card, field:IndexedField
		static public const LEAVE_INDEXED_FIELD_COMPLETE:String = "leaveIndexedFieldComplete"
		
		///  c:Card
		static public const LEAVE_PLAY:String = "leavePlay";
		///  c:Card
		static public const LEAVE_PLAY_COMPLETE:String = "leavePlayComplete";
		
		///  c:Card
		static public const TRIBUTE_CREATURE:String = "tributeCreature";
		///  c:Card
		static public const TRIBUTE_CREATURE_COMPLETE:String = "tributeCreatureComplete";;
		
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		
		public function getIndex():int
		{
			if ( args[ 0 ] is Card ) 
			{
				if ( Card( args[ 0 ] ).isInPlay )
					return Card( args[ 0 ] ).indexedField.index;
				else
					return -1;
			}
			if ( args[ 0 ] is IndexedField ) 
				return IndexedField( args[ 0 ] ).index;
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getIndex..." ); }
			return -1;
		}
		
		public function getController():Player
		{
			if ( args[ 0 ] is Card ) 
				return Card( args[ 0 ] ).controller;
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getController..." ); }
			return null;
		}
		
		public function getPlayer():Player
		{
			if ( args[ 0 ] is Player ) 
				return Player( args[ 0 ] );
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getPlayer..." ); }
			return null;
		}
		
		public function getDrawnCard():Card
		{
			if ( args[ 1 ] is Card ) 
				return Card( args[ 1 ] );
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getDrawnCard..." ); }
			return null;
		}
		
		public function getSourceCard():Card
		{
			if ( args[ 0 ] is Card ) 
				return Card( args[ 0 ] );
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getSourceCard..." ); }
			return null;
		}
		
		public function getAttacker():Card
		{
			if ( args[ 0 ] is Card && Card( args[ 0 ] ).isCreature ) 
				return Card( args[ 0 ] );
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getAttacker..." ); }
			return null;
		}
		
		public function getSummoned():Card
		{
			if ( args[ 0 ] is Card && Card( args[ 0 ] ).isCreature ) 
				return Card( args[ 0 ] );
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getSummoned..." ); }
			return null;
		}
		
		public function getSummonedField():CreatureField
		{
			if ( args.length > 1 && args[ 1 ] is CreatureField ) 
				return CreatureField( args[ 1 ] );
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getSummonedField..." ); }
			return null;
		}
		
		public function getDamage():Damage
		{
			if ( args[ 1 ] is Damage ) 
				return args[ 1 ] as Damage;
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getDamage..." ); }
			return -1;
		}
		
		public function getDeathIsFromCombat():Boolean
		{
			if ( args.length > 1 && args[ 1 ] is Boolean )
				return args[ 1 ] as Boolean;
			
			CONFIG::development
			{ throw new ArgumentError( "What to do... getDeathIsFromCombat..." ); }
			return false;
		}
		
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		//  //  //  //  //  //  //  //  //  //  //  //  //  //  //
		
	}

}