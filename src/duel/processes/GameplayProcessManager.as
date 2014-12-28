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
		
		public function turnEnd( p:Player ):void
		{
			enqueueProcess( gen( "turnEnd", onComplete, p ) );
			function onComplete( p:Player ):void
			{
				game.dispatchEventWith( GameEvents.TURN_END );
				turnStart( p.opponent );
			}
		}
		
		public function turnStart( p:Player ):void
		{
			enqueueProcess( gen( "turnStart", onComplete, p ) );
			function onComplete():void
			{
				game.currentPlayer = p;
				game.dispatchEventWith( GameEvents.TURN_START );
				startChain_Draw( p, 1 );
			}
		}
		
		
		public function startChain_Draw( p:Player, count:int = 1 ):void
		{
			var pro:Process;
			while ( --count >= 0 )
			{
				pro = gen( "drawCard", onComplete, p );
				pro.time = .001;
				interruptCurrentProcess( pro )
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
				pro.time = .001;
				interruptCurrentProcess( pro )
			}
		}
		
		public function startChain_Discard( p:Player, c:Card ):void 
		{
			enqueueProcess( gen( "discardCard", onComplete, p, c ) );
			function onComplete():void
			{
				if ( !p.hand.containsCard( c ) )
				{
					enqueueProcess( gen( "abortDiscardCard", null, p, c ) );
					return;
				}
				p.hand.removeCard( c );
				enterGrave( c );
				enqueueProcess( gen( "completeDiscardCard", null, p, c ) );
			}
		}
		
		// SUMMON
		
		public function startChain_Summon( c:Card, field:CreatureField ):void
		{
			enqueueProcess( gen( "declareSummon", declareSummon, c, field ) );
			
			function declareSummon( c:Card, field:CreatureField ):void
			{
				enqueueProcess( gen( "performSummon", performSummon, c, field ) );
			}
			function performSummon( c:Card, field:CreatureField ):void
			{
				if ( !game.canPlaceCreatureHere( c, field ) )
				{
					enqueueProcess( gen( "abortSummon", null, c, field ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				c.sprite.animSummon();
				
				enqueueProcess( gen( "completeSummon", completeSummon, c, field ) );
			}
			function completeSummon( c:Card, field:CreatureField ):void
			{
				if ( c.isInPlay )
					c.exhausted ||= !c.behaviourC.haste;
			}
		}
		
		
		// SET TRAP
		
		public function startChain_TrapSet( c:Card, field:TrapField ):void 
		{
			enqueueProcess( gen( "declareTrapSet", stepDeclare, c, field ) );
			
			function stepDeclare( c:Card, field:TrapField ):void
			{
				enqueueProcess( gen( "performTrapSet", stepPerform, c, field ) );
			}
			function stepPerform( c:Card, field:TrapField ):void
			{
				if ( !game.canPlaceTrapHere( c, field ) )
				{
					enqueueProcess( gen( "abortTrapSet", null, c, field ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				enqueueProcess( gen( "completeTrapSet", null, c, field ) );
			}
		}
		
		
		public function startChain_TrapActivation( c:Card ):void
		{
			var currentProcess:Process = isIdle ? null : queue[ 0 ];
			
			interruptCurrentProcess( gen( "declareTrapActivation", stepDeclare, c ) );
			
			function stepDeclare( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				interruptCurrentProcess( gen( "performTrapActivation", stepPerform, c ) );
				
				trace ( c + " interrupted process " + currentProcess );
			}
			function stepPerform( c:Card ):void
			{
				if ( !c.canActivate )
				{
					interruptCurrentProcess( gen( "abortTrapActivation", discard, c ) );
					return;
				}
				
				c.sprite.animFlipEffect();
				c.behaviourT.onActivateFunc( currentProcess );
				
				interruptCurrentProcess( gen( "completeTrapActivation", discard, c ) );
			}
			function discard( c:Card ):void
			{
				if ( !c.behaviourT.persistent )
					enterGrave( c );
			}
		}
		
		
		// RELOCATION
		
		public function startChain_Relocation( c:Card, field:CreatureField ):void
		{
			if ( c.faceDown )
				enqueueProcess( gen( "flipUpForRelocation", flipUpForRelocation, c ) );
			else
				enqueueProcess( gen( "declareRelocation", declareRelocation, c, field ) );
			
			function flipUpForRelocation( c:Card ):void
			{
				startChain_SafeFlip( c );
				enqueueProcess( gen( "declareRelocation", declareRelocation, c, field ) );
			}
			
			function declareRelocation( c:Card, field:CreatureField ):void
			{
				if ( !c.canRelocate )
					return;
				
				c.sprite.animRelocation();
				
				enqueueProcess( gen( "performRelocation", performRelocation, c, field ) );
			}
			function performRelocation( c:Card, field:CreatureField ):void
			{
				if ( !c.canRelocate )
				{
					enqueueProcess( gen( "abortRelocation", completeOrAbortRelocation, c, field ) );
					return;
				}
				
				field.addCard( c );
				
				enqueueProcess( gen( "completeRelocation", completeOrAbortRelocation, c, field ) );
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
				enqueueProcess( gen( "flipUpForAttack", flipUpForAttack, c ) );
			else
				enqueueProcess( gen( "declareAttack", declareAttack, c ) );
			
			function flipUpForAttack( c:Card ):void
			{
				startChain_SafeFlip( c );
				enqueueProcess( gen( "declareAttack", declareAttack, c ) );
			}
				
			function declareAttack( c:Card ):void
			{
				if ( !c.canAttack )
				{
					enqueueProcess( gen( "abortAttack", null, c ) );
					return;
				}
				c.sprite.animAttackPrepare();
				enqueueProcess( gen( "performAttack", performAttack, c ) );
			}
			function performAttack( c:Card ):void
			{
				if ( !c.canAttack )
				{
					enqueueProcess( gen( "abortAttack", completeOrAbortAttack, c ) );
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
						enqueueProcess( gen( "performAttack", performAttack, c ) );
						return;
					}
					
					c.sprite.animAttackPerform();
					c.indexedField.opposingCreature.sprite.animAttackPerform();
					dealCombatDamage( c, c.indexedField.opposingCreature );
					dealCombatDamage( c.indexedField.opposingCreature, c );
				}
				enqueueProcess( gen( "completeAttack", completeOrAbortAttack, c ) );
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
			enqueueProcess( gen( "dealCombatDamage", onComplete, attacker, attackee ) );
			
			function onComplete( attacker:Card, attackee:Card ):void
			{
				if ( attackee.behaviourC.attack <= attacker.behaviourC.attack )
					startChain_death( attackee );
			}
		}
		
		private function dealCombatDamageDirect( attacker:Card, attackee:Player ):void
		{
			enqueueProcess( gen( "dealCombatDamageDirect", dealDamageDirect, attackee, attacker.behaviourC.attack ) );
		}
		
		private function dealEffectDamageDirect( p:Player, amount:int ):void 
		{
			interruptCurrentProcess( gen( "dealEffectDamageDirect", dealDamageDirect, p, amount ) );
		}
		
		private function dealDamageDirect( p:Player, amount:int ):void 
		{
			interruptCurrentProcess( gen( "dealDamageDirect", onComplete, p, amount ) );
			function onComplete( p:Player, amount:int ):void 
			{
				p.lp -= amount;
			}
		}
		
		public function startChain_death( c:Card ):void 
		{
			interruptCurrentProcess( gen( "declareDeath", declareDeath, c ) );
			function declareDeath( c:Card ):void 
			{
				interruptCurrentProcess( gen( "performDeath", performDeath, c ) );
				if ( c.faceDown )
					startChain_MagicFlip( c );
			}
			function performDeath( c:Card ):void 
			{
				c.sprite.animDie();
				interruptCurrentProcess( gen( "completeDeath", null, c ) );
			}
			function completeDeath( c:Card ):void 
			{
				enterGrave( c );
			}
		}
		
		// COMBAT FLIP & SAFE FLIP & MAGIC FLIP
		
		private function startChain_CombatFlip( c:Card ):void
		{
			interruptCurrentProcess( gen( "performCombatFlip", performCombatFlip, c ) );
			function performCombatFlip( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				if ( c.behaviourC.hasCombatFlipEffect )
					startChain_CombatFlipEffect( c );
				else
					interruptCurrentProcess( gen( "completeCombatFlip", null, c ) );
			}
			
			// EFFECT
			function startChain_CombatFlipEffect( c:Card ):void
			{
				interruptCurrentProcess( gen( "declareCombatFlipEffect", declareCombatFlipEffect, c ) );
			}
			function declareCombatFlipEffect( c:Card ):void
			{
				c.sprite.animFlipEffect();
				interruptCurrentProcess( gen( "performCombatFlipEffect", performCombatFlipEffect, c ) );
			}
			function performCombatFlipEffect( c:Card ):void
			{
				if ( c.behaviourC.onCombatFlipFunc != null )
					c.behaviourC.onCombatFlip();
				interruptCurrentProcess( gen( "completeCombatFlipEffect", null, c ) );
			}
		}
		
		public function startChain_SafeFlip( c:Card ):void
		{
			interruptCurrentProcess( gen( "performSafeFlip", performSafeFlip, c ) );
			function performSafeFlip( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				if ( c.behaviourC.hasSafeFlipEffect )
					startChain_SafeFlipEffect( c );
				else
					interruptCurrentProcess( gen( "completeSafeFlip", null, c ) );
			}
			
			// EFFECT
			function startChain_SafeFlipEffect( c:Card ):void
			{
				interruptCurrentProcess( gen( "declareSafeFlipEffect", declareSafeFlipEffect, c ) );
			}
			function declareSafeFlipEffect( c:Card ):void
			{
				c.sprite.animFlipEffect();
				interruptCurrentProcess( gen( "performSafeFlipEffect", performSafeFlipEffect, c ) );
			}
			function performSafeFlipEffect( c:Card ):void
			{
				if ( c.behaviourC.onSafeFlipFunc != null )
					c.behaviourC.onSafeFlip();
				interruptCurrentProcess( gen( "completeSafeFlipEffect", null, c ) );
			}
		}
		
		public function startChain_MagicFlip( c:Card ):void
		{
			interruptCurrentProcess( gen( "performMagicFlip", performMagicFlip, c ) );
			function performMagicFlip( c:Card ):void
			{
				c.faceDown = false;
				c.sprite.animSpecialFlip();
				if ( c.behaviourC.hasMagicFlipEffect )
					startChain_MagicFlipEffect( c );
				else
					interruptCurrentProcess( gen( "completeMagicFlip", null, c ) );
			}
			
			// EFFECT
			function startChain_MagicFlipEffect( c:Card ):void
			{
				interruptCurrentProcess( gen( "declareMagicFlipEffect", declareMagicFlipEffect, c ) );
			}
			function declareMagicFlipEffect( c:Card ):void
			{
				c.sprite.animFlipEffect();
				interruptCurrentProcess( gen( "performMagicFlipEffect", performMagicFlipEffect, c ) );
			}
			function performMagicFlipEffect( c:Card ):void
			{
				if ( c.behaviourC.hasMagicFlipEffect )
					c.behaviourC.onMagicFlip();
				interruptCurrentProcess( gen( "completeMagicFlipEffect", null, c ) );
			}
		}
		
		// CHAINGING CARD CONTAINERS
		public function enterGrave( c:Card ):void 
		{
			interruptCurrentProcess( gen( "enterGrave", onComplete, c ) );
			function onComplete( c:Card ):void 
			{
				if ( c.isInPlay )
				{
					c.exhausted = false;
					c.sprite.exhaustClock.alpha = 0.0;
				}
				c.owner.grave.addCard( c );
				c.faceDown = false;
				interruptCurrentProcess( gen( "enterGraveComplete", null, c ) );
			}
		}
		
		public function enterHand( c:Card, p:Player ):void 
		{
			interruptCurrentProcess( gen( "enterHand", onComplete, c, p ) );
			function onComplete( c:Card, p:Player ):void 
			{
				if ( c.isInPlay )
				{
					c.exhausted = false;
					c.sprite.exhaustClock.alpha = 0.0;
				}
				c.owner.hand.addCard( c );
				c.faceDown = false;
				interruptCurrentProcess( gen( "enterHandComplete", null, c, p ) );
			}
		}
		
		
		
		
		//
		protected function get game():Game { return Game.current }
	}

}