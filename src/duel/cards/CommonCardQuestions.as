package duel.cards 
{
	import duel.Damage;
	import duel.table.CreatureField;
	import duel.table.Hand;
	import duel.table.TrapField;
	/**
	 * ...
	 * @author choephix
	 */
	public class CommonCardQuestions 
	{
		
		public static function isInPlay( c:Card ):Boolean
		{ return c.isInPlay }
		public static function isNotInPlay( c:Card ):Boolean
		{ return !c.isInPlay }
		
		public static function isInGrave( c:Card ):Boolean
		{ return c.isInGrave }
		public static function isNotInGrave( c:Card ):Boolean
		{ return !c.isInGrave }
		
		public static function isInHand( c:Card ):Boolean
		{ return c.isInHand }
		public static function isNotInHand( c:Card ):Boolean
		{ return !c.isInHand }
		
		public static function isInDeck( c:Card ):Boolean
		{ return c.isInGrave }
		public static function isNotInDeck( c:Card ):Boolean
		{ return !c.isInGrave }
		
		//
		
		public static function canSummonHere( c:Card, field:CreatureField ):Boolean
		{ 
			if ( c.isInPlay ) return false;
			
			if ( c.behaviourC.needsTribute )
			{
				if ( c.isInGrave ) return false;
				if ( c.controller != field.owner ) return false;
				if ( field.isEmpty ) return false; //TODO remove this for riders and combinatrons
				return true;
			}
			
			return canPlaceCreatureHere( c, field );
		}
		public static function cannotSummonHere( c:Card, field:CreatureField ):Boolean
		{ return !canSummonHere( c, field ) }
		
		public static function canRelocateHere( c:Card, field:CreatureField ):Boolean
		{ 
			if ( !c.isInPlay ) return false;
			if ( !c.canRelocate ) return false;
			return canPlaceCreatureHere( c, field );
		}
		public static function cannotRelocateHere( c:Card, field:CreatureField ):Boolean
		{ return !canRelocateHere( c, field ) }
		
		public static function canPlaceCreatureHere( c:Card, field:CreatureField ):Boolean
		{
			if ( c.isInGrave ) return false;
			if ( c.controller != field.owner ) return false;
			if ( field.isLocked ) return false;
			if ( !field.isEmpty ) return false; //TODO remove this for riders and combinatrons
			return true;
		}
		public static function cannotPlaceCreatureHere( c:Card, field:CreatureField ):Boolean
		{ return !canPlaceCreatureHere( c, field ) }
		
		public static function canPlaceTrapHere( card:Card, field:TrapField ):Boolean
		{
			if ( card.isInGrave ) return false;
			if ( !field.isEmpty ) return false;
			if ( field.isLocked ) return false;
			if ( card.controller != field.owner ) return false;
			return true;
		}
		public static function cannotPlaceTrapHere( c:Card, field:TrapField ):Boolean
		{ return !canPlaceTrapHere( c, field ) }
		
		//
		
		public static function canPerformAttack( c:Card ):Boolean
		{ return c.canAttack }
		public static function cannotPerformAttack( c:Card ):Boolean
		{ return !canPerformAttack( c ) }
		
		public static function canTakeDamage( c:Card, dmg:Damage ):Boolean
		{ return c.isInPlay }
		public static function cannotTakeDamage( c:Card, dmg:Damage ):Boolean
		{ return !canTakeDamage( c, dmg ) }
		
		public static function canDie( c:Card ):Boolean
		{ return c.isInPlay }
		public static function cannotDie( c:Card ):Boolean
		{ return !canDie( c ) }
		
		public static function canFlipInPlay( c:Card ):Boolean
		{ return c.isInPlay && c.faceDown }
		public static function cannotFlipInPlay( c:Card ):Boolean
		{ return !canFlipInPlay( c ) }
		
		public static function canDoFlipEffect( c:Card ):Boolean
		{ return c.isInPlay }
		public static function cannotDoFlipEffect( c:Card ):Boolean
		{ return !canDoFlipEffect( c ) }
	}
}