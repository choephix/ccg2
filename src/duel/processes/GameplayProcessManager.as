package duel.processes
{
	import duel.cards.Card;
	import duel.cards.CommonCardQuestions;
	import duel.Damage;
	import duel.DamageType;
	import duel.display.animation;
	import duel.Game;
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
		
		public function startChain_TurnEnd( p:Player ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.TURN_END, turnEnd, p );
			pro.delay = .333;
			
			appendProcess( pro );
			
			function turnEnd( p:Player ):void
			{
				startChain_TurnStart( p.opponent );
			}
		}
		
		public function startChain_TurnStart( p:Player ):void
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
				startChain_Draw( p, 1 );
			}
		}
		
		// DRAW & DISCARD
		
		public function startChain_Draw( p:Player, count:int = 1 ):void
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
					dealDirectDamage( p, new Damage( 1, DamageType.SPECIAL, null ) );
					return;
				}
				
				var c:Card = p.deck.getFirstCard();
				p.deck.removeCard( c );
				
				pro = gen( GameplayProcess.DRAW_CARD_COMPLETE, null, p, c );
				pro.delay = NaN;
				prependProcess( pro );
				
				enterHand( c, p );
			}
		}
		
		public function startChain_Discard( p:Player, c:Card ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.DISCARD_CARD, discardCard, p, c );
			pro.abortCheck = abortCheck;
			pro.delay = .333;
			
			appendProcess( pro );
			
			function abortCheck( p:Player, c:Card ):Boolean
			{
				return !p.hand.containsCard( c );
			}
				
			function discardCard( p:Player, c:Card ):void
			{
				p.hand.removeCard( c );
				enterGrave( c );
			}
				
			pro = pro.chain( gen( GameplayProcess.DISCARD_CARD_COMPLETE, null, p, c ) );
		}
		
		// SUMMON
		
		public function startChain_SummonHere( c:Card, field:CreatureField ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.SUMMON, null, c, field );
			pro.abortCheck = CommonCardQuestions.cannotSummonHere;
			pro.onAbort = onAbort;
			
			appendProcess( pro );
			
			pro = pro.chain( gen( GameplayProcess.ENTER_PLAY, onEnter, c, field ) );
			pro.abortCheck = CommonCardQuestions.cannotPlaceCreatureHere;
			pro.onAbort = onAbort;
			
			function onEnter( c:Card, field:CreatureField ):void
			{
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				c.sprite.animSummon();
			}
			
			pro = pro.chain( gen( GameplayProcess.ENTER_PLAY_COMPLETE, null, c, field ) );
			
			pro = pro.chain( gen( GameplayProcess.SUMMON_COMPLETE, complete, c, field ) );
			
			function complete( c:Card, field:CreatureField ):void
			{
				if ( c.isInPlay )
					c.exhausted ||= !c.behaviourC.haste;
			}
			
			function onAbort( c:Card ):void
			{
				if ( c.isInPlay )
					enterGrave( c );
			}
			
		}
		
		public function startChain_ResurrectHere( c:Card, field:CreatureField ):void	//TODO  USE THIS SHIT (zig&zag)
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
					enterGrave( c );
			}
			
			function onEnd( c:Card, field:CreatureField ):void
			{
				c.lot.removeCard( c );
				startChain_SummonHere( c, field );
			}
			
			appendProcess( gen( GameplayProcess.RESURRECT_COMPLETE, null, c, field ) );
		}
		
		// RELOCATION
		
		public function startChain_Relocation( c:Card, field:CreatureField ):void
		{
			var pro:GameplayProcess;
			
			if ( c.faceDown )
				startChain_SafeFlip( c );
			
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
					c.exhausted = true;
				}
			}
		}
		
		// TRAPS
		
		public function startChain_TrapSet( c:Card, field:TrapField ):void 
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.SET_TRAP, onEnd, c, field );
			pro.abortCheck = CommonCardQuestions.cannotPlaceTrapHere;
			pro.onAbort = onAbort;
			
			function onAbort( c:Card ):void
			{
				if ( c.isInPlay )
					enterGrave( c );
			}
			
			appendProcess( pro );
			
			function onEnd( c:Card, field:TrapField ):void
			{
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
			}
			
			pro = pro.chain( gen( GameplayProcess.SET_TRAP_COMPLETE, null, c, field ) );
		}
		
		public function startChain_TrapActivation( c:Card ):void
		{
			var interruptedProcess:GameplayProcess = currentProcess as GameplayProcess;
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.ACTIVATE_TRAP, null, c );
			pro.abortCheck = CommonCardQuestions.isInPlay;
			pro.onAbort = onAbort;
			pro.onStart = onStart;
			pro.onEnd = onEnd;
			
			function onAbort( c:Card ):void
			{
				if ( c.isInPlay )
					enterGrave( c );
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
				c.behaviourT.onActivateFunc( interruptedProcess );
			}
			
			pro = pro.chain( gen( GameplayProcess.ACTIVATE_TRAP_COMPLETE, onComplete, c ) );
			
			function onComplete( c:Card ):void
			{
				if ( c.isInPlay && !c.behaviourT.persistent )
					enterGrave( c );
			}
		}
		
		// SPECIAL EFFECTS
		
		public function startChain_InPlaySpecialActivation( c:Card ):void
		{
			startChain_SpecialActivation( c,
					c.behaviourC.inplaySpecialActivateFunc, 
					c.behaviourC.inplaySpecialConditionFunc, 
					CommonCardQuestions.isNotInPlay );
		}
		
		public function startChain_InGraveSpecialActivation( c:Card ):void
		{
			startChain_SpecialActivation( c,
					c.behaviourC.graveSpecialActivateFunc, 
					c.behaviourC.graveSpecialConditionFunc, 
					CommonCardQuestions.isNotInGrave );
		}
		
		public function startChain_InHandSpecialActivation( c:Card ):void
		{
			startChain_SpecialActivation( c,
					c.behaviourC.handSpecialActivateFunc, 
					c.behaviourC.handSpecialConditionFunc, 
					CommonCardQuestions.isNotInHand );
		}
		
		private function startChain_SpecialActivation( c:Card, func:Function, abortCheckFunc:Function, abortCheck2:Function ):void
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
				return abortCheck2( c ) || abortCheckFunc( interruptedProcess );
			}
			
			function onStart( c:Card ):void
			{
				c.lot.moveCardToTop( c );
				
				if ( c.faceDown )
					startChain_SilentFlip( c );
				
				trace ( c + " interrupted process " + interruptedProcess );
			}
			
			function onEnd( c:Card ):void
			{
				c.sprite.animSpecialEffect();
				func( interruptedProcess );
			}
			
			pro = pro.chain( gen( GameplayProcess.ACTIVATE_SPECIAL_COMPLETE, null, c ) );
		}
		
		// ATTACK
		
		public function startChain_Attack( c:Card ):void
		{
			var pro:GameplayProcess;
			
			if ( c.faceDown )
				startChain_SafeFlip( c );
			
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
						startChain_CombatFlip( c.indexedField.opposingCreature );
			}
			
			function onEnd( c:Card ):void
			{
				c.sprite.animAttackPerform();
				
				if ( c.indexedField.opposingCreature == null )
				{
					dealDirectDamage( c.controller.opponent, c.behaviourC.genAttackDamage() );
				}
				else
				{
					c.indexedField.opposingCreature.sprite.animAttackPerform();
					dealCreatureDamage( c, c.indexedField.opposingCreature.behaviourC.genAttackDamage() );
					dealCreatureDamage( c.indexedField.opposingCreature, c.behaviourC.genAttackDamage() );
				}
			}
			
			pro = pro.chain( gen( GameplayProcess.ATTACK_COMPLETE, completeOrAbort, c ) );
			
			function completeOrAbort( c:Card ):void
			{
				if ( c.isInPlay )
					c.exhausted = true;
			}
		}
		
		// DAMAGE & DEATH
		
		private function dealCreatureDamage( c:Card, dmg:Damage ):void
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
					startChain_SilentFlip( c );
			}
			
			function onEnd( c:Card, dmg:Damage ):void
			{
				if ( !c.isInPlay ) 
					return;
				
				if ( c.behaviourC.attack <= dmg.amount )
					startChain_death( c );
				else
					c.sprite.animDamageOnly();
			}
			
			pro = pro.chain( gen( GameplayProcess.CREATURE_DAMAGE_COMPLETE, null, c, dmg ) );
		}
		
		private function dealDirectDamage( p:Player, dmg:Damage ):void
		{
			var pro:GameplayProcess;
			
			pro = gen( GameplayProcess.DIRECT_DAMAGE, onEnd, p, dmg );
			
			prependProcess( pro );
			
			function onEnd( p:Player, dmg:Damage ):void
			{
				p.lp -= dmg.amount;
			}
			
			pro = pro.chain( gen( GameplayProcess.DIRECT_DAMAGE_COMPLETE, null, p, dmg ) );
			pro.delay = .440;
		}
		
		public function startChain_death( c:Card ):void 
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
					startChain_SilentFlip( c );
			}
			
			function onEnd( c:Card ):void
			{
				c.sprite.animDie();
			}
			
			pro = pro.chain( gen( GameplayProcess.DIE_COMPLETE, complete, c ) );
			
			function complete( c:Card ):void 
			{
				enterGrave( c );
			}
		}
		
		// COMBAT FLIP & SAFE FLIP & MAGIC FLIP
		
		private function startChain_CombatFlip( c:Card ):void
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
		
		public function startChain_SafeFlip( c:Card ):void
		{
			/// ...
		}
		
		public function startChain_SilentFlip( c:Card ):void
		{
			/// ...
		}
		
		// CHAINGING CARD CONTAINERS
		public function enterGrave( c:Card ):void 
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
				if ( c.isInPlay )
				{
					c.exhausted = false;
					c.sprite.exhaustClock.alpha = 0.0;
				}
				c.owner.grave.addCard( c );
			}
			
			pro = pro.chain( gen( GameplayProcess.ENTER_GRAVE_COMPLETE, complete, c ) );
			
			function complete( c:Card ):void 
			{
				c.faceDown = false;
			}
		}
		
		public function enterHand( c:Card, p:Player ):void 
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
				p.hand.addCard( c );
				c.faceDown = false;
			}
			
			pro = pro.chain( gen( GameplayProcess.ENTER_HAND_COMPLETE, null, c, p ) );
			pro.delay = NaN;
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