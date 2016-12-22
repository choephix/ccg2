package duel.cards 
{
	import duel.Damage;
	import duel.Game;
	import duel.table.CreatureField;
	import duel.table.Hand;
	import duel.table.TrapField;
	
	public class GameplayFAQ 
	{
		
		public static function isInPlay( c:Card ):Boolean
		{ return c != null && c.isInPlay }
		public static function isNotInPlay( c:Card ):Boolean
		{ return !c.isInPlay }
		
		public static function isInGrave( c:Card ):Boolean
		{ return c != null && c.isInGrave }
		public static function isNotInGrave( c:Card ):Boolean
		{ return !c.isInGrave }
		
		public static function isInHand( c:Card ):Boolean
		{ return c != null && c.isInHand }
		public static function isNotInHand( c:Card ):Boolean
		{ return !c.isInHand }
		
		public static function isInDeck( c:Card ):Boolean
		{ return c != null && c.isInGrave }
		public static function isNotInDeck( c:Card ):Boolean
		{ return !c.isInGrave }
		
		//
		
		/** /
		
		public static function canSummonHere( c:Card, field:CreatureField, isManual:Boolean ):Boolean
		{ 
			if ( c.isInPlay ) return false;
			if ( c.isInGrave ) return false;
				
			if ( c.statusC.needTribute )
			{
				if ( c.controller != field.owner ) return false;
				if ( field.isLocked ) return false;
				if ( field.isEmpty ) return false;
				if ( !field.topCard.statusC.canBeTribute ) return false;
				return c.statusC.canBeSummonedOn( field, isManual );
			}
			
			if ( !canPlaceCreatureHere( c, field ) ) return false;
			if ( !c.statusC.canBeSummonedOn( field, isManual ) ) return false;
			return true;
		}
		public static function cannotSummonHere( c:Card, field:CreatureField, isManual:Boolean ):Boolean
		{ return !canSummonHere( c, field, isManual ) }
		
		/**/
		
		public static function canSwapHere( c:Card, field:CreatureField, free:Boolean ):Boolean
		{ 
			if ( c == null ) return false;
			if ( field == null ) return false;
			if ( !c.isInPlay ) return false;
			if ( !free && !c.statusC.canRelocate ) return false;
			if ( c.lot == field ) return false;
			if ( field.isLocked ) return false;
			if ( field.isEmpty ) return false;
			if ( !free && !c.statusC.hasSwap ) return false;
			return true;
		}
		public static function cannotSwapHere( c:Card, field:CreatureField, free:Boolean ):Boolean
		{ return !canSwapHere( c, field, free ) }
		
		public static function canRelocateHere( c:Card, field:CreatureField, free:Boolean ):Boolean
		{ 
			if ( c == null ) return false;
			if ( field == null ) return false;
			if ( !c.isInPlay ) return false;
			if ( !free && !c.statusC.canRelocate ) return false;
			if ( c.lot == field ) return false;
			if ( field.isLocked ) return false;
			if ( !field.isEmpty ) return false; //TODO remove this for riders and combinatrons
			return true;
		}
		public static function cannotRelocateHere( c:Card, field:CreatureField, free:Boolean ):Boolean
		{ return !canRelocateHere( c, field, free ) }
		
		public static function canPlaceTrapHere( c:Card, field:TrapField ):Boolean
		{
			if ( c == null ) return false;
			if ( field == null ) return false;
			
			if ( field.isLocked ) return false;
			if ( c.lot == field ) return false;
			
			CONFIG::development
			{ if ( Game.GODMODE ) return true }
			
			return true;
		}
		public static function cannotPlaceTrapHere( c:Card, field:TrapField ):Boolean
		{ return !canPlaceTrapHere( c, field ) }
		
		//
		
		public static function canPerformAttack( c:Card, free:Boolean ):Boolean
		{ return c != null && c.isInPlay && ( free || c.statusC.canAttack ) }
		public static function cannotPerformAttack( c:Card, free:Boolean ):Boolean
		{ return !canPerformAttack( c, free ) }
		
		public static function canTakeDamage( c:Card, dmg:Damage ):Boolean
		{ return c != null && c.isInPlay }
		public static function cannotTakeDamage( c:Card, dmg:Damage ):Boolean
		{ return !canTakeDamage( c, dmg ) }
		
		public static function canDie( c:Card, fromCombat:Boolean=false, causer:Card=null ):Boolean
		{ return c != null && c.isInPlay }
		public static function cannotDie( c:Card, fromCombat:Boolean=false, causer:Card=null ):Boolean
		{ return !canDie( c ) }
		
		public static function canFlipInPlay( c:Card ):Boolean
		{ return c != null && c.isInPlay && c.faceDown }
		public static function cannotFlipInPlay( c:Card ):Boolean
		{ return !canFlipInPlay( c ) }
		
		public static function canDoFlipEffect( c:Card ):Boolean
		{ return c != null && c.isInPlay }
		public static function cannotDoFlipEffect( c:Card ):Boolean
		{ return !canDoFlipEffect( c ) }
	}
}