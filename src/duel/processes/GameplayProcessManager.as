package duel.processes
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.cards.GameplayFAQ;
	import duel.Damage;
	import duel.DamageType;
	import duel.display.animation;
	import duel.Game;
	import duel.gameplay.DeathType;
	import duel.otherlogic.SpecialEffect;
	import duel.players.Player;
	import duel.table.CreatureField;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import flash.geom.Point;
	
	use namespace animation;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class GameplayProcessManager extends ProcessManager
	{
		//{ TURN LOGIC
		
		public function append_TurnEnd( p:Player ):void
		{
			var pro:GameplayProcess;
			
			/// TURN_END
			pro = chain( pro, gen( GameplayProcess.TURN_END, p ) );
			pro.onEnd = function turnEnd( p:Player ):void
			{
				append_TurnStart( p.opponent );
				p.mana.raiseCap();
			}
		}
		
		public function append_TurnStart( p:Player ):void
		{
			var pro:GameplayProcess;
			
			/// TURN_START
			pro = chain( pro, gen( GameplayProcess.TURN_START, p ) );
			pro.delay = .333;
			
			pro.onStart = 
			function onStart( p:Player ):void
			{
				game.setCurrentPlayer( p );
				p.mana.refill();
			}
			
			pro.onEnd = 
			function onEnd( p:Player ):void
			{
				prepend_Draw( p, 1 );
			}
			
			/// TURN_START_COMPLETE
			pro = chain ( pro, gen( GameplayProcess.TURN_START_COMPLETE, p ) );
			pro.delay = .333;
		}
		
		public function prepend_SpendMana( p:Player, amount:int ):void
		{
			var pro:GameplayProcess;
			
			/// TURN_START
			pro = chain( pro, gen( GameplayProcess.SPEND_MANA, p ) );
			pro.onEnd = 
			function onEnd( p:Player ):void
			{
				p.mana.decrease( amount );
			}
			
			/// TURN_START_COMPLETE
			pro = chain ( pro, gen( GameplayProcess.SPEND_MANA_COMPLETE, p ) );
		}
		
		//}
		//{ DRAW & DISCARD
		
		public function prepend_Draw( p:Player, count:int = 1, isManual:Boolean = false ):void
		{
			var pro:GameplayProcess;
			while ( --count >= 0 )
			{
				/// SiNGLE DRAW_CARD
				pro = chain( pro, gen( GameplayProcess.DRAW_CARD, p, isManual ) );
				pro.onStart = onStart;
				pro.onEnd = onEnd;
				pro.delay = NaN;
			}
			
			function onStart( p:Player, isManual:Boolean ):void
			{
				if ( isManual )
					prepend_SpendMana( p, 1 );
			}
			
			function onEnd( p:Player, isManual:Boolean ):void 
			{
				if ( p.deck.isEmpty )
				{
					prepend_DirectDamage( p, new Damage( 1, DamageType.SPECIAL, null ) );
					return;
				}
				
				var c:Card = p.deck.getFirstCard();
				p.deck.removeCard( c );
				
				/// SiNGLE DRAW_CARD_COMPLETE
				
				var proComplete:GameplayProcess = gen( GameplayProcess.DRAW_CARD_COMPLETE, p, isManual, c );
				proComplete.delay = NaN;
				prependProcess( proComplete );
				prepend_AddToHand( c, p );
			}
		}
		
		public function prepend_Discard( p:Player, c:Card ):void 
		{
			var pro:GameplayProcess;
			
			/// DISCARD_CARD
			pro = chain( pro, gen( GameplayProcess.DISCARD_CARD, p, c ) );
			
			pro.abortCheck = 
			function abortCheck( p:Player, c:Card ):Boolean
			{
				return !p.hand.containsCard( c );
			}
			
			pro.onEnd = 
			function discardCard( p:Player, c:Card ):void
			{
				p.hand.removeCard( c );
				prepend_AddToGrave( c );
			}
				
			/// DISCARD_CARD_COMPLETE
			pro = chain ( pro, gen( GameplayProcess.DISCARD_CARD_COMPLETE, p, c ) );
		}
		
		//}
		//{ SUMMON
		
		public function append_SummonHere( c:Card, field:CreatureField, isManual:Boolean ):void
		{
			var pro:GameplayProcess;
			
			/// SUMMON - step 1
			pro = chain( pro, gen( GameplayProcess.SUMMON, c, field, isManual ) );
			pro.onStart = 
			function onStart( c:Card, field:CreatureField, isManual:Boolean ):void
			{
				if ( isManual )
					prepend_SpendMana( c.controller, c.cost );
			}
			pro.abortCheck = 
			function abortCheck( c:Card, field:CreatureField, isManual:Boolean ):Boolean
			{
				if ( c.isInPlay ) return true;
				if ( field.isLocked ) return true;
				if ( isManual && c.statusC.needTribute && field.topCard == null ) return true;
				return false;
			}
			
			/// SUMMON - step 2
			pro = chain( pro, gen( GameplayProcess.SUMMON, c, field, isManual ) );
			pro.onStart = 
			function onStart( c:Card, field:CreatureField, isManual:Boolean ):void
			{
				/// TRIBUTE_CREATURE
				if ( isManual && c.statusC.needTribute )
					if ( field.topCard == null )
						throw new Error( "Where's my tribute?" );
				if ( !isManual || c.statusC.needTribute )
					if ( field.topCard != null )
						prepend_TributeCreature( field.topCard, true, c );
			}
			pro.abortCheck = 
			function abortCheck( c:Card, field:CreatureField, isManual:Boolean ):Boolean
			{
				if ( c.isInPlay ) return true;
				if ( field.isLocked ) return true;
				return false;
			}
			
			/// ENTER_PLAY
			pro = chain( pro, process_EnterPlay( c, field, isManual && c.propsC.isFlippable ) );
			
			/// SUMMON_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SUMMON_COMPLETE, c, field, isManual ) );
			pro.delay = isManual ? .250 : NaN;
			pro.abortable = true; //was false by default, cuz' "complete"
			pro.abortCheck =
			function completeAbortCheck( c:Card, field:CreatureField, isManual:Boolean ):Boolean
			{
				return !c.isInPlay;
			}
			pro.onStart = 
			function complete( c:Card, field:CreatureField, isManual:Boolean ):void
			{
				if ( !c.isInPlay ) return;
				c.statusC.hasSummonExhaustion = true;
				c.sprite.animSummon();
				game.jugglerGui.addFakeTime( isManual ? .250 : 0.017 );
			}
			
		}
		
		private function prepend_TributeCreature( c:Card, isForGrand:Boolean, cause:Card ):GameplayProcess 
		{
			var pro:GameplayProcess;
			
			/// TRIBUTE_CREATURE
			pro = chain( pro, gen( GameplayProcess.TRIBUTE_CREATURE, c, isForGrand, cause ) );
			pro.abortCheck =
			function completeAbortCheck( c:Card, isForGrand:Boolean, cause:Card ):Boolean
			{
				return !c.isInPlay;
			}
			pro.onEnd = 
			function onEnd( c:Card, isForGrand:Boolean, cause:Card ):void 
			{
				prepend_Death( c, DeathType.TRIBUTE, cause );
			}
			
			/// TRIBUTE_CREATURE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.TRIBUTE_CREATURE_COMPLETE, c, isForGrand, cause ) );
			pro.onEnd =
			function onEnd( c:Card, isForGrand:Boolean, cause:Card ):void 
			{
				if ( isForGrand ) 
					cause.history.tribute = c;
			}
			
			/// returns TRIBUTE_CREATURE (the chain head)
			return pro;
		}
		
		
		public function prepend_ResurrectHere( c:Card, field:CreatureField, cause:Card ):void
		{
			var pro:GameplayProcess;
			
			/// RESURRECT
			pro = chain( pro, gen( GameplayProcess.RESURRECT, c, field ) );
			pro.onStart =
			function onStart( c:Card, field:CreatureField ):void
			{
				if ( field.topCard != null )
					prepend_Death( field.topCard, DeathType.SPECIAL, cause );
			}
			pro.onEnd = 
			function onEnd( c:Card, field:CreatureField ):void
			{
				c.lot.removeCard( c );
				
				/// SUMMON
				append_SummonHere( c, field, false );
			}
			pro.abortCheck = 
			function abortCheck( c:Card, field:CreatureField ):Boolean
			{
				if ( !c.isInGrave ) return true;
				if ( field.isLocked ) return true;
				if ( !field.isEmpty ) return true;
				return false;
			}
			pro.onAbort = 
			function onAbort( c:Card, field:CreatureField ):void
			{
				if ( c.isInPlay )
					prepend_AddToGrave( c );
			}
			
			/// RESURRECT_COMPLETE
			pro = chain( pro, gen( GameplayProcess.RESURRECT_COMPLETE, c, field ) );
		}
		
		//}
		//{ RELOCATION
		
		/** Move creature card/stack from one field to another. Usually costs the creature one action
		 * @param	c		creature to be relocated
		 * @param	field	destination field
		 * @param	free	if true, this relocation will not exhaust the creauture for the turn
		 */
		public function append_Relocation( c:Card, field:CreatureField, free:Boolean ):void
		{
			/// DO SWAP INSTEAD?
			if ( c.statusC.hasSwap && field.topCard != null )
			{
				append_SwapRelocation( c, field, free );
				return;
			}
			
			var pro:GameplayProcess;
			var oldField:CreatureField = c.indexedField as CreatureField;
			
			/// RELOCATE
			pro = chain( pro, gen( GameplayProcess.RELOCATE, c, field, free ) );
			pro.abortCheck = GameplayFAQ.cannotRelocateHere;
			pro.onStart = 
			function onStart( c:Card, field:CreatureField, free:Boolean ):void
			{
				c.sprite.animRelocation();
			}
			pro.onAbort = completeOrAbort;
			
			/// LEAVE_INDEXED_FIELD
			pro = chain( pro, process_LeaveIndexedField( c ) );
			
			/// ENTER_INDEXED_FIELD
			pro = chain( pro, process_EnterIndexedField( c, field, false ) );
			
			/// RELOCATE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.RELOCATE_COMPLETE, c, field, free ) );
			pro.onEnd = completeOrAbort;
			
			/// /// ///
			function completeOrAbort( c:Card, field:CreatureField, free:Boolean ):void {
				if ( c.isInPlay )
				{
					if ( c.lot == null )
					{
						CONFIG::development
						{ error( "RELOCATION ERROR: c.lot is NULL" ) }
						prependProcess( process_EnterIndexedField( c, oldField, c.faceDown ) );
					}
						
					c.sprite.animRelocationCompleteOrAbort();
					
					if ( !free )
						c.statusC.actionsRelocate++;
				}
			}
			
			if ( c.faceDown )
				/// SAFE_FLIP
				prepend_SafeFlip( c );
		}
		
		public function append_SwapRelocation( c:Card, field:CreatureField, free:Boolean ):void
		{
			var pro:GameplayProcess;
			var oldField:CreatureField = c.indexedField as CreatureField;
			var swappee:Card = field.topCard;
			
			/// RELOCATE
			pro = chain( pro, gen( GameplayProcess.RELOCATE, c, field, free ) );
			pro.abortCheck = GameplayFAQ.cannotSwapHere;
			pro.onStart = 
			function onStart( c:Card, field:CreatureField, free:Boolean ):void
			{
				c.sprite.animRelocation();
				swappee.sprite.animRelocation();
			}
			pro.onAbort = completeOrAbort;
			
			/// LEAVE_INDEXED_FIELD
			pro = chain( pro, process_LeaveIndexedField( c ) );
			pro = chain( pro, process_LeaveIndexedField( swappee ) );
			
			/// ENTER_INDEXED_FIELD
			pro = chain( pro, process_EnterIndexedField( c, field, false ) );
			pro = chain( pro, process_EnterIndexedField( swappee, oldField, false ) );
			pro.delay = .033;
			
			/// RELOCATE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.RELOCATE_COMPLETE, c, field, free ) );
			pro.onEnd = completeOrAbort;
			
			/// /// ///
			function completeOrAbort( c:Card, field:CreatureField, free:Boolean ):void {
				if ( c.isInPlay )
				{
					c.sprite.animRelocationCompleteOrAbort();
					swappee.sprite.animRelocationCompleteOrAbort();
					if ( !free )
						c.statusC.actionsRelocate++;
				}
			}
			
			if ( c.faceDown )
				/// SAFE_FLIP
				prepend_SafeFlip( c );
		}
		
		//}
		//{ TRAPS
		
		public function append_TrapSet( c:Card, field:TrapField, isManual:Boolean ):void 
		{
			var pro:GameplayProcess;
			
			/// SET_TRAP
			pro = chain( pro, gen( GameplayProcess.SET_TRAP, c, field ) );
			pro.onStart = 
			function onStart( c:Card, field:TrapField ):void
			{
				if ( field.topCard )
					/// DESTROY OLD TRAP
					prepend_DestroyTrap( field.topCard, null );
					
				if ( isManual )
					prepend_SpendMana( c.controller, c.cost );
			}
			pro.abortCheck = GameplayFAQ.cannotPlaceTrapHere;
			pro.onAbort = onAbort;
			function onAbort( c:Card, field:TrapField ):void
			{
				if ( c.isInPlay )
					prepend_DestroyTrap( c, null );
			}
			
			/// ENTER_PLAY
			pro = chain( pro, process_EnterPlay( c, field, true ) );
			
			/// SET_TRAP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SET_TRAP_COMPLETE, c, field ) );
			pro.delay = isManual ? .150 : NaN;
			pro.onEnd = 
			function complete( c:Card, field:TrapField ):void
			{
				game.jugglerGui.addFakeTime( isManual ? .150 : 0.017 );
			}
		}
		
		public function prepend_TrapActivation( c:Card ):void
		{
			var interruptedProcess:GameplayProcess = currentProcess as GameplayProcess;
			var pro:GameplayProcess;
			
			/// ACTIVATE_TRAP (PREPARE)
			pro = chain( pro, gen( GameplayProcess.ACTIVATE_TRAP, c ) );
			pro.onStart = onStart;
			pro.onEnd = onEnd1;
			pro.onAbort = onAbort;
			pro.abortCheck = GameplayFAQ.isNotInPlay;
			
			function onStart( c:Card ):void
			{
				c.propsT.effect.isActive = true;
				c.propsT.effect.isBusy = true;
				c.faceDown = false;
				game.jugglerStrict.addFakeTime( .360 );
				trace ( c + " interrupted process " + interruptedProcess );
			}
			function onEnd1( c:Card ):void
			{
				c.sprite.animFlipEffect();
			}
			
			/// ACTIVATE_TRAP (EFFECT)
			pro = chain( pro, gen( GameplayProcess.ACTIVATE_TRAP, c ) );
			pro.delay = .033;
			pro.onEnd = onEnd2;
			pro.onAbort = onAbort;
			pro.abortCheck = GameplayFAQ.isNotInPlay;
			
			function onEnd2( c:Card ):void
			{
				c.propsT.effect.isBusy = false;
				if ( !c.propsT.effect.watcherActivate.funcCondition( interruptedProcess ) )
					return;
				c.propsT.effect.watcherActivate.funcEffect( interruptedProcess );
			}
			
			function onAbort( c:Card ):void
			{
				c.propsT.effect.isActive = false;
				c.propsT.effect.isBusy = false;
				if ( c.isInPlay )
					prepend_AddToGrave( c );
			}
			
			/// ACTIVATE_TRAP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ACTIVATE_TRAP_COMPLETE, c ) );
			pro.onEnd =
			function onComplete( c:Card ):void
			{
				if ( c.isInPlay && !c.propsT.isPersistent )
					prepend_AddToGrave( c );
			}
		}
		
		public function prepend_DestroyTrap( c:Card, cause:Card ):void
		{
			var pro:GameplayProcess;

			/// DESTROY_TRAP
			pro = chain( pro, gen( GameplayProcess.DESTROY_TRAP, c, cause ) );
			pro.onStart =
			function onStart( c:Card, cause:Card ):void
			{
				if ( !c.faceDown )
					c.sprite.animDeactivateTrap();
			}
			
			/// DESTROY_TRAP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.DESTROY_TRAP_COMPLETE, c, cause ) );
			pro.onEnd =
			function complete( c:Card, cause:Card ):void 
			{
				if ( c.owner != null )
					prepend_AddToGrave( c );
				else
					prepend_RelinquishToken( c );
			}
		}
		
		//}
		//{ SPECIAL EFFECTS
		
		public function prepend_TriggerSpecial( c:Card, special:SpecialEffect  ):void 
		{
			var interruptedProcess:GameplayProcess = currentProcess as GameplayProcess;
			var pro:GameplayProcess;
			
			/// ACTIVATE_SPECIAL
			pro = chain( pro, gen( GameplayProcess.ACTIVATE_SPECIAL, c ) );
			pro.delay = .200;
			pro.abortable = true;
			pro.abortCheck = abortCheck;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			pro.onAbort = special.finishActivation;
			
			function onStart( c:Card ):void
			{
				special.startActivation();
				c.lot.moveCardToTop( c );
				c.sprite.animSpecialEffect();
				
				game.jugglerStrict.addFakeTime( .400 );
				
				if ( c.faceDown )
					/// SILENT_FLIP
					prepend_SilentFlip( c );
				
				trace ( c + " interrupted process " + interruptedProcess );
			}
			function onEnd( c:Card ):void
			{
				if ( !special.isAllowedInField( c.lot.type ) ) return;
				if ( !special.meetsCondition( interruptedProcess ) ) return;
				special.performEffect( interruptedProcess );
			}
			function abortCheck( c:Card ):Boolean
			{ 
				return !special.isAllowedInField( c.lot.type ) ||
					!special.meetsCondition( interruptedProcess );
			}
			
			/// ACTIVATE_SPECIAL_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ACTIVATE_SPECIAL_COMPLETE, c ) );
			pro.delay = .400;
			pro.abortable = false;
			pro.onEnd = special.finishActivation;
		}
		
		//}
		//{ ATTACK
		
		public function append_Attack( c:Card, free:Boolean ):void
		{
			var pro:GameplayProcess;
			
			/// ATTACK (step 1_
			pro = chain( pro, gen( GameplayProcess.ATTACK, c, free ) );
			pro.onStart =
			function onStart( c:Card, free:Boolean ):void
			{
				c.sprite.animAttackPrepare();
			}
			pro.onEnd =
			function onEnd( c:Card, free:Boolean ):void
			{
				if ( c.indexedField.opposingCreature == null ) return;
				if ( !c.indexedField.opposingCreature.faceDown ) return;
				prepend_CombatFlip( c.indexedField.opposingCreature );
			}
			pro.onAbort = onAbort;
			pro.abortCheck = GameplayFAQ.cannotPerformAttack;
			
			/// ATTACK (step 2)
			pro = chain( pro, gen( GameplayProcess.ATTACK, c, free ) );
			pro.onEnd =
			function onEnd( c:Card, free:Boolean ):void
			{
				c.sprite.animAttackPerform();
				
				if ( c.indexedField.opposingCreature == null )
				{
					prepend_DirectDamage( c.controller.opponent, c.statusC.generateAttackDamage() );
				}
				else
				{
					c.indexedField.opposingCreature.sprite.animAttackPerform();
					prepend_CreatureDamage( c, c.indexedField.opposingCreature.statusC.generateAttackDamage() );
					prepend_CreatureDamage( c.indexedField.opposingCreature, c.statusC.generateAttackDamage() );
				}
			}
			pro.onAbort = onAbort;
			pro.abortCheck = GameplayFAQ.cannotPerformAttack;
			
			function onAbort():void
			{
				c.sprite.animAttackAbort();
				completeOrAbort( c, free );
				prependProcess( gen( GameplayProcess.ATTACK_ABORT, c, free ) );
			}
			
			/// ATTACK_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ATTACK_COMPLETE, c, free ) );
			pro.onStart = completeOrAbort;
			
			/// /// ///
			function completeOrAbort( c:Card, free:Boolean ):void
			{
				if ( !free )
					c.statusC.actionsAttack++;
			}
			
			if ( c.faceDown )
				/// SAFE_FLIP
				prepend_SafeFlip( c );
		}
		
		//}
		//{ DAMAGE & DEATH
		
		private function prepend_CreatureDamage( c:Card, dmg:Damage ):void
		{
			var pro:GameplayProcess;
			
			/// CREATURE_DAMAGE
			pro = chain( pro, gen( GameplayProcess.CREATURE_DAMAGE, c, dmg ) );
			pro.onStart =
			function onStart( c:Card, dmg:Damage ):void
			{
				if ( c.faceDown )
					prepend_SilentFlip( c );
			}
			pro.onEnd =
			function onEnd( c:Card, dmg:Damage ):void
			{
				if ( !c.isInPlay ) 
					return;
				
				if ( c.statusC.realPowerValue <= dmg.amount )
				{
					prepend_Death( c,
						dmg.type == DamageType.COMBAT ? DeathType.COMBAT : DeathType.SPECIAL,
						dmg.source as Card );
					game.showFloatyText( c.sprite.localToGlobal( new Point() ), 
						c.statusC.realPowerValue + "-" + dmg.amount + "=DEATH!", 0xFF0000 );
				}
				else
				{
					c.sprite.animDamageOnly();
					game.showFloatyText( c.sprite.localToGlobal( new Point() ), 
						c.statusC.realPowerValue + "-" + dmg.amount + "=" + (c.statusC.realPowerValue - dmg.amount), 0x00FFFF );
				}
			}
			pro.onAbort =
			function onAbort( c:Card, dmg:Damage ):void
			{
				if ( c.isInPlay )
					c.sprite.animDamageAbort();
			}
			pro.abortCheck = GameplayFAQ.cannotTakeDamage;
			
			/// CREATURE_DAMAGE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.CREATURE_DAMAGE_COMPLETE, c, dmg ) );
		}
		
		public function prepend_DirectDamage( p:Player, dmg:Damage ):void
		{
			var pro:GameplayProcess;
			
			/// DIRECT_DAMAGE
			pro = chain( pro, gen( GameplayProcess.DIRECT_DAMAGE, p, dmg ) );
			pro.onEnd =
			function onEnd( p:Player, dmg:Damage ):void
			{
				p.takeDirectDamage( dmg.amount );
				if ( dmg.amount > 0 )
				{
					const CLR1:uint = 0xAA0011;
					const CLR2:uint = 0x220011;
					const REV:Boolean = game.p2 == p;
					game.blink( REV ? CLR1 : CLR2, REV ? CLR2 : CLR1 );
				}
			}
			pro.abortCheck = 
			function abortCheck( p:Player, dmg:Damage ):Boolean
			{ 
				return dmg.type == DamageType.HEALING;
			}
			pro.onAbort = 
			function onAbort( p:Player, dmg:Damage ):void
			{
				if ( dmg.type == DamageType.HEALING )
					prepend_Heal( p, dmg.amount );
			}
			
			/// DIRECT_DAMAGE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.DIRECT_DAMAGE_COMPLETE, p, dmg ) );
		}
		
		public function prepend_Heal( p:Player, amount:int ):void
		{
			var pro:GameplayProcess;
			
			/// DIRECT_DAMAGE
			pro = chain( pro, gen( GameplayProcess.HEAL_LP, p, amount ) );
			pro.onEnd =
			function onEnd( p:Player, amount:int ):void
			{
				p.heal( amount );
				if ( amount > 0 )
				{
					const CLR1:uint = 0x004422; // 0x66FFFF 
					const CLR2:uint = 0x000011; // 0x003322 
					const REV:Boolean = game.p2 == p;
					game.blink( REV ? CLR1 : CLR2, REV ? CLR2 : CLR1 );
				}
			}
			
			/// DIRECT_DAMAGE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.HEAL_LP_COMPLETE, p, amount ) );
		}
		
		public function prepend_Death( c:Card, deathType:DeathType, cause:Card ):void 
		{
			var pro:GameplayProcess;

			/// DIE
			pro = chain( pro, gen( GameplayProcess.DIE, c, deathType, cause ) );
			pro.onStart =
			function onStart( c:Card, deathType:DeathType, cause:Card ):void
			{
				if ( c.faceDown )
					prepend_SilentFlip( c, deathType == DeathType.SPECIAL );
			}
			pro.onEnd =
			function onEnd( c:Card, deathType:DeathType, cause:Card ):void
			{
				if ( deathType == DeathType.COMBAT )
					c.sprite.animDieCombat();
				else
				if ( deathType == DeathType.TRIBUTE )
					c.sprite.animDieTribute();
				else
					c.sprite.animDieNonCombat();
			}
			pro.abortCheck = GameplayFAQ.cannotDie;
			
			/// DIE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.DIE_COMPLETE, c, deathType, cause ) );
			pro.onStart =
			function complete( c:Card, deathType:DeathType, cause:Card ):void 
			{
				if ( c.owner != null )
					prepend_AddToGrave( c );
				else
					prepend_RelinquishToken( c );
			}
		}
		
		public function prepend_RelinquishToken( c:Card ):void 
		{
			var pro:GameplayProcess;

			/// DIE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.RELINQUISH_TOKEN, c ) );
			pro.onStart =
			function complete( c:Card ):void 
			{
				c.lot.removeCard( c );
				c.sprite.animFadeToNothing( true );
			}
		}
		
		//}
		//{ COMBAT FLIP & SAFE FLIP & MAGIC FLIP
		
		private function prepend_CombatFlip( c:Card ):void
		{
			var pro:GameplayProcess;
			
			/// COMBAT_FLIP
			pro = chain( pro, gen( GameplayProcess.COMBAT_FLIP, c ) );
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				game.jugglerStrict.addFakeTime( .330 );
			}
			pro.abortCheck = GameplayFAQ.cannotFlipInPlay;
			
			/// COMBAT_FLIP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.COMBAT_FLIP_COMPLETE, c ) );
			
			/// /// /// /// /// /// /// /// /// /// /// ///
			if ( !c.statusC.canDoCombatFlipEffect ) return;
			/// /// /// /// /// /// /// /// /// /// /// ///
			
			/// COMBAT_FLIP_EFFECT
			pro = chain( pro, gen( GameplayProcess.COMBAT_FLIP_EFFECT, c ) );
			pro.onStart =
			function effectStart( c:Card ):void
			{
				c.sprite.animFlipEffect();
				game.jugglerStrict.addFakeTime( .660 );
			}
			pro.onEnd =
			function effectEnd( c:Card ):void
			{
				c.statusC.onCombatFlip();
			}
			pro.abortCheck = 
			function effectAbortCheck( c:Card ):Boolean
			{
				return !c.isInPlay || !c.statusC.canDoCombatFlipEffect;
			}
			
			/// COMBAT_FLIP_EFFECT_COMPLETE
			pro = chain( pro, gen( GameplayProcess.COMBAT_FLIP_EFFECT_COMPLETE, c ) )
			pro.delay = .500;
		}
		
		public function prepend_SafeFlip( c:Card ):void
		{
			var pro:GameplayProcess;
			
			/// SAFE_FLIP
			pro = chain( pro, gen( GameplayProcess.SAFE_FLIP, c ) );
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				game.jugglerStrict.addFakeTime( .330 );
			}
			pro.abortCheck = GameplayFAQ.cannotFlipInPlay;
			
			/// SAFE_FLIP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SAFE_FLIP_COMPLETE, c ) );
			
			/// /// /// /// /// /// /// /// /// /// /// ///
			if ( !c.statusC.canDoSafeFlipEffect ) return;
			/// /// /// /// /// /// /// /// /// /// /// ///
			
			/// SAFE_FLIP_EFFECT
			pro = chain( pro, gen( GameplayProcess.SAFE_FLIP_EFFECT, c ) );
			pro.onStart =
			function effectStart( c:Card ):void
			{
				c.sprite.animFlipEffect();
				game.jugglerStrict.addFakeTime( .660 );
			}
			pro.onEnd =
			function effectEnd( c:Card ):void
			{
				c.statusC.onSafeFlip();
			}
			pro.abortCheck = 
			function effectAbortCheck( c:Card ):Boolean
			{
				return !c.isInPlay || !c.statusC.canDoSafeFlipEffect;
			}
			
			/// SAFE_FLIP_EFFECT_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SAFE_FLIP_EFFECT_COMPLETE, c ) );
			pro.delay = .500;
		}
		
		public function prepend_SilentFlip( c:Card, quick:Boolean = false ):void
		{
			
			var pro:GameplayProcess;

			/// SILENT_FLIP
			pro = chain( pro, gen( GameplayProcess.SILENT_FLIP, c ) );
			pro.abortable = false;
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				game.jugglerStrict.addFakeTime( quick ? .067 : .440 );
			}
			
			/// SILENT_FLIP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SILENT_FLIP_COMPLETE, c ) );
			pro.abortable = false;
		}
		
		//}
		//{ CHAINGING CARD CONTAINERS I   ( ADD   TO   GRAVE / HAND / DECK )
		
		public function prepend_AddToGrave( c:Card ):void 
		{
			if ( c.props.isToken )
			{
				prepend_RelinquishToken( c );
				return;
			}
			
			var pro:GameplayProcess;
			
			if ( c.isInPlay )
				/// LEAVE_PLAY
				pro = chain( pro, process_LeavePlay( c ) );
			
			/// ENTER_GRAVE
			pro = chain( pro, gen( GameplayProcess.ENTER_GRAVE, c ) );
			pro.onStart =
			function onStart( c:Card ):void
			{
				if ( c.lot != null )
					c.lot.removeCard( c )
			}
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				c.owner.grave.addCard( c );
			}
			pro.abortCheck = 
			function abortCheck( c:Card ):Boolean
			{
				return c.isInGrave;
			}
			
			/// ENTER_GRAVE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ENTER_GRAVE_COMPLETE, c ) );
		}
		
		public function prepend_AddToHand( c:Card, p:Player ):void 
		{
			if ( c.props.isToken )
			{
				prepend_RelinquishToken( c );
				return;
			}
			
			var pro:GameplayProcess;
			
			if ( c.isInPlay )
				/// LEAVE_PLAY
				pro = chain( pro, process_LeavePlay( c ) );
			
			/// ENTER_HAND
			pro = chain( pro, gen( GameplayProcess.ENTER_HAND, c, p ) );
			pro.delay = NaN;
			pro.onEnd =
			function onEnd( c:Card, p:Player ):void 
			{
				p.hand.addCard( c );
				c.faceDown = !p.controllable;
			}
			pro.abortCheck = 
			function abortCheck( c:Card, p:Player ):Boolean
			{
				return p.hand.containsCard( c );
			}
			
			/// ENTER_HAND_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ENTER_HAND_COMPLETE, c, p ) );
			pro.delay = NaN;
		}
		
		public function prepend_AddToDeck( c:Card, p:Player, faceDown:Boolean, shuffle:Boolean ):void 
		{
			if ( c.props.isToken )
			{
				prepend_RelinquishToken( c );
				return;
			}
			
			var pro:GameplayProcess;
			
			if ( c.isInPlay )
				/// LEAVE_PLAY
				pro = chain( pro, process_LeavePlay( c ) );
			
			/// ENTER_DECK
			pro = chain( pro, gen( GameplayProcess.ENTER_DECK, c, p ) );
			pro.delay = NaN;
			pro.onStart =
			pro.onEnd =
			function onEnd( c:Card, p:Player ):void 
			{
				p.deck.addCard( c );
				c.faceDown = faceDown;
			}
			pro.onAbort =
			pro.abortCheck = 
			function abortCheck( c:Card, p:Player ):Boolean
			{
				return p.deck.containsCard( c );
			}
			
			/// ENTER_DECK_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ENTER_DECK_COMPLETE, c, p ) );
			pro.delay = NaN;
			
			if ( shuffle )
			{
				CONFIG::development { throw UninitializedError( "Deck shuffling not yet implemented" ) }
				return;
			}
		}
		
		//}
		//{ CHAINGING CARD CONTAINERS II   ( ENTER / LEAVE   PLAY / FIELD )
		
		private function process_EnterPlay( c:Card, field:IndexedField, faceDown:Boolean ):GameplayProcess 
		{
			var pro:GameplayProcess;
			
			/// ENTER_PLAY
			pro = gen( GameplayProcess.ENTER_PLAY, c );
			pro.abortable = false;
			
			pro
				/// ENTER_INDEXED_FIELD
				.chain( process_EnterIndexedField( c, field, faceDown ) )
				/// ENTER_PLAY_COMPLETE
				.chain( gen( GameplayProcess.ENTER_PLAY_COMPLETE, c, field ) );
			
			/// returns ENTER_PLAY (the chain head)
			return pro;
		}
		
		private function process_LeavePlay( c:Card ):GameplayProcess 
		{
			var pro:GameplayProcess;
			
			/// LEAVE_PLAY
			pro = gen( GameplayProcess.LEAVE_PLAY, c );
			pro.abortCheck = GameplayFAQ.isNotInPlay;
			pro.onStart =
			function onStart( c:Card ):void 
			{
				if ( c.propsT && c.propsT.isPersistent && c.propsT.effect.isActive )
				{
					c.propsT.effect.isActive = false;
					c.propsT.effect.watcherDeactivate.funcEffect( null );
				}
			}
			
			pro
				/// LEAVE_INDEXED_FIELD
				.chain( process_LeaveIndexedField( c ) )
				/// LEAVE_PLAY_COMPLETE
				.chain( gen( GameplayProcess.LEAVE_PLAY_COMPLETE, c ) )
				.onEnd = complete;
			
			function complete( c:Card ):void 
			{
				if ( c.isCreature )
					c.statusC.onLeavePlay();
			}
			
			/// returns LEAVE_PLAY (the chain head)
			return pro;
		}
		
		private function process_EnterIndexedField( c:Card, field:IndexedField, faceDown:Boolean ):GameplayProcess 
		{
			var pro:GameplayProcess;

			/// ENTER_INDEXED_FIELD
			pro = gen( GameplayProcess.ENTER_INDEXED_FIELD, c, field );
			pro.delay = .015;
			pro.abortable = false;
			pro.onEnd =
			function onEnd( c:Card, field:IndexedField ):void 
			{
				field.addCard( c );
				c.faceDown = faceDown;
			}
			
			/// ENTER_INDEXED_FIELD_COMPLETE
			chain( pro, gen( GameplayProcess.ENTER_INDEXED_FIELD_COMPLETE, c, field ) );
			
			/// returns ENTER_INDEXED_FIELD (the chain head)
			return pro;
		}
		
		private function process_LeaveIndexedField( c:Card ):GameplayProcess 
		{
			var pro:GameplayProcess;

			/// LEAVE_INDEXED_FIELD
			pro = gen( GameplayProcess.LEAVE_INDEXED_FIELD, c, c.indexedField );
			pro.onEnd = leave;
			function leave( c:Card, field:IndexedField ):void 
			{
				if ( !field.containsCard( c ) ) 
				{
					CONFIG::development 
					{ throw new Error( "process_LeaveIndexedField: !field.containsCard" ) }
					return;
				}
				c.indexedField.removeCard( c );
			}
			pro.abortCheck =
			function abortCheck( c:Card, field:IndexedField ):Boolean
			{
				return !field.containsCard( c );
			}
			
			/// LEAVE_INDEXED_FIELD_COMPLETE
			chain( pro, gen( GameplayProcess.LEAVE_INDEXED_FIELD_COMPLETE, c, c.indexedField ) );
			
			/// returns LEAVE_INDEXED_FIELD (the chain head)
			return pro;
		}
		
		//}
		
		public function prepend_PeekAt( c:Card ):void 
		{
			var pro:GameplayProcess;
			
			/// FLIP UP
			pro = chain( pro, gen( GameplayProcess.DELAY, c ) );
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
			}
			
			/// FLIP BACK DOWN
			pro = chain( pro, gen( GameplayProcess.DELAY, c ) );
			pro.delay = 1.730;
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.faceDown = true;
			}
		}
		
		public function prepend_Delay( time:Number ):void 
		{
			var pro:GameplayProcess;
			pro = gen( GameplayProcess.DELAY, time );
			pro.delay = time;
			prependProcess( pro );
		}
		
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\  \\
		////\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\  \\
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\  \\
		////\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\  \\
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\  \\
		
		//{
		public function chain( prev:Process, next:Process ):GameplayProcess
		{
			if ( prev != null ) {
				while ( prev.next != null ) 
					prev = prev.next;
				
				prev.next = next;
			}
			else
				prependProcess( next )
			
			while ( next.next != null ) 
				next = next.next;
			
			return next as GameplayProcess;
		}
		
		public static function gen( name:String, ...args ):GameplayProcess
		{
			var p:GameplayProcess = new GameplayProcess();
			p.name = name;
			p.args = args;
			p.abortable = name.substr( -8 ) != "Complete";
			return p;
		}
		
		protected function get game():Game { return Game.current }
		//}
		
	}

}