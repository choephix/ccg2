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
	import duel.table.Field;
	
	use namespace cardprops;
	use namespace gameprocessing;
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureCardStatus extends CardStatus
	{
		public var actionsRelocate:int = 0;
		public var actionsAttack:int = 0;
		public var hasSummonExhaustion:Boolean = false;
		
		public function get propsC():CreatureCardProperties
		{ return props as CreatureCardProperties }
		
		override public function initialize():void
		{
			super.initialize();
			this.buffs = new BuffManager( card );
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
		
		public function onLeavePlay():void
		{
			reset();
			buffs.removeAllWeak();
		}
		
		public function onTurnEnd():void
		{
			reset();
		}
		
		/// This must be called on turn start as well as when the card leaves play
		public function reset():void
		{
			actionsRelocate = 0;
			actionsAttack = 0;
			hasSummonExhaustion = false;
		}
		
		// PROP FLAGS
		
		public function get hasActionExhaustion():Boolean
		{ 
			if ( propsC.hasSwift ) 
				return actionsAttack * actionsRelocate > 0;
			return actionsRelocate + actionsAttack > 0;
		}
		
		public function get canAttack():Boolean { 
			if ( hasSummonExhaustion ) return false;
			if ( hasActionExhaustion ) return false;
			if ( buffs.cannotAttack ) return false;
			if ( game.globalBuffs.getCannotAttack( card ) ) return false;
			return true;
		}
		public function get canRelocate():Boolean { 
			if ( hasSummonExhaustion ) return false;
			if ( hasActionExhaustion ) return false;
			if ( buffs.cannotRelocate ) return false;
			if ( game.globalBuffs.getCannotRelocate( card ) ) return false;
			return true;
		}
		
		public function get needTribute():Boolean { 
			if ( buffs.skipTribute ) return false;
			if ( game.globalBuffs.getSkipTribute( card ) ) return false;
			return propsC.isGrand;
		}
		
		public function get canBeTribute():Boolean
		///{ return !hasSummonExhaustion && !hasActionExhaustion }
		{ return !hasSummonExhaustion }
		
		// PROP VALUES
		
		public function get basePowerValue():int
		{ return propsC.basePower }
		
		public function get currentPowerValue():int
		{ return propsC.basePower + buffs.powerOffset + game.globalBuffs.getPowerOffset( card ) }
		
		// IN-HAND LOGIC
		
		public function maySummonOn( f:Field ):Boolean
		{ return propsC.summonCondition == null ? true : propsC.summonCondition( f ) }
		
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
		
		public function buffToString():String 
		{ return buffs.isEmpty as String }
		
		//
		public function toString():String 
		{
			return "N/A";
		}
	}

}