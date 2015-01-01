package duel.processes
{
	import duel.cards.Card;
	import duel.cards.CommonCardQuestions;
	import duel.Damage;
	import duel.DamageType;
	import duel.display.animation;
	import duel.Game;
	import duel.otherlogic.SpecialEffect;
	import duel.Player;
	import duel.table.CreatureField;
	import duel.table.TrapField;
	
	use namespace animation;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameplayProcessManager extends ProcessManager
	{
		// TURN LOGIC
		
		public function append_TurnEnd( p:Player ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.TURN_END, turnEnd, p );
			pro.delay = .333;
			
			appendProcess( pro );
			
			function turnEnd( p:Player ):void
			{
				append_TurnStart( p.opponent );
			}
		}
		
		public function append_TurnStart( p:Player ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.TURN_START, null, p );
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			pro.delay = .333;
			
			appendProcess( pro );
			
			function onStart( p:Player ):void
			{
				game.currentPlayer = p;
			}
			
			function onEnd( p:Player ):void
			{
				prepend_Draw( p, 1 );
			}
			
			pro = pro.chain( gen( GameplayProcess.TURN_START_COMPLETE, null, p ) );
			pro.delay = .333;
		}
		
		// DRAW & DISCARD
		
		public function prepend_Draw( p:Player, count:int = 1 ):void
		{
			var pro:GameplayProcess;
			while ( --count >= 0 )
			{
				pro = gen( GameplayProcess.DRAW_CARD, onComplete, p );
				pro.delay = NaN;
				prependProcess( pro );
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
				
				pro = gen( GameplayProcess.DRAW_CARD_COMPLETE, null, p, c );
				pro.delay = NaN;
				prependProcess( pro );
				
				prepend_AddToHand( c, p );
			}
		}
		
		public function prepend_Discard( p:Player, c:Card ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.DISCARD_CARD, discardCard, p, c );
			pro.abortCheck = abortCheck;
			
			prependProcess( pro );
			
			function abortCheck( p:Player, c:Card ):Boolean
			{
				return !p.hand.containsCard( c );
			}
				
			function discardCard( p:Player, c:Card ):void
			{
				p.hand.removeCard( c );
				prepend_AddToGrave( c );
			}
				
			pro = pro.chain( gen( GameplayProcess.DISCARD_CARD_COMPLETE, null, p, c ) );
		}
		
		// SUMMON
		
		public function append_SummonHere( c:Card, field:CreatureField ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.SUMMON, null, c, field );
			pro.abortCheck = CommonCardQuestions.cannotSummonHere;
			pro.onAbort = onAbort;
			pro.onEnd = onSummon;
			
			appendProcess( pro );
			
			function onSummon( c:Card, field:CreatureField ):void
			{
				if ( !field.isEmpty )
					prepend_Death( field.topCard );
			}
			
			pro = pro.chain( gen( GameplayProcess.ENTER_PLAY, onEnter, c, field ) );
			pro.abortCheck = CommonCardQuestions.cannotPlaceCreatureHere;
			pro.onAbort = onAbort;
			
			function onAbort( c:Card ):void
			{
				if ( c.isInPlay )
					prepend_AddToGrave( c );
			}
			
			function onEnter( c:Card, field:CreatureField ):void
			{
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
			}
			
			pro = pro.chain( gen( GameplayProcess.ENTER_PLAY_COMPLETE, null, c, field ) );
			
			pro = pro.chain( gen( GameplayProcess.SUMMON_COMPLETE, complete, c, field ) );
			pro.abortCheck = completeAbortCheck;
			
			function completeAbortCheck( c:Card, field:CreatureField ):Boolean
			{
				return !c.isInPlay;
			}
			
			function complete( c:Card, field:CreatureField ):void
			{
				c.summonedThisTurn = true;
				c.sprite.animSummon();
			}
			
		}
		
		public function prepend_ResurrectHere( c:Card, field:CreatureField ):void	//TODO  USE THIS SHIT (zig&zag)
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.RESURRECT, onEnd, c, field );
			pro.abortCheck = abortCheck;
			pro.onAbort = onAbort;
			
			appendProcess( pro );
			
			function abortCheck( c:Card, field:CreatureField ):Boolean
			{
				if ( !c.isInGrave ) return true;
				return CommonCardQuestions.cannotPlaceCreatureHere( c, field );
			}
			
			function onAbort( c:Card ):void
			{
				if ( c.isInPlay )
					prepend_AddToGrave( c );
			}
			
			function onEnd( c:Card, field:CreatureField ):void
			{
				c.lot.removeCard( c );
				append_SummonHere( c, field );
			}
			
			appendProcess( gen( GameplayProcess.RESURRECT_COMPLETE, null, c, field ) );
		}
		
		// RELOCATION
		
		public function append_Relocation( c:Card, field:CreatureField ):void
		{
			var pro:GameplayProcess;
			
			if ( c.faceDown )
				prepend_SafeFlip( c );
			
			pro = gen( GameplayProcess.RELOCATE, null, c, field );
			pro.abortCheck = CommonCardQuestions.cannotRelocateHere;
			pro.onAbort = completeOrAbort;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			
			appendProcess( pro );
			
			function onStart( c:Card, field:CreatureField ):void
			{
				c.sprite.animRelocation();
			}
			function onEnd( c:Card, field:CreatureField ):void
			{
				field.addCard( c );
			}
			
			pro = pro.chain( gen( GameplayProcess.RELOCATE_COMPLETE, completeOrAbort, c, field ) );
			
			function completeOrAbort( c:Card, field:CreatureField ):void {
				if ( c.isInPlay )
				{
					c.sprite.animRelocationCompleteOrAbort();
					c.actionsRelocate++;
				}
			}
		}
		
		// TRAPS
		
		public function append_TrapSet( c:Card, field:TrapField ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.SET_TRAP, onEnd, c, field );
			pro.abortCheck = CommonCardQuestions.cannotPlaceTrapHere;
			pro.onAbort = onAbort;
			
			function onAbort( c:Card ):void
			{
				if ( c.isInPlay )
					prepend_AddToGrave( c );
			}
			
			appendProcess( pro );
			
			function onEnd( c:Card, field:TrapField ):void
			{
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
			}
			
			pro = pro.chain( gen( GameplayProcess.SET_TRAP_COMPLETE, null, c, field ) );
		}
		
		public function prepend_TrapActivation( c:Card ):void
		{
			var interruptedProcess:GameplayProcess = currentProcess as GameplayProcess;
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.ACTIVATE_TRAP, null, c );
			pro.abortCheck = CommonCardQuestions.isNotInPlay;
			pro.onAbort = onAbort;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			
			function onAbort( c:Card ):void
			{
				if ( c.isInPlay )
					prepend_AddToGrave( c );
			}
			
			prependProcess( pro );
			
			function onStart( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				trace ( c + " interrupted process " + interruptedProcess );
			}
			
			function onEnd( c:Card ):void
			{
				c.sprite.animFlipEffect();
				c.behaviourT.effect.activateNow( interruptedProcess );
			}
			
			pro = pro.chain( gen( GameplayProcess.ACTIVATE_TRAP_COMPLETE, onComplete, c ) );
			
			function onComplete( c:Card ):void
			{
				if ( c.isInPlay && !c.behaviourT.persistent )
					prepend_AddToGrave( c );
			}
		}
		
		// SPECIAL EFFECTS
		
		public function prepend_InPlaySpecialActivation( c:Card ):void
		{
			prepend_SpecialActivation( c,
					c.behaviourC.inplaySpecial, 
					CommonCardQuestions.isNotInPlay );
		}
		
		public function prepend_InGraveSpecialActivation( c:Card ):void
		{
			prepend_SpecialActivation( c,
					c.behaviourC.graveSpecial, 
					CommonCardQuestions.isNotInGrave );
		}
		
		public function prepend_InHandSpecialActivation( c:Card ):void
		{
			prepend_SpecialActivation( c,
					c.behaviourC.handSpecial, 
					CommonCardQuestions.isNotInHand );
		}
		
		private function prepend_SpecialActivation( c:Card, special:SpecialEffect, extraAbortCheck:Function ):void
		{
			var interruptedProcess:GameplayProcess = currentProcess as GameplayProcess;
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.ACTIVATE_SPECIAL, null, c );
			pro.abortCheck = abortCheck;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			
			prependProcess( pro );
			
			function abortCheck( c:Card ):Boolean
			{ 
				return extraAbortCheck( c ) || !special.meetsCondition( interruptedProcess );
			}
			
			function onStart( c:Card ):void
			{
				c.lot.moveCardToTop( c );
				
				if ( c.faceDown )
					prepend_SilentFlip( c );
				
				trace ( c + " interrupted process " + interruptedProcess );
			}
			
			function onEnd( c:Card ):void
			{
				c.sprite.animSpecialEffect();
				special.activateNow( interruptedProcess );
			}
			
			pro = pro.chain( gen( GameplayProcess.ACTIVATE_SPECIAL_COMPLETE, null, c ) );
		}
		
		// ATTACK
		
		public function append_Attack( c:Card ):void
		{
			var pro:GameplayProcess;
			
			if ( c.faceDown )
				prepend_SafeFlip( c );
			
			pro = gen( GameplayProcess.ATTACK, null, c );
			pro.abortCheck = CommonCardQuestions.cannotPerformAttack;
			pro.onAbort = completeOrAbort;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			
			appendProcess( pro );
			
			function onStart( c:Card ):void
			{
				c.sprite.animAttackPrepare();
				
				if ( c.indexedField.opposingCreature != null )
					if ( c.indexedField.opposingCreature.faceDown )
						prepend_CombatFlip( c.indexedField.opposingCreature );
			}
			
			function onEnd( c:Card ):void
			{
				c.sprite.animAttackPerform();
				
				if ( c.indexedField.opposingCreature == null )
				{
					prepend_DirectDamage( c.controller.opponent, c.behaviourC.genAttackDamage() );
				}
				else
				{
					c.indexedField.opposingCreature.sprite.animAttackPerform();
					prepend_CreatureDamage( c, c.indexedField.opposingCreature.behaviourC.genAttackDamage() );
					prepend_CreatureDamage( c.indexedField.opposingCreature, c.behaviourC.genAttackDamage() );
				}
			}
			
			pro = pro.chain( gen( GameplayProcess.ATTACK_COMPLETE, completeOrAbort, c ) );
			
			function completeOrAbort( c:Card ):void
			{
				c.actionsAttack++;
			}
		}
		
		// DAMAGE & DEATH
		
		private function prepend_CreatureDamage( c:Card, dmg:Damage ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.CREATURE_DAMAGE, null, c, dmg );
			pro.abortCheck = CommonCardQuestions.cannotTakeDamage;
			pro.onAbort = onAbort;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			
			prependProcess( pro );
			
			function onAbort( c:Card, dmg:Damage ):void
			{
				if ( c.isInPlay )
					c.sprite.animDamageAbort();
			}
			
			function onStart( c:Card, dmg:Damage ):void
			{
				if ( c.faceDown )
					prepend_SilentFlip( c );
			}
			
			function onEnd( c:Card, dmg:Damage ):void
			{
				if ( !c.isInPlay ) 
					return;
				
				if ( c.behaviourC.attack <= dmg.amount )
					prepend_Death( c );
				else
					c.sprite.animDamageOnly();
			}
			
			pro = pro.chain( gen( GameplayProcess.CREATURE_DAMAGE_COMPLETE, null, c, dmg ) );
		}
		
		private function prepend_DirectDamage( p:Player, dmg:Damage ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.DIRECT_DAMAGE, onEnd, p, dmg );
			
			prependProcess( pro );
			
			function onEnd( p:Player, dmg:Damage ):void
			{
				p.takeDirectDamage( dmg.amount );
			}
			
			pro = pro.chain( gen( GameplayProcess.DIRECT_DAMAGE_COMPLETE, null, p, dmg ) );
			pro.delay = .440;
		}
		
		public function prepend_Death( c:Card ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.DIE, null, c );
			pro.abortCheck = CommonCardQuestions.cannotDie;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			
			prependProcess( pro );
			
			function onStart( c:Card ):void
			{
				if ( c.faceDown )
					prepend_SilentFlip( c );
			}
			
			function onEnd( c:Card ):void
			{
				c.sprite.animDie();
			}
			
			pro = pro.chain( gen( GameplayProcess.DIE_COMPLETE, complete, c ) );
			
			function complete( c:Card ):void 
			{
				prepend_AddToGrave( c );
			}
		}
		
		// COMBAT FLIP & SAFE FLIP & MAGIC FLIP
		
		private function prepend_CombatFlip( c:Card ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.COMBAT_FLIP, onEnd, c );
			pro.abortCheck = CommonCardQuestions.cannotFlipInPlay;
			
			prependProcess( pro );
			
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
			}
			
			pro = pro.chain( gen( GameplayProcess.COMBAT_FLIP_COMPLETE, onComplete, c ) );
			
			function onComplete( c:Card ):void
			{
				if ( !c.behaviourC.hasCombatFlipEffect )
					return;
					
				var proE:GameplayProcess;
				proE = gen( GameplayProcess.COMBAT_FLIP_EFFECT, null, c );
				proE.abortCheck = effectAbortCheck;
				proE.onStart = effectStart;
				proE.onEnd = effectEnd;
				prependProcess( proE );
				proE = proE.chain( gen( GameplayProcess.COMBAT_FLIP_EFFECT_COMPLETE, null, c ) );
			}
			
			function effectAbortCheck( c:Card ):Boolean
			{
				return !c.isInPlay || !c.behaviourC.hasCombatFlipEffect;
			}
			
			function effectStart( c:Card ):void
			{
				c.sprite.animFlipEffect();
			}
			
			function effectEnd( c:Card ):void
			{
				c.behaviourC.onCombatFlip();
			}
		}
		
		public function prepend_SafeFlip( c:Card ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.SAFE_FLIP, onEnd, c );
			pro.abortCheck = CommonCardQuestions.cannotFlipInPlay;
			
			prependProcess( pro );
			
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
			}
			
			pro = pro.chain( gen( GameplayProcess.SAFE_FLIP_COMPLETE, onComplete, c ) );
			
			function onComplete( c:Card ):void
			{
				if ( !c.behaviourC.hasSafeFlipEffect )
					return;
					
				var proE:GameplayProcess;
				proE = gen( GameplayProcess.SAFE_FLIP_EFFECT, null, c );
				proE.abortCheck = effectAbortCheck;
				proE.onStart = effectStart;
				proE.onEnd = effectEnd;
				prependProcess( proE );
				proE = proE.chain( gen( GameplayProcess.SAFE_FLIP_EFFECT_COMPLETE, null, c ) );
			}
			
			function effectAbortCheck( c:Card ):Boolean
			{
				return !c.isInPlay || !c.behaviourC.hasSafeFlipEffect;
			}
			
			function effectStart( c:Card ):void
			{
				c.sprite.animFlipEffect();
			}
			
			function effectEnd( c:Card ):void
			{
				c.behaviourC.onSafeFlip();
			}
		}
		
		public function prepend_SilentFlip( c:Card ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.SILENT_FLIP, onEnd, c );
			pro.abortCheck = CommonCardQuestions.cannotFlipInPlay;
			
			prependProcess( pro );
			
			function onEnd( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
			}
			
			pro = pro.chain( gen( GameplayProcess.SILENT_FLIP_COMPLETE, null, c ) );
		}
		
		// CHAINGING CARD CONTAINERS
		public function prepend_AddToGrave( c:Card ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.ENTER_GRAVE, onEnd, c );
			pro.abortCheck = abortCheck;
			
			prependProcess( pro );
			
			function abortCheck( c:Card ):Boolean
			{
				return c.isInGrave;
			}
			
			function onEnd( c:Card ):void
			{
				c.resetState();
				c.owner.grave.addCard( c );
			}
			
			pro = pro.chain( gen( GameplayProcess.ENTER_GRAVE_COMPLETE, complete, c ) );
			
			function complete( c:Card ):void 
			{
				c.faceDown = false;
			}
			
			//PREPEND LEAVE PLAY
			if ( c.isInPlay )
				prepend_LeavePlay( c );
		}
		
		public function prepend_AddToHand( c:Card, p:Player ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.ENTER_HAND, onEnd, c, p );
			pro.abortCheck = abortCheck;
			pro.delay = NaN;
			
			prependProcess( pro );
			
			function abortCheck( c:Card, p:Player ):Boolean
			{
				return p.hand.containsCard( c );
			}
			
			function onEnd( c:Card, p:Player ):void 
			{
				c.resetState();
				p.hand.addCard( c );
				c.faceDown = false;
			}
			
			pro = pro.chain( gen( GameplayProcess.ENTER_HAND_COMPLETE, null, c, p ) );
			pro.delay = NaN;
			
			//PREPEND LEAVE PLAY
			if ( c.isInPlay )
				prepend_LeavePlay( c );
		}
		
		public function prepend_AddToDeck( c:Card, p:Player, faceDown:Boolean ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.ENTER_DECK, onEnd, c, p );
			pro.abortCheck = abortCheck;
			pro.delay = NaN;
			
			prependProcess( pro );
			
			function abortCheck( c:Card, p:Player ):Boolean
			{
				return p.deck.containsCard( c );
			}
			
			function onEnd( c:Card, p:Player ):void 
			{
				c.resetState();
				p.deck.addCard( c );
				c.faceDown = faceDown;
			}
			
			pro = pro.chain( gen( GameplayProcess.ENTER_DECK_COMPLETE, null, c, p ) );
			pro.delay = NaN;
			
			//PREPEND LEAVE PLAY
			if ( c.isInPlay )
				prepend_LeavePlay( c );
		}
		
		public function prepend_LeavePlay( c:Card ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.LEAVE_PLAY, onEnd );
			pro.abortCheck = CommonCardQuestions.isNotInPlay;
			
			prependProcess( pro );
			
			function onEnd( c:Card, p:Player ):void 
			{
				c.resetState();
				
				if ( c.indexedField == null ) 
				{
					CONFIG::development 
					{ throw new Error( "c.indexField is NULL during leave play" ) }
					return;
				}
				
				c.indexedField.removeCard( c );
			}
			
			pro = pro.chain( gen( GameplayProcess.LEAVE_PLAY_COMPLETE, null, c ) );
		}
		
		
		
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		////\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		////\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
		
		public static function gen( name:String, onEnd:Function = null, ...args ):GameplayProcess
		{
			var p:GameplayProcess = new GameplayProcess();
			p.name = name;
			p.onEnd = onEnd;
			p.args = args;
			return p;
		}
		
		protected function get game():Game { return Game.current }
	}

}