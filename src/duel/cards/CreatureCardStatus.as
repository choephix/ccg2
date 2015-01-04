package duel.cards 
{
	import duel.cards.buffs.Buff;
	import duel.cards.buffs.BuffManager;
	import duel.cards.properties.cardprops;
	import duel.cards.properties.CreatureCardProperties;
	import duel.Damage;
	import duel.DamageType;
	
	use namespace cardprops;
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureCardStatus 
	{
		public var card:Card;
		
		protected var props:CreatureCardProperties;
		protected var buffs:BuffManager;
		
		public function CreatureCardStatus( card:Card )
		{
			this.card = card;
			this.props = card.propsC;
			this.buffs = new BuffManager();
			this.buffs.card = card;
		}
		
		public function get isFlippable():Boolean
		{ return props.startFaceDown || buffs.getOR( Buff.FLIPPABLE ) }
		
		public function get needTribute():Boolean
		{ return props.needTribute || buffs.getOR( Buff.NEED_TRIBUTE ) }
		
		public function get hasHaste():Boolean
		{ return props.haste || buffs.getOR( Buff.HASTE ) }
		
		public function get hasNoAttack():Boolean
		{ return props.noAttack || buffs.getOR( Buff.NO_ATTACK ) }
		
		public function get hasNoRelocation():Boolean
		{ return props.noMove || buffs.getOR( Buff.NO_RELOCATION ) }
		
		public function get hasSwift():Boolean
		{ return props.swift || buffs.getOR( Buff.SWIFT ) }
		
		
		public function get currentPowerValue():int
		{ return props.basePower + buffs.getSUM( Buff.POWER_OFFSET ) }
		
		public function get currentAttackValue():int
		{ return currentPowerValue }
		
		///
		
		public function generateAttackDamage():Damage
		{ return new Damage( currentPowerValue, DamageType.COMBAT, card ) }
		
		///
		
		public function get basePowerValue():int
		{ return props.basePower }
		
		///
		
		/* * * /
		
		public function get hasGraveSpecial():Boolean 
		{ return graveSpecial != null && !graveSpecial.isNone }
		
		public function get hasHandSpecial():Boolean 
		{ return handSpecial != null && !handSpecial.isNone  }
		
		// SPECIAL
		public function get hasInPlaySpecialEffect():Boolean
		{ return inplaySpecial != null && !inplaySpecial.isNone }
		
		// ONGOING
		public function get hasInPlayOngoingEffect():Boolean
		{ return inplayOngoing != null && !inplayOngoing.isNone }
		
		// COMBAT FLIP
		public function get hasCombatFlipEffect():Boolean
		{ return onCombatFlipFunc != null; }
		
		public function onCombatFlip():void
		{
			if ( onCombatFlipFunc != null )
				onCombatFlipFunc();
		}
		
		// SAFE FLIP
		public function get hasSafeFlipEffect():Boolean
		{ return onSafeFlipFunc != null; }
		
		public function onSafeFlip():void
		{
			if ( onSafeFlipFunc != null )
				onSafeFlipFunc();
		}
		
		/* * */
		
		//
		
		//
		
		public function addBuff( b:Buff ):void
		{
			buffs.addBuff( b );
		}
		
		public function removeBuff( b:Buff ):void
		{
			buffs.removeBuff( b );
		}
		
		//
		public function toString():String 
		{
			var a:Array = [];
			if ( needTribute )			a.push( "needs tribute" );
			if ( isFlippable )			a.push( "flippable" );
			if ( hasHaste )				a.push( "haste" );
			if ( hasNoAttack )			a.push( "no attack" );
			if ( hasNoRelocation )		a.push( "no move" );
			if ( hasSwift )				a.push( "swift" );
			//if ( hasHandSpecial )		a.push( "inhand ef" );
			//if ( hasGraveSpecial )		a.push( "ingrave ef" );
			//if ( hasCombatFlipEffect )	a.push( "combat-flip" );
			//if ( hasSafeFlipEffect )	a.push( "safe-flip" );
			//if ( hasInPlaySpecialEffect )	a.push( "special" );
			//if ( hasInPlayOngoingEffect )	a.push( "ongoing" );
			return a.join( "\n" );
		}
	}

}