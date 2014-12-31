package duel.cards.behaviour 
{
	import duel.Damage;
	import duel.DamageType;
	import duel.otherlogic.SpecialEffect;
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureCardBehaviour extends CardBehaviour 
	{
		public var attack:int = 0;
		public var tributes:int = 0;
		
		public var haste:Boolean = false; 		// CAN ATTACK OR MOVE FIRST TURN
		public var noattack:Boolean = false; 	// CANNOT ATTACK
		public var nomove:Boolean = false; 		// CANNOT MOVE
		public var swift:Boolean = false; 		// CAN ATTACK AND MOVE SAME TURN
		public var berserk:Boolean = false;		// ATTACKS AUTOMATICALLY
		
		
		// SPECIAL
		public var inplaySpecial:SpecialEffect = new SpecialEffect();
		public function get hasInPlaySpecialEffect():Boolean
		{ return inplaySpecial != null && !inplaySpecial.isNone; }
		
		// ONGOING
		public var inplayOngoingFunc:Function;
		public function get hasInPlayOngoingEffect():Boolean
		{ return inplayOngoingFunc != null; }
		
		// COMBAT FLIP
		public var onCombatFlipFunc:Function;
		public function get hasCombatFlipEffect():Boolean
		{ return onCombatFlipFunc != null; }
		
		public function onCombatFlip():void
		{
			if ( onCombatFlipFunc != null )
				onCombatFlipFunc();
		}
		
		// SAFE FLIP
		public var onSafeFlipFunc:Function;
		public function get hasSafeFlipEffect():Boolean
		{ return onSafeFlipFunc != null; }
		
		public function onSafeFlip():void
		{
			if ( onSafeFlipFunc != null )
				onSafeFlipFunc();
		}
		
		//
		
		//
		
		//
		public function genAttackDamage():Damage
		{
			return new Damage( attack, DamageType.COMBAT, card );
		}
		
		//
		public function toString():String 
		{
			var a:Array = [];
			if ( haste )	a.push( "haste" );
			if ( noattack )	a.push( "no attack" );
			if ( nomove )	a.push( "no move" );
			if ( swift )	a.push( "swift" );
			if ( berserk )	a.push( "berserk" );
			if ( hasCombatFlipEffect )	a.push( "combat-flip" );
			if ( hasSafeFlipEffect )	a.push( "safe-flip" );
			if ( hasHandSpecial )	a.push( "inhand" );
			if ( hasGraveSpecial )	a.push( "ingrave" );
			if ( hasInPlaySpecialEffect )	a.push( "special" );
			if ( hasInPlayOngoingEffect )	a.push( "ongoing" );
			return a.join( "\n" );
		}
	}
}