package duel.processes
{
	import duel.cards.Card;
	import duel.display.animation;
	import duel.Game;
	import duel.GameEvents;
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
			var pro:Process;
			pro = gen( "turnEnd", turnEnd, p );
			pro.delay = .333;
			appendProcess( pro );
			function turnEnd( p:Player ):void
			{
				game.dispatchEventWith( GameEvents.TURN_END );
				turnStart( p.opponent );
			}
			function turnStart( p:Player ):void
			{
				game.currentPlayer = p;
				pro = gen( "turnStart", completeTurnStart, p );
				pro.delay = .333;
				appendProcess( pro );
			}
			function completeTurnStart( p:Player ):void
			{
				game.dispatchEventWith( GameEvents.TURN_START );
				startChain_Draw( p, 1 );
			}
		}
		
		// DRAW & DISCARD
		
		public function startChain_Draw( p:Player, count:int = 1 ):void
		{
			var pro:Process;
			while ( --count >= 0 )
			{
				pro = gen( "drawCard", onComplete, p );
				pro.delay = NaN;
				prependProcess( pro )
			}
			
			function onComplete( p:Player ):void 
			{
				if ( p.deck.isEmpty )
				{
					dealEffectDamageDirect( p, 1 );
					return;
				}
				var c:Card = p.deck.getFirstCard();
				p.deck.removeCard( c );
				
				enterHand( c, p );
				pro = gen( "completeDrawCard", null, p, c );
				pro.delay = NaN;
				prependProcess( pro )
			}
		}
		
		public function startChain_Discard( p:Player, c:Card ):void 
		{
			appendProcess( gen( "discardCard", onComplete, p, c ) );
			function onComplete():void
			{
				if ( !p.hand.containsCard( c ) )
				{
					appendProcess( gen( "abortDiscardCard", null, p, c ) );
					return;
				}
				p.hand.removeCard( c );
				enterGrave( c );
				appendProcess( gen( "completeDiscardCard", null, p, c ) );
			}
		}
		
		// SUMMON
		
		public function startChain_Summon( c:Card, field:CreatureField ):void
		{
			appendProcess( gen( "declareSummon", declareSummon, c, field ) );
			
			function declareSummon( c:Card, field:CreatureField ):void
			{
				appendProcess( gen( "performSummon", performSummon, c, field ) );
			}
			function performSummon( c:Card, field:CreatureField ):void
			{
				if ( !game.canPlaceCreatureHere( c, field ) )
				{
					appendProcess( gen( "abortSummon", null, c, field ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				c.sprite.animSummon();
				
				appendProcess( gen( "completeSummon", completeSummon, c, field ) );
			}
			function completeSummon( c:Card, field:CreatureField ):void
			{
				if ( c.isInPlay )
					c.exhausted ||= !c.behaviourC.haste;
			}
		}
		
		
		// TRAPS
		
		public function startChain_TrapSet( c:Card, field:TrapField ):void 
		{
			appendProcess( gen( "declareTrapSet", stepDeclare, c, field ) );
			
			function stepDeclare( c:Card, field:TrapField ):void
			{
				appendProcess( gen( "performTrapSet", stepPerform, c, field ) );
			}
			function stepPerform( c:Card, field:TrapField ):void
			{
				if ( !game.canPlaceTrapHere( c, field ) )
				{
					appendProcess( gen( "abortTrapSet", null, c, field ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				appendProcess( gen( "completeTrapSet", null, c, field ) );
			}
		}
		
		
		public function startChain_TrapActivation( c:Card ):void
		{
			var interruptedProcess:Process = currentProcess;
			
			prependProcess( gen( "declareTrapActivation", stepDeclare, c ) );
			
			function stepDeclare( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				prependProcess( gen( "performTrapActivation", stepPerform, c ) );
				
				trace ( c + " interrupted process " + interruptedProcess );
			}
			function stepPerform( c:Card ):void
			{
				if ( !c.canActivate )
				{
					prependProcess( gen( "abortTrapActivation", abortTrapActivation, c ) );
					return;
				}
				
				prependProcess( gen( "completeTrapActivation", completeTrapActivation, c ) );
				
				c.sprite.animFlipEffect();
				c.behaviourT.onActivateFunc( interruptedProcess );
			}
			function abortTrapActivation( c:Card ):void
			{
				if ( c.isInPlay )
					enterGrave( c );
			}
			function completeTrapActivation( c:Card ):void
			{
				if ( c.isInPlay && !c.behaviourT.persistent )
					enterGrave( c );
			}
		}
		
		public function startChain_SpecialActivation( c:Card, func:Function ):void
		{
			var interruptedProcess:Process = currentProcess;
			
			//if ( c.faceDown )
				//appendProcess( gen( "flipUpForRelocation", flipUpForRelocation, c ) );
			//else
				//appendProcess( gen( "declareRelocation", declareRelocation, c, field ) );
			//function prepareForSpecial( c:Card ):void
			//{
				//startChain_SafeFlip( c );
				//appendProcess( gen( "declareRelocation", declareRelocation, c, field ) );
			//}
			
			prependProcess( gen( "declareSpecialActivation", declare, c ) );
			
			function declare( c:Card ):void
			{
				c.lot.moveCardToTop( c );
				
				prependProcess( gen( "performSpecialActivation", perform, c ) );
				if ( c.faceDown )
					startChain_MagicFlip( c );
				
				trace ( c + " interrupted process " + interruptedProcess );
			}
			function perform( c:Card ):void
			{
				//TODO must recheck conditions here
				prependProcess( gen( "completeSpecialActivation", null, c ) );
				
				c.sprite.animFlipEffect();
				func( interruptedProcess );
			}
		}
		
		
		// RELOCATION
		
		public function startChain_Relocation( c:Card, field:CreatureField ):void
		{
			if ( c.faceDown )
				appendProcess( gen( "flipUpForRelocation", flipUpForRelocation, c ) );
			else
				appendProcess( gen( "declareRelocation", declareRelocation, c, field ) );
			
			function flipUpForRelocation( c:Card ):void
			{
				startChain_SafeFlip( c );
				appendProcess( gen( "declareRelocation", declareRelocation, c, field ) );
			}
			
			function declareRelocation( c:Card, field:CreatureField ):void
			{
				if ( !c.canRelocate )
					return;
				
				c.sprite.animRelocation();
				
				appendProcess( gen( "performRelocation", performRelocation, c, field ) );
			}
			function performRelocation( c:Card, field:CreatureField ):void
			{
				if ( !c.canRelocate )
				{
					appendProcess( gen( "abortRelocation", completeOrAbortRelocation, c, field ) );
					return;
				}
				
				field.addCard( c );
				
				appendProcess( gen( "completeRelocation", completeOrAbortRelocation, c, field ) );
			}
			function completeOrAbortRelocation():void {
				
				c.sprite.animRelocationCompleteOrAbort()
				
				if ( c.isInPlay )
					c.exhausted = true;
			}
		}
		
		// ATTACK
		
		public function startChain_Attack( c:Card ):void
		{
			if ( c.faceDown )
				appendProcess( gen( "flipUpForAttack", flipUpForAttack, c ) );
			else
				appendProcess( gen( "declareAttack", declareAttack, c ) );
			
			function flipUpForAttack( c:Card ):void
			{
				startChain_SafeFlip( c );
				appendProcess( gen( "declareAttack", declareAttack, c ) );
			}
				
			function declareAttack( c:Card ):void
			{
				if ( !c.canAttack )
				{
					appendProcess( gen( "abortAttack", null, c ) );
					return;
				}
				c.sprite.animAttackPrepare();
				appendProcess( gen( "performAttack", performAttack, c ) );
			}
			function performAttack( c:Card ):void
			{
				if ( !c.canAttack )
				{
					appendProcess( gen( "abortAttack", completeOrAbortAttack, c ) );
					c.sprite.animAttackAbort();
					return;
				}
				
				if ( c.indexedField.opposingCreature == null )
				{
					c.sprite.animAttackPerform();
					dealCombatDamageDirect( c, c.controller.opponent );
				}
				else
				{
					if ( c.indexedField.opposingCreature.faceDown )
					{
						startChain_CombatFlip( c.indexedField.opposingCreature );
						appendProcess( gen( "performAttack", performAttack, c ) );
						return;
					}
					
					c.sprite.animAttackPerform();
					c.indexedField.opposingCreature.sprite.animAttackPerform();
					dealCombatDamage( c, c.indexedField.opposingCreature );
					dealCombatDamage( c.indexedField.opposingCreature, c );
				}
				appendProcess( gen( "completeAttack", completeOrAbortAttack, c ) );
			}
			function completeOrAbortAttack( c:Card ):void
			{
				if ( c.isInPlay )
					c.exhausted = true;
			}
		}
		
		// DAMAGE & DEATH
		
		private function dealCombatDamage( attacker:Card, attackee:Card ):void
		{
			appendProcess( gen( "dealCombatDamage", onComplete, attacker, attackee ) );
			
			function onComplete( attacker:Card, attackee:Card ):void
			{
				if ( attackee.behaviourC.attack <= attacker.behaviourC.attack )
					startChain_death( attackee );
			}
		}
		
		private function dealCombatDamageDirect( attacker:Card, attackee:Player ):void
		{
			appendProcess( gen( "dealCombatDamageDirect", dealDamageDirect, attackee, attacker.behaviourC.attack ) );
		}
		
		private function dealEffectDamageDirect( p:Player, amount:int ):void 
		{
			prependProcess( gen( "dealEffectDamageDirect", dealDamageDirect, p, amount ) );
		}
		
		private function dealDamageDirect( p:Player, amount:int ):void 
		{
			prependProcess( gen( "dealDamageDirect", onComplete, p, amount ) );
			function onComplete( p:Player, amount:int ):void 
			{
				p.lp -= amount;
			}
		}
		
		public function startChain_death( c:Card ):void 
		{
			prependProcess( gen( "declareDeath", declareDeath, c ) );
			function declareDeath( c:Card ):void 
			{
				prependProcess( gen( "performDeath", performDeath, c ) );
				if ( c.faceDown )
					startChain_MagicFlip( c );
			}
			function performDeath( c:Card ):void 
			{
				c.sprite.animDie();
				prependProcess( gen( "completeDeath", completeDeath, c ) );
			}
			function completeDeath( c:Card ):void 
			{
				enterGrave( c );
			}
		}
		
		// COMBAT FLIP & SAFE FLIP & MAGIC FLIP
		
		private function startChain_CombatFlip( c:Card ):void
		{
			prependProcess( gen( "performCombatFlip", performCombatFlip, c ) );
			function performCombatFlip( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				if ( c.behaviourC.hasCombatFlipEffect )
					startChain_CombatFlipEffect( c );
				else
					prependProcess( gen( "completeCombatFlip", null, c ) );
			}
			
			// EFFECT
			function startChain_CombatFlipEffect( c:Card ):void
			{
				prependProcess( gen( "declareCombatFlipEffect", declareCombatFlipEffect, c ) );
			}
			function declareCombatFlipEffect( c:Card ):void
			{
				c.sprite.animFlipEffect();
				prependProcess( gen( "performCombatFlipEffect", performCombatFlipEffect, c ) );
			}
			function performCombatFlipEffect( c:Card ):void
			{
				if ( !c.isInPlay )
				{
					appendProcess( gen( "abortCombatFlipEffect", null, c ) );
					return;
				}
				if ( c.behaviourC.onCombatFlipFunc != null )
					c.behaviourC.onCombatFlip();
				prependProcess( gen( "completeCombatFlipEffect", null, c ) );
			}
		}
		
		public function startChain_SafeFlip( c:Card ):void
		{
			prependProcess( gen( "performSafeFlip", performSafeFlip, c ) );
			function performSafeFlip( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				if ( c.behaviourC.hasSafeFlipEffect )
					startChain_SafeFlipEffect( c );
				else
					prependProcess( gen( "completeSafeFlip", null, c ) );
			}
			
			// EFFECT
			function startChain_SafeFlipEffect( c:Card ):void
			{
				prependProcess( gen( "declareSafeFlipEffect", declareSafeFlipEffect, c ) );
			}
			function declareSafeFlipEffect( c:Card ):void
			{
				c.sprite.animFlipEffect();
				prependProcess( gen( "performSafeFlipEffect", performSafeFlipEffect, c ) );
			}
			function performSafeFlipEffect( c:Card ):void
			{
				if ( c.behaviourC.onSafeFlipFunc != null )
					c.behaviourC.onSafeFlip();
				prependProcess( gen( "completeSafeFlipEffect", null, c ) );
			}
		}
		
		public function startChain_MagicFlip( c:Card ):void
		{
			prependProcess( gen( "performMagicFlip", performMagicFlip, c ) );
			function performMagicFlip( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				if ( c.behaviourC.hasMagicFlipEffect )
					startChain_MagicFlipEffect( c );
				else
					prependProcess( gen( "completeMagicFlip", null, c ) );
			}
			
			// EFFECT
			function startChain_MagicFlipEffect( c:Card ):void
			{
				prependProcess( gen( "declareMagicFlipEffect", declareMagicFlipEffect, c ) );
			}
			function declareMagicFlipEffect( c:Card ):void
			{
				c.sprite.animFlipEffect();
				prependProcess( gen( "performMagicFlipEffect", performMagicFlipEffect, c ) );
			}
			function performMagicFlipEffect( c:Card ):void
			{
				if ( c.behaviourC.hasMagicFlipEffect )
					c.behaviourC.onMagicFlip();
				prependProcess( gen( "completeMagicFlipEffect", null, c ) );
			}
		}
		
		// CHAINGING CARD CONTAINERS
		public function enterGrave( c:Card ):void 
		{
			prependProcess( gen( "enterGrave", onComplete, c ) );
			function onComplete( c:Card ):void 
			{
				if ( c.isInPlay )
				{
					c.exhausted = false;
					c.sprite.exhaustClock.alpha = 0.0;
				}
				//c.controller = c.owner;
				c.owner.grave.addCard( c );
				c.faceDown = false;
				prependProcess( gen( "enterGraveComplete", null, c ) );
			}
		}
		
		public function enterHand( c:Card, p:Player ):void 
		{
			var pro:Process;
			
			pro = gen( "enterHand", onComplete, c, p );
			pro.delay = NaN;
			prependProcess( pro );
			function onComplete( c:Card, p:Player ):void 
			{
				if ( c.isInPlay )
				{
					c.exhausted = false;
					c.sprite.exhaustClock.alpha = 0.0;
				}
				p.hand.addCard( c );
				c.faceDown = false;
				
				pro = gen( "enterHandComplete", null, c, p );
				pro.delay = NaN;
				prependProcess( pro );
			}
		}
		
		
		
		
		//
		protected function get game():Game { return Game.current }
	}

}