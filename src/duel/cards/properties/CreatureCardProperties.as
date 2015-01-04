package duel.cards.properties {
	import duel.Damage;
	import duel.DamageType;
	import duel.otherlogic.OngoingEffect;
	import duel.otherlogic.SpecialEffect;
	
	use namespace cardprops;
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureCardProperties extends CardProperties 
	{
		cardprops var isToken:Boolean = false;
		
		cardprops var basePower:int = 0;
		cardprops var needTribute:Boolean = false;
		cardprops var flippable:Boolean = false;
		
		cardprops var haste:Boolean 	= false; 	// CAN ATTACK OR MOVE FIRST TURN
		cardprops var swift:Boolean 	= false; 	// CAN ATTACK AND MOVE SAME TURN
		cardprops var noAttack:Boolean 	= false; 	// CANNOT ATTACK
		cardprops var noMove:Boolean	= false; 	// CANNOT MOVE
		
		override public function get startFaceDown():Boolean 
		{ return flippable }
		
		// SPECIAL
		public var inplaySpecial:SpecialEffect = new SpecialEffect();
		public function get hasInPlaySpecialEffect():Boolean
		{ return inplaySpecial != null && !inplaySpecial.isNone }
		
		// ONGOING
		public var inplayOngoing:OngoingEffect = new OngoingEffect();
		public function get hasInPlayOngoingEffect():Boolean
		{ return inplayOngoing != null && !inplayOngoing.isNone }
		
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
	}
}