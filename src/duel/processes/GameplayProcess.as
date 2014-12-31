package duel.processes 
{
	import duel.cards.Card;
	import duel.Player;
	import duel.table.CreatureField;
	import duel.table.IndexedField;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameplayProcess extends Process 
	{
		static public const TURN_END:String		= "turnEnd";
		static public const TURN_START:String	= "turnStart";
		static public const DRAW_CARD:String	= "drawCard";
		static public const DRAW_CARD_COMPLETE:String = "drawCardComplete";
		static public const DISCARD_CARD:String = "discardCard";
		static public const DISCARD_CARD_COMPLETE:String = "discardCardComplete";
		static public const SUMMON:String = "summon";
		static public const SUMMON_COMPLETE:String = "summonComplete";
		static public const RESURRECT:String = "resurrect";
		static public const RESURRECT_COMPLETE:String = "resurrectComplete";
		static public const SET_TRAP:String = "setTrap";
		static public const SET_TRAP_COMPLETE:String = "setTrapComplete";
		static public const ACTIVATE_TRAP:String = "activateTrap";
		static public const ACTIVATE_TRAP_COMPLETE:String = "activateTrapComplete";
		static public const ACTIVATE_SPECIAL:String = "activateSpecial";
		static public const ACTIVATE_SPECIAL_COMPLETE:String = "activateSpecialComplete";
		static public const RELOCATE:String = "relocate";
		static public const RELOCATE_COMPLETE:String = "relocateComplete";
		static public const ATTACK:String = "attack";
		static public const ATTACK_COMPLETE:String = "attackComplete";
		static public const CREATURE_DAMAGE:String = "creatureDamage";
		static public const CREATURE_DAMAGE_COMPLETE:String = "creatureDamageComplete";
		static public const DIRECT_DAMAGE:String = "directDamage";
		static public const DIRECT_DAMAGE_COMPLETE:String = "directDamageComplete";
		static public const DIE:String = "die";
		static public const DIE_COMPLETE:String = "dieComplete";
		
		static public const COMBAT_FLIP:String = "combatFlip";
		static public const COMBAT_FLIP_COMPLETE:String = "combatFlipComplete";
		static public const COMBAT_FLIP_EFFECT:String = "combatFlipEffect";
		static public const COMBAT_FLIP_EFFECT_COMPLETE:String = "combatFlipEffectComplete";
		
		static public const SAFE_FLIP:String = "safeFlip";
		static public const SAFE_FLIP_COMPLETE:String = "safeFlipComplete";
		static public const SAFE_FLIP_EFFECT:String = "safeFlipEffect";
		static public const SAFE_FLIP_EFFECT_COMPLETE:String = "safeFlipEffectComplete";
		
		static public const SILENT_FLIP:String = "silentFlip";
		static public const SILENT_FLIP_COMPLETE:String = "silentFlipComplete";
		
		static public const ENTER_GRAVE:String = "enterGrave";
		static public const ENTER_GRAVE_COMPLETE:String = "enterGraveComplete";
		static public const ENTER_HAND:String = "enterHand";
		static public const ENTER_HAND_COMPLETE:String = "enterHandComplete";
		static public const ENTER_PLAY:String = "enterPlay";
		static public const ENTER_PLAY_COMPLETE:String = "enterPlayComplete";
		
		//LEAVE_PLAY
		//LEAVE_PLAY_COMPLETE
		
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
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getController():Player
		{
			if ( args[ 0 ] is Card ) 
				return Card( args[ 0 ] ).controller;
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getPlayer():Player
		{
			if ( args[ 0 ] is Player ) 
				return Player( args[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getSourceCard():Card
		{
			if ( args[ 0 ] is Card ) 
				return Card( args[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getAttacker():Card
		{
			if ( args[ 0 ] is Card && Card( args[ 0 ] ).type.isCreature ) 
				return Card( args[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getSummoned():Card
		{
			if ( args[ 0 ] is Card && Card( args[ 0 ] ).type.isCreature ) 
				return Card( args[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getSummonedField():CreatureField
		{
			if ( args[ 1 ] is CreatureField ) 
				return CreatureField( args[ 1 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
	}

}