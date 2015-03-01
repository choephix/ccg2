package duel.cards.properties {
	import duel.cards.buffs.GlobalBuff;
	import duel.Damage;
	import duel.DamageType;
	import duel.otherlogic.OngoingEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.cards.properties.cardprops;
	
	use namespace cardprops;
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureCardProperties extends CardProperties 
	{
		public var isToken:Boolean = false;
		public var isGrand:Boolean = false;
		public var isFlippable:Boolean = false;
		cardprops var basePower:int = 0;
		cardprops var hasSwift:Boolean 	= false; 	// CAN ATTACK AND MOVE SAME TURN
		cardprops var hasSwap:Boolean 	= false; 	// CAN RELOCATE TO AN OCCUPIED FIELD
		
		// SUMMONING CONDITION
		cardprops var summonConditionManual:Function;
		cardprops var summonConditionAutomatic:Function;
		
		// SPECIAL
		cardprops var specialsTriggered:Vector.<SpecialEffect> = new Vector.<SpecialEffect>();
		
		cardprops function get specialsTriggeredCount():int
		{ return specialsTriggered.length }
		
		/// Interrupts current process on activation
		cardprops function addTriggered( special:SpecialEffect = null ):SpecialEffect
		{
			if ( special == null )
				special = new SpecialEffect();
			specialsTriggered.push( special );
			return special;
		}
		
		// ONGOING
		cardprops var specialsOngoing:Vector.<OngoingEffect> = new Vector.<OngoingEffect>();
		
		cardprops function get specialsOngoingCount():int
		{ return specialsOngoing.length }
		
		/// Activates without interrupting current process
		cardprops function addOngoing( special:OngoingEffect = null ):OngoingEffect
		{
			if ( special == null )
				special = new OngoingEffect();
			specialsOngoing.push( special );
			return special;
		}
		
		// COMBAT FLIP
		public var onCombatFlipFunc:Function;
		
		// SAFE FLIP
		public var onSafeFlipFunc:Function;
	}
}