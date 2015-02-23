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
		
		private var _basePowerValue:int = 0;
		private var _realPowerValue:int = 0;
		private var _cannotAttack:Boolean;
		private var _cannotRelocate:Boolean;
		private var _canBeTribute:Boolean;
		private var _skipTribute:Boolean;
		
		public function get propsC():CreatureCardProperties
		{ return props as CreatureCardProperties }
		
		override public function initialize():void
		{
			super.initialize();
			this.buffs = new BuffManager( card );
		}
		
		override public function onGameProcess( p:GameplayProcess ):void
		{
			updateStatus();
			buffs.onGameProcess( p );
			
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
						processes.prepend_Death( card, false, null );
					}
				}
			}
			
		}
		
		private function updateStatus():void 
		{
			_basePowerValue = propsC.basePower;
			_realPowerValue = _basePowerValue + buffs.powerOffset + game.globalBuffs.getPowerOffset( card );
			_realPowerValue = _realPowerValue >= 0 ? _realPowerValue : 0;
			_cannotAttack = buffs.cannotAttack || game.globalBuffs.getCannotAttack( card );
			_cannotRelocate = buffs.cannotRelocate || game.globalBuffs.getCannotRelocate( card );
			_canBeTribute = !hasSummonExhaustion && !buffs.cannotBeTribute; /// && !hasActionExhaustion
			_skipTribute = buffs.skipTribute || game.globalBuffs.getSkipTribute( card );
		}
		
		public function onLeavePlay():void
		{
			reset();
			buffs.removeAllWeak();
			card.history.tribute = null;
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
			if ( _cannotAttack ) return false;
			return true;
		}
		
		public function get canRelocate():Boolean { 
			if ( hasSummonExhaustion ) return false;
			if ( hasActionExhaustion ) return false;
			if ( _cannotRelocate ) return false;
			return true;
		}
		
		public function get needTribute():Boolean { 
			if ( _skipTribute ) return false;
			return propsC.isGrand;
		}
		
		public function get canBeTribute():Boolean
		{ return _canBeTribute }
		
		// PROP VALUES
		
		public function get basePowerValue():int
		{ return _basePowerValue }
		
		public function get realPowerValue():int
		{ return _realPowerValue }
		
		//
		
		public function canBeSummonedOn( f:Field, manually:Boolean ):Boolean
		{ 
			if ( manually )
				return propsC.summonConditionManual == null ? true : propsC.summonConditionManual( f );
			else
				return propsC.summonConditionAutomatic == null ? true : propsC.summonConditionAutomatic( f );
		}
		
		// COMBAT LOGIC
		
		public function generateAttackDamage():Damage
		{ return new Damage( realPowerValue, DamageType.COMBAT, card ) }
		
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
		
		public function addNewBuff( weak:Boolean = false ):Buff
		{ 
			var b:Buff = new Buff( weak );
			buffs.addBuff( b );
			return b;
		}
		
		public function addBuff( b:Buff ):void
		{ buffs.addBuff( b ) }
		
		public function removeBuff( b:Buff ):void
		{ buffs.removeBuff( b ) }
		
		public function buffsToString():String 
		{ return buffs.isEmpty as String }
		
		//
		public function toString():String 
		{
			return "N/A";
		}
	}

}