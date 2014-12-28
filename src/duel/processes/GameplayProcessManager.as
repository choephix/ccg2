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
				startChain_Draw( p.opponent, 1 );
			}
		}
		
		
		public function startChain_Draw( p:Player, count:int = 1 ):void
		{
			var pro:Process;
			while ( --count >= 0 )
			{
				pro = gen( "drawCard", onComplete, p );
				pro.time = .033;
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
				p.putInHand( c );
			}
		}
		
		// SUMMON
		
		public function startChain_Summon( c:Card, field:CreatureField ):void
		{
			enqueueProcess( gen( "declareSummon", performSummon, c, field ) );
		}
		
		private function performSummon( c:Card, field:CreatureField ):void
		{
			enqueueProcess( gen( "performSummon", onComplete, c, field ) );
			
			function onComplete( c:Card, field:CreatureField ):void
			{
				if ( !game.canPlaceCreatureHere( c, field ) )
				{
					enqueueProcess( gen( "abortSummon", null, c, field ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				c.sprite.animSummon();
				
				//if ( c.type.isCreature )
					//c.exhausted = !c.behaviourC.haste;
				
				enqueueProcess( gen( "completeSummon", null, c, field ) );
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
				c.specialFlipUp();
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
			enqueueProcess( gen( "declareRelocation", performRelocation, c, field ) );
		}
		
		private function performRelocation( c:Card, field:CreatureField ):void
		{
			enqueueProcess( gen( "performRelocation", onComplete, c, field ) );
			
			c.specialFlipUp();
			
			function onComplete( c:Card, field:CreatureField ):void
			{
				if ( !c.canRelocate )
				{
					enqueueProcess( gen( "abortRelocation", null, c, field ) );
					return;
				}
				
				field.addCard( c );
				
				c.sprite.animSummon();
				
				enqueueProcess( gen( "completeRelocation", null, c, field ) );
			}
		}
		
		// ATTACK
		
		public function startChain_Attack( c:Card ):void
		{
			if ( c.faceDown )
				enqueueProcess( gen( "flipUpForAttack", declareAttack, c ) );
			else
				enqueueProcess( gen( "declareAttack", declareAttack, c ) );
			
			function flipUpForAttack( c:Card ):void
			{
				c.specialFlipUp();
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
					enqueueProcess( gen( "abortAttack", null, c ) );
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
						combatFlip( c.indexedField.opposingCreature );
						enqueueProcess( gen( "performAttack", performAttack, c ) );
						return;
					}
					
					c.sprite.animAttackPerform();
					c.indexedField.opposingCreature.sprite.animAttackPerform();
					dealCombatDamage( c, c.indexedField.opposingCreature );
					dealCombatDamage( c.indexedField.opposingCreature, c );
				}
				enqueueProcess( gen( "completeAttack", null, c ) );
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
				c.sprite.animDie();
				interruptCurrentProcess( gen( "performDeath", performDeath, c ) );
			}
			function performDeath( c:Card ):void 
			{
				interruptCurrentProcess( gen( "completeDeath", null, c ) );
				enterGrave( c );
			}
		}
		
		// COMBAT FLIP
		
		private function combatFlip( c:Card ):void
		{
			c.specialFlipUp();
			interruptCurrentProcess( gen( "combatFlip", combatFlipEffect, c ) );
			
			function combatFlipEffect( c:Card ):void
			{
				if ( c.behaviourC.onCombatFlipFunc != null )
				{
					c.sprite.animFlipEffect();
					interruptCurrentProcess( gen( "combatFlipEffect", complete, c ) );
				}
			}
			function complete( c:Card ):void
			{
				if ( c.behaviourC.onCombatFlipFunc != null )
					c.behaviourC.onCombatFlip();
			}
		}
		
		// CHAINGING CARD CONTAINERS
		private function enterGrave( c:Card ):void 
		{
			interruptCurrentProcess( gen( "enterGrave", onComplete, c ) );
			function onComplete( c:Card ):void 
			{
				c.exhausted = false;
				c.owner.putToGrave( c );
				interruptCurrentProcess( gen( "enterGraveComplete", null, c ) );
			}
		}
		
		
		
		
		//
		protected function get game():Game { return Game.current }
	}

}