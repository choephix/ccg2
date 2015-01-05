package duel.cards.status {
	import duel.cards.buffs.Buff;
	import duel.cards.buffs.BuffManager;
	import duel.cards.Card;
	import duel.cards.properties.cardprops;
	import duel.cards.properties.CreatureCardProperties;
	import duel.Damage;
	import duel.DamageType;
	import duel.otherlogic.OngoingEffect;
	import duel.otherlogic.SpecialEffect;
	import duel.processes.GameplayProcess;
	import duel.processes.gameprocessing;
	
	use namespace cardprops;
	use namespace gameprocessing;
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureCardStatus extends CardStatus
	{
		public function get propsC():CreatureCardProperties
		{ return props as CreatureCardProperties }
		
		override public function initialize():void
		{
			super.initialize();
			this.buffs = new BuffManager();
			this.buffs.card = card;
		}
		
		override public function onGameProcess( p:GameplayProcess ):void
		{
			var i:int;
			
			// ONGOING SPECIALS
			if ( propsC.specialsOngoingCount > 0 )
			{
				var oe:OngoingEffect;
				for ( i = 0; i < propsC.specialsOngoingCount; i++ ) 
				{
					oe = propsC.specialsOngoing[ i ];
					oe.update( p );
					
					/// just in case
					if ( p.isInterrupted )
						return;
				}
			}
			
			// TRIGGERED SPECIALS
			if ( propsC.specialsTriggeredCount > 0 )
			{
				var se:SpecialEffect;
				for ( i = 0; i < propsC.specialsTriggeredCount; i++ ) 
				{
					se = propsC.specialsTriggered[ i ];
					if ( se.isAllowedInField( card.lot.type ) && se.mustInterrupt( p ) )
					{
						p.interrupt();
						processes.prepend_TriggerSpecial( card, se );
						return;
					}
				}
			}
			
			// LIFE-LINKS
			if ( _lifeLinked )
			{
				if ( !card.isInPlay )
				{
					clearLifeLinks();
				}
				else
				{
					i = 0;
					
					while ( i < _lifeLinks.length )
					{
						if ( _lifeLinks[i].isInPlay )
							i++
						else
							_lifeLinks.splice( i, 1 );
					}
					
					if ( i == 0 )
					{
						clearLifeLinks();
						processes.prepend_Death( card );
					}
				}
			}
				
		}
		
		// PROP FLAGS
		
		public function get isFlippable():Boolean
		{ return propsC.flippable || buffs.getOR( Buff.FLIPPABLE ) }
		
		public function get needTribute():Boolean
		{ return propsC.needTribute || buffs.getOR( Buff.NEED_TRIBUTE ) }
		
		public function get hasHaste():Boolean
		{ return propsC.haste || buffs.getOR( Buff.HASTE ) }
		
		public function get hasNoAttack():Boolean
		{ return propsC.noAttack || buffs.getOR( Buff.NO_ATTACK ) }
		
		public function get hasNoRelocation():Boolean
		{ return propsC.noMove || buffs.getOR( Buff.NO_RELOCATION ) }
		
		public function get hasSwift():Boolean
		{ return propsC.swift || buffs.getOR( Buff.SWIFT ) }
		
		// PROP VALUES
		
		public function get basePowerValue():int
		{ return propsC.basePower }
		
		public function get currentPowerValue():int
		{ return propsC.basePower + buffs.getSUM( Buff.POWER_OFFSET ) }
		
		public function get currentAttackValue():int
		{ return currentPowerValue }
		
		// COMBAT LOGIC
		
		public function generateAttackDamage():Damage
		{ return new Damage( currentPowerValue, DamageType.COMBAT, card ) }
		
		/* * */
		
		// COMBAT FLIP
		public function get canDoCombatFlipEffect():Boolean
		{ return propsC.onCombatFlipFunc != null; }
		
		public function onCombatFlip():void
		{ propsC.onCombatFlipFunc() }
		
		// SAFE FLIP
		public function get canDoSafeFlipEffect():Boolean
		{ return propsC.onSafeFlipFunc != null; }
		
		public function onSafeFlip():void
		{ propsC.onSafeFlipFunc() }
		
		/* * */
		
		// LIFE-LINKS
		
		private var _lifeLinks:Vector.<Card> = new <Card> [];
		private var _lifeLinked:Boolean = false;
		
		public function setLifeLinks( ...cards ):void
		{ 
			_lifeLinked = true;
			_lifeLinks.push.apply( null, cards )
		}
		
		public function isLifeLinked():Boolean
		{ return _lifeLinked }
		
		public function clearLifeLinks():void
		{ 
			_lifeLinked = false;
			_lifeLinks.length = 0;
		}
		
		// BUFFS
		
		protected var buffs:BuffManager;
		
		public function addBuff( b:Buff ):void
		{ buffs.addBuff( b ) }
		
		public function removeBuff( b:Buff ):void
		{ buffs.removeBuff( b ) }
		
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
			if ( _lifeLinked )			a.push( "links:"+_lifeLinks.length );
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