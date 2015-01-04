package duel.processes
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.cards.CommonCardQuestions;
	import duel.Damage;
	import duel.DamageType;
	import duel.display.animation;
	import duel.Game;
	import duel.otherlogic.SpecialEffect;
	import duel.Player;
	import duel.table.CreatureField;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import flash.geom.Point;
	
	use namespace animation;
	use namespace gameprocessing;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class GameplayProcessManager extends ProcessManager
	{
		//{ TURN LOGIC
		
		gameprocessing function append_TurnEnd( p:Player ):void
		{
			var pro:GameplayProcess;
			
			/// TURN_END
			pro = chain( pro, gen( GameplayProcess.TURN_END, p ) );
			pro.delay = .333;
			pro.onEnd = function turnEnd( p:Player ):void
			{
				append_TurnStart( p.opponent );
			}
		}
		
		gameprocessing function append_TurnStart( p:Player ):void
		{
			var pro:GameplayProcess;
			
			/// TURN_START
			pro = chain( pro, gen( GameplayProcess.TURN_START, p ) );
			pro.delay = .333;
			
			pro.onStart = 
			function onStart( p:Player ):void
			{
				game.currentPlayer = p;
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
		
		//}
		//{ DRAW & DISCARD
		
		gameprocessing function prepend_Draw( p:Player, count:int = 1 ):void
		{
			var pro:GameplayProcess;
			while ( --count >= 0 )
			{
				/// SiNGLE DRAW_CARD
				pro = chain( pro, gen( GameplayProcess.DRAW_CARD, p ) );
				pro.onEnd = onComplete;
				pro.delay = NaN;
			}
			
			function onComplete( p:Player ):void 
			{
				if ( p.deck.isEmpty )
				{
					prepend_DirectDamage( p, new Damage( 1, DamageType.SPECIAL, null ) );
					return;
				}
				
				var c:Card = p.deck.getFirstCard();
				p.deck.removeCard( c );
				
				/// SiNGLE DRAW_CARD_COMPLETE
				
				var proComplete:GameplayProcess = gen( GameplayProcess.DRAW_CARD_COMPLETE, p, c );
				proComplete.delay = NaN;
				prependProcess( proComplete );
				prepend_AddToHand( c, p );
			}
		}
		
		gameprocessing function prepend_Discard( p:Player, c:Card ):void 
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
		
		gameprocessing function append_SummonHere( c:Card, field:CreatureField, isManual:Boolean ):void
		{
			var pro:GameplayProcess;
			
			/// SUMMON
			pro = chain( pro, gen( GameplayProcess.SUMMON, c, field ) );
			pro.onEnd = 
			function onEnd( c:Card, field:CreatureField ):void
			{
				/// TRIBUTE_CREATURE
				if ( isManual && c.statusC.needTribute )
				{
					if ( field.topCard == null )
					{
						CONFIG::development
						{ error( "Where's my tribute?" ) }
						return;
					}
					prepend_TributeCreature( field.topCard );
				}
			}
			pro.abortCheck = 
			function abortCheck( c:Card, field:CreatureField ):Boolean
			{
				if ( c.isInPlay ) return true;
				if ( field.isLocked ) return true;
				if ( isManual && c.statusC.needTribute && field.topCard == null ) return true;
				return false;
			}
			
			/// ENTER_PLAY
			pro = chain( pro, process_EnterPlay( c, field, c.propsC.startFaceDown ) );
			
			/// SUMMON_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SUMMON_COMPLETE, c, field ) );
			pro.abortable = true; //was false by default, cuz' "complete"
			pro.abortCheck =
			function completeAbortCheck( c:Card, field:CreatureField ):Boolean
			{
				return !c.isInPlay;
			}
			pro.onEnd = 
			function complete( c:Card, field:CreatureField ):void
			{
				c.summonedThisTurn = true;
				c.sprite.animSummon();
			}
			
		}
		
		private function prepend_TributeCreature( c:Card ):GameplayProcess 
		{
			var pro:GameplayProcess;
			
			/// TRIBUTE_CREATURE
			pro = chain( pro, gen( GameplayProcess.TRIBUTE_CREATURE, c ) );
			pro.abortCheck = CommonCardQuestions.isNotInPlay;
			pro.onEnd = 
			function onEnd( c:Card ):void 
			{
				c.resetState();
				prepend_Death( c );
			}
			
			/// TRIBUTE_CREATURE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.TRIBUTE_CREATURE_COMPLETE, c ) );
			
			/// returns TRIBUTE_CREATURE (the chain head)
			return pro;
		}
		
		
		gameprocessing function prepend_ResurrectHere( c:Card, field:CreatureField ):void	//TODO  USE THIS SHIT (zig&zag)
		{
			var pro:GameplayProcess;
			
			/// RESURRECT
			pro = chain( pro, gen( GameplayProcess.RESURRECT, c, field ) );
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
				return CommonCardQuestions.cannotPlaceCreatureHere( c, field );
			}
			pro.onAbort = 
			function onAbort( c:Card ):void
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
		gameprocessing function append_Relocation( c:Card, field:CreatureField, free:Boolean ):void
		{
			var pro:GameplayProcess;
			var oldField:CreatureField = c.indexedField as CreatureField;
			
			/// RELOCATE
			pro = chain( pro, gen( GameplayProcess.RELOCATE, c, field ) );
			pro.abortCheck = CommonCardQuestions.cannotRelocateHere;
			pro.onStart = 
			function onStart( c:Card, field:CreatureField ):void
			{
				c.sprite.animRelocation();
			}
			pro.onAbort = completeOrAbort;
			
			/// LEAVE_INDEXED_FIELD
			pro = chain( pro, process_LeaveIndexedField( c ) );
			
			/// ENTER_INDEXED_FIELD
			pro = chain( pro, process_EnterIndexedField( c, field, false ) );
			
			/// RELOCATE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.RELOCATE_COMPLETE, c, field ) );
			pro.onEnd = completeOrAbort;
			
			/// /// ///
			function completeOrAbort( c:Card, field:CreatureField ):void {
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
						c.actionsRelocate++;
				}
			}
			
			if ( c.faceDown )
				/// SAFE_FLIP
				prepend_SafeFlip( c );
		}
		
		//}
		//{ TRAPS
		
		gameprocessing function append_TrapSet( c:Card, field:TrapField, isManual:Boolean ):void 
		{
			var pro:GameplayProcess;
			
			/// SET_TRAP
			pro = chain( pro, gen( GameplayProcess.SET_TRAP, c, field ) );
			pro.onStart = 
			function onStart( c:Card, field:TrapField ):void
			{
				if ( field.topCard )
					/// DESTROY OLD TRAP
					prepend_DestroyTrap( field.topCard );
			}
			pro.abortCheck = CommonCardQuestions.cannotPlaceTrapHere;
			pro.onAbort = onAbort;
			function onAbort( c:Card, field:TrapField ):void
			{
				if ( c.isInPlay )
					prepend_DestroyTrap( c );
			}
			
			/// ENTER_PLAY
			pro = chain( pro, process_EnterPlay( c, field, c.props.startFaceDown ) );
			
			/// SET_TRAP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SET_TRAP_COMPLETE, c, field ) );
		}
		
		gameprocessing function prepend_TrapActivation( c:Card ):void
		{
			var interruptedProcess:GameplayProcess = currentProcess as GameplayProcess;
			var pro:GameplayProcess;
			
			/// ACTIVATE_TRAP
			pro = chain( pro, gen( GameplayProcess.ACTIVATE_TRAP, c ) );
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			pro.onAbort = onAbort;
			pro.abortCheck = CommonCardQuestions.isNotInPlay;
			
			function onStart( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				trace ( c + " interrupted process " + interruptedProcess );
			}
			function onEnd( c:Card ):void
			{
				c.sprite.animFlipEffect();
				c.propsT.effect.activate( interruptedProcess );
			}
			function onAbort( c:Card ):void
			{
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
		
		gameprocessing function prepend_TrapDeactivation( c:Card ):void
		{
			var interruptedProcess:GameplayProcess = currentProcess as GameplayProcess;
			var pro:GameplayProcess;
			
			/// DEACTIVATE_TRAP
			pro = chain( pro, gen( GameplayProcess.DEACTIVATE_TRAP, c ) );
			pro.onEnd = 
			function onEnd( c:Card ):void
			{
				c.propsT.effect.deactivate( interruptedProcess );
			}
			
			/// DEACTIVATE_TRAP
			pro = chain( pro, gen( GameplayProcess.DEACTIVATE_TRAP_COMPLETE, c ) );
		}
		
		gameprocessing function prepend_DestroyTrap( c:Card ):void
		{
			c.propsT.persistenceLink == null;
			prepend_AddToGrave( c );
		}
		
		//}
		//{ SPECIAL EFFECTS
		
		gameprocessing function prepend_InPlaySpecialActivation( c:Card ):void
		{
			prepend_SpecialActivation( c,
					c.propsC.inplaySpecial, 
					CommonCardQuestions.isNotInPlay );
		}
		
		gameprocessing function prepend_InGraveSpecialActivation( c:Card ):void
		{
			prepend_SpecialActivation( c,
					c.propsC.graveSpecial, 
					CommonCardQuestions.isNotInGrave );
		}
		
		gameprocessing function prepend_InHandSpecialActivation( c:Card ):void
		{
			prepend_SpecialActivation( c,
					c.propsC.handSpecial, 
					CommonCardQuestions.isNotInHand );
		}
		
		private function prepend_SpecialActivation( c:Card, special:SpecialEffect, extraAbortCheck:Function ):void
		{
			var interruptedProcess:GameplayProcess = currentProcess as GameplayProcess;
			var pro:GameplayProcess;
			
			/// ACTIVATE_SPECIAL
			pro = chain( pro, gen( GameplayProcess.ACTIVATE_SPECIAL, c ) );
			pro.abortCheck = abortCheck;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			
			function onStart( c:Card ):void
			{
				c.lot.moveCardToTop( c );
				
				if ( c.faceDown )
					/// SILENT_FLIP
					prepend_SilentFlip( c );
				
				trace ( c + " interrupted process " + interruptedProcess );
			}
			function onEnd( c:Card ):void
			{
				c.sprite.animSpecialEffect();
				special.activateNow( interruptedProcess );
			}
			function abortCheck( c:Card ):Boolean
			{ 
				return extraAbortCheck( c ) || !special.meetsCondition( interruptedProcess );
			}
			
			/// ACTIVATE_SPECIAL_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ACTIVATE_SPECIAL_COMPLETE, c ) );
		}
		
		//}
		//{ ATTACK
		
		gameprocessing function append_Attack( c:Card, free:Boolean ):void
		{
			var pro:GameplayProcess;
			
			/// ATTACK
			pro = chain( pro, gen( GameplayProcess.ATTACK, c ) );
			pro.onStart =
			function onStart( c:Card ):void
			{
				c.sprite.animAttackPrepare();
				
				if ( c.indexedField.opposingCreature != null )
					if ( c.indexedField.opposingCreature.faceDown )
						prepend_CombatFlip( c.indexedField.opposingCreature );
			}
			pro.onEnd =
			function onEnd( c:Card ):void
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
			pro.onAbort =
			function abort():void
			{
				c.sprite.animAttackAbort();
				completeOrAbort( c );
				prependProcess( gen( GameplayProcess.ATTACK_ABORT, c ) );
			}
			pro.abortCheck = CommonCardQuestions.cannotPerformAttack;
			
			/// ATTACK_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ATTACK_COMPLETE, c ) );
			pro.onStart = completeOrAbort;
			
			/// /// ///
			function completeOrAbort( c:Card ):void
			{
				if ( !free )
					c.actionsAttack++;
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
				
				if ( c.statusC.currentAttackValue <= dmg.amount )
				{
					prepend_Death( c, true );
					game.showFloatyText( c.sprite.localToGlobal( new Point() ), 
						c.statusC.currentAttackValue + "-" + dmg.amount + "=DEATH!", 0xFF0000 );
				}
				else
				{
					c.sprite.animDamageOnly();
					game.showFloatyText( c.sprite.localToGlobal( new Point() ), 
						c.statusC.currentAttackValue + "-" + dmg.amount + "=" + (c.statusC.currentAttackValue - dmg.amount), 0x00FFFF );
				}
			}
			pro.onAbort =
			function onAbort( c:Card, dmg:Damage ):void
			{
				if ( c.isInPlay )
					c.sprite.animDamageAbort();
			}
			pro.abortCheck = CommonCardQuestions.cannotTakeDamage;
			
			/// CREATURE_DAMAGE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.CREATURE_DAMAGE_COMPLETE, c, dmg ) );
		}
		
		gameprocessing function prepend_DirectDamage( p:Player, dmg:Damage ):void
		{
			var pro:GameplayProcess;

			/// DIRECT_DAMAGE
			pro = chain( pro, gen( GameplayProcess.DIRECT_DAMAGE, p, dmg ) );
			pro.onEnd =
			function onEnd( p:Player, dmg:Damage ):void
			{
				p.takeDirectDamage( dmg.amount );
			}
			
			/// DIRECT_DAMAGE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.DIRECT_DAMAGE_COMPLETE, p, dmg ) );
		}
		
		gameprocessing function prepend_Death( c:Card, fromCombat:Boolean=false ):void 
		{
			var pro:GameplayProcess;

			/// DIE
			pro = chain( pro, gen( GameplayProcess.DIE, c, fromCombat ) );
			pro.onStart =
			function onStart( c:Card, fromCombat:Boolean=false ):void
			{
				if ( c.faceDown )
					prepend_SilentFlip( c );
			}
			pro.onEnd =
			function onEnd( c:Card, fromCombat:Boolean=false ):void
			{
				if ( fromCombat )
					c.sprite.animDie();
				else
					c.sprite.animFadeToNothing( false );
			}
			pro.abortCheck = CommonCardQuestions.cannotDie;
			
			/// DIE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.DIE_COMPLETE, c, fromCombat ) );
			pro.delay = fromCombat ? .480 : .150;
			pro.onEnd =
			function complete( c:Card, fromCombat:Boolean=false ):void 
			{
				if ( c.owner )
					prepend_AddToGrave( c );
				else
				{
					c.lot.removeCard( c );
					c.sprite.animFadeToNothing( true );
				}
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
				c.sprite.animSpecialFlip();
			}
			pro.abortCheck = CommonCardQuestions.cannotFlipInPlay;
			
			/// COMBAT_FLIP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.COMBAT_FLIP_COMPLETE, c ) );
			
			/// /// /// /// /// /// /// /// /// /// /// ///
			if ( !c.propsC.hasCombatFlipEffect ) return;
			/// /// /// /// /// /// /// /// /// /// /// ///
			
			/// COMBAT_FLIP_EFFECT
			pro = chain( pro, gen( GameplayProcess.COMBAT_FLIP_EFFECT, c ) );
			pro.onStart =
			function effectStart( c:Card ):void
			{
				c.sprite.animFlipEffect();
			}
			pro.onEnd =
			function effectEnd( c:Card ):void
			{
				c.propsC.onCombatFlip();
			}
			pro.abortCheck = 
			function effectAbortCheck( c:Card ):Boolean
			{
				return !c.isInPlay || !c.propsC.hasCombatFlipEffect;
			}
			
			/// COMBAT_FLIP_EFFECT_COMPLETE
			pro = chain( pro, gen( GameplayProcess.COMBAT_FLIP_EFFECT_COMPLETE, c ) );
		}
		
		gameprocessing function prepend_SafeFlip( c:Card ):void
		{
			var pro:GameplayProcess;
			
			/// SAFE_FLIP
			pro = chain( pro, gen( GameplayProcess.SAFE_FLIP, c ) );
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
			}
			pro.abortCheck = CommonCardQuestions.cannotFlipInPlay;
			
			/// SAFE_FLIP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SAFE_FLIP_COMPLETE, c ) );
			
			/// /// /// /// /// /// /// /// /// /// /// ///
			if ( !c.propsC.hasSafeFlipEffect ) return;
			/// /// /// /// /// /// /// /// /// /// /// ///
			
			/// SAFE_FLIP_EFFECT
			pro = chain( pro, gen( GameplayProcess.SAFE_FLIP_EFFECT, c ) );
			pro.onStart =
			function effectStart( c:Card ):void
			{
				c.sprite.animFlipEffect();
			}
			pro.onEnd =
			function effectEnd( c:Card ):void
			{
				c.propsC.onSafeFlip();
			}
			pro.abortCheck = 
			function effectAbortCheck( c:Card ):Boolean
			{
				return !c.isInPlay || !c.propsC.hasSafeFlipEffect;
			}
			
			/// SAFE_FLIP_EFFECT_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SAFE_FLIP_EFFECT_COMPLETE, c ) );
		}
		
		gameprocessing function prepend_SilentFlip( c:Card ):void
		{
			
			var pro:GameplayProcess;

			/// SILENT_FLIP
			pro = chain( pro, gen( GameplayProcess.SILENT_FLIP, c ) );
			pro.abortable = false;
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
			}
			
			/// SILENT_FLIP_COMPLETE
			pro = chain( pro, gen( GameplayProcess.SILENT_FLIP_COMPLETE, c ) );
		}
		
		//}
		//{ CHAINGING CARD CONTAINERS I   ( ADD   TO   GRAVE / HAND / DECK )
		
		gameprocessing function prepend_AddToGrave( c:Card ):void 
		{
			var pro:GameplayProcess;
			
			if ( c.isInPlay )
				/// LEAVE_PLAY
				pro = chain( pro, process_LeavePlay( c ) );
			
			/// ENTER_GRAVE
			pro = chain( pro, gen( GameplayProcess.ENTER_GRAVE, c ) );
			pro.onEnd =
			function onEnd( c:Card ):void
			{
				c.resetState();
				c.owner.grave.addCard( c );
			}
			pro.abortCheck = 
			function abortCheck( c:Card ):Boolean
			{
				return c.isInGrave;
			}
			
			/// ENTER_GRAVE_COMPLETE
			pro = chain( pro, gen( GameplayProcess.ENTER_GRAVE_COMPLETE, c ) );
			pro.onEnd =
			function complete( c:Card ):void 
			{
				c.faceDown = false;
			}
		}
		
		gameprocessing function prepend_AddToHand( c:Card, p:Player ):void 
		{
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
				c.resetState();
				p.hand.addCard( c );
				c.faceDown = false;
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
		
		gameprocessing function prepend_AddToDeck( c:Card, p:Player, faceDown:Boolean, shuffle:Boolean ):void 
		{
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
				c.resetState();
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
				.chain( process_EnterIndexedField( c, field, c.props.startFaceDown ) )
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
			pro.abortCheck = CommonCardQuestions.isNotInPlay;
			pro.onStart =
			function onStart( c:Card ):void 
			{
				if ( c.propsT && c.propsT.isPersistent && c.propsT.effect.isActive )
					prepend_TrapDeactivation( c );
			}
			
			pro
				/// LEAVE_INDEXED_FIELD
				.chain( process_LeaveIndexedField( c ) )
				/// LEAVE_PLAY_COMPLETE
				.chain( gen( GameplayProcess.LEAVE_PLAY_COMPLETE, c ) )
				.onEnd = complete;
			
			function complete( c:Card ):void 
			{
				c.resetState();
			}
			
			/// returns LEAVE_PLAY (the chain head)
			return pro;
		}
		
		private function process_EnterIndexedField( c:Card, field:IndexedField, faceDown:Boolean ):GameplayProcess 
		{
			var pro:GameplayProcess;

			/// ENTER_INDEXED_FIELD
			pro = gen( GameplayProcess.ENTER_INDEXED_FIELD, c, field );
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
				c.resetState();
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
			chain( pro, gen( GameplayProcess.ENTER_INDEXED_FIELD_COMPLETE, c, c.indexedField ) );
			
			/// returns LEAVE_INDEXED_FIELD (the chain head)
			return pro;
		}
		
		//}
		
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		////\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		////\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		
		//{
		gameprocessing function chain( prev:Process, next:Process ):GameplayProcess
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
		
		gameprocessing static function gen( name:String, ...args ):GameplayProcess
		{
			CONFIG::development
			{ 
				while ( args[ 0 ] is Function )
				{
					args.shift();
					error( "You left a function here" );
				}
			}
			
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