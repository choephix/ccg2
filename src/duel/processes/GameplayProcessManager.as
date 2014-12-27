package duel.processes
{
	import duel.cards.Card;
	import duel.Game;
	import duel.Player;
	import duel.table.CreatureField;
	import duel.table.TrapField;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameplayProcessManager extends ProcessManager
	{
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
			enqueueProcess( gen( "declareTrapSet", performTrapSet, c, field ) );
		}
		
		private function performTrapSet( c:Card, field:TrapField ):void
		{
			enqueueProcess( gen( "performTrapSet", onComplete, c, field ) );
			
			function onComplete( c:Card, field:TrapField ):void
			{
				if ( !game.canPlaceTrapHere( c, field ) )
				{
					enqueueProcess( gen( "abortTrapSet", null, c, field ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				//if ( c.type.isCreature )
					//c.exhausted = !c.behaviourC.haste;
				
				enqueueProcess( gen( "completeTrapSet", null, c, field ) );
			}
		}
		
		
		
		public function performTrapActivation( c:Card ):void
		{
			enqueueProcess( gen( "performTrapActivation", onComplete, c ) );
			
			function onComplete( c:Card ):void
			{
				if ( !c.canActivate )
				{
					enqueueProcess( gen( "abortTrapActivation", discard, c ) );
					return;
				}
				
				c.behaviourT.onActivateFunc();
				
				enqueueProcess( gen( "completeTrapActivation", discard, c ) );
			}
			
			function discard( c:Card ):void
			{
				if ( !c.behaviourT.persistent )
					c.die();
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
			
			function onComplete( c:Card, field:CreatureField ):void
			{
				if ( !c.canRelocate )
				{
					enqueueProcess( gen( "abortRelocation", null, c, field ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = false;
				
				c.sprite.animSummon();
				
				enqueueProcess( gen( "completeRelocation", null, c, field ) );
			}
		}
		
		// ATTACK
		
		public function startChain_Attack( c:Card ):void
		{
			c.faceDown = false;
			enqueueProcess( gen( "declareAttack", onComplete, c ) );
			
			function onComplete( c:Card ):void
			{
				c.sprite.animAttackPrepare();
				performAttack( c );
			}
		}
		
		private function performAttack( c:Card ):void
		{
			enqueueProcess( gen( "performAttack", onComplete, c ) );
			
			function onComplete( c:Card ):void
			{
				if ( !c.canAttack )
				{
					enqueueProcess( gen( "abortAttack", null, c ) );
					c.sprite.animAttackAbort();
					return;
				}
				
				if ( c.field.opposingCreature == null )
				{
					c.sprite.animAttackPerform();
					dealCombatDamageDirect( c, c.controller.opponent );
				}
				else
				{
					if ( c.field.opposingCreature.faceDown )
					{
						combatFlip( c.field.opposingCreature );
						performAttack( c );
						return;
					}
					
					c.sprite.animAttackPerform();
					c.field.opposingCreature.sprite.animAttackPerform();
					dealCombatDamage( c, c.field.opposingCreature );
					dealCombatDamage( c.field.opposingCreature, c );
				}
				enqueueProcess( gen( "completeAttack", null, c ) );
			}
		}
		
		private function dealCombatDamageDirect( attacker:Card, attackee:Player ):void
		{
			enqueueProcess( gen( "dealCombatDamageDirect", onComplete, attacker, attackee ) );
			
			function onComplete( attacker:Card, attackee:Player ):void
			{
				attackee.takeDirectDamage( attacker.behaviourC.attack );
			}
		}
		
		private function dealCombatDamage( attacker:Card, attackee:Card ):void
		{
			enqueueProcess( gen( "dealCombatDamage", onComplete, attacker, attackee ) );
			
			function onComplete( attacker:Card, attackee:Card ):void
			{
				if ( attackee.behaviourC.attack <= attacker.behaviourC.attack )
					attackee.die();
			}
		}
		
		private function combatFlip( c:Card ):void
		{
			c.faceDown = false;
			interruptCurrentProcess( gen( "combatFlip", combatFlipEffect, c ) );
			
			function combatFlipEffect( c:Card ):void
			{
				if ( c.behaviourC.onCombatFlipFunc != null )
				{
					c.sprite.animFlipEffect();
					interruptCurrentProcess( gen( "combatFlipEffect", c.behaviourC.onCombatFlip, c ) );
				}
			}
		}
		
		
		
		//
		
		
		
		//
		protected function get game():Game { return Game.current }
	}

}