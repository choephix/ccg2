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
		// SUMMONS
		
		public function startChain_Summon( c:Card, field:CreatureField ):void
		{
			enqueueProcess( gen( "declareSummon", performSummon, c, field ) );
		}
		
		private function performSummon( c:Card, field:CreatureField ):void
		{
			enqueueProcess( gen( "performSummon", onComplete ) );
			
			function onComplete():void
			{
				if ( !game.canPlayHere( c, field ) )
				{
					enqueueProcess( gen( "abortSummon" ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				c.sprite.animSummon();
				
				//if ( c.type.isCreature )
					//c.exhausted = !c.behaviourC.haste;
				
				enqueueProcess( gen( "completeSummon" ) );
			}
		}
		
		
		// SET TRAPS
		
		public function startChain_TrapSet(c:Card, field:TrapField):void 
		{
			enqueueProcess( gen( "declareTrapSet", performTrapSet, c, field ) );
		}
		
		private function performTrapSet( c:Card, field:TrapField ):void
		{
			enqueueProcess( gen( "performTrapSet", onComplete ) );
			
			function onComplete():void
			{
				if ( !game.canPlayHere( c, field ) )
				{
					enqueueProcess( gen( "abortTrapSet" ) );
					return;
				}
				
				field.addCard( c );
				c.faceDown = c.behaviour.startFaceDown;
				
				//if ( c.type.isCreature )
					//c.exhausted = !c.behaviourC.haste;
				
				enqueueProcess( gen( "completeTrapSet" ) );
			}
		}
		
		// ATTACKS
		
		public function startChain_Attack( attacker:Card ):void
		{
			attacker.faceDown = false;
			enqueueProcess( gen( "declareAttack", performAttack, attacker ) );
		}
		
		private function performAttack( attacker:Card ):void
		{
			enqueueProcess( gen( "performAttack", onComplete ) );
			
			function onComplete():void
			{
				if ( !attacker.canAttack )
				{
					enqueueProcess( gen( "abortAttack" ) );
					return;
				}
				else
				if ( attacker.field.opposingCreature == null )
				{
					dealCombatDamageDirect( attacker, attacker.controller.opponent );
				}
				else
				{
					if ( attacker.field.opposingCreature.faceDown )
					{
						combatFlip( attacker.field.opposingCreature );
						performAttack( attacker );
						return;
					}
					
					dealCombatDamage( attacker, attacker.field.opposingCreature );
					dealCombatDamage( attacker.field.opposingCreature, attacker );
				}
				enqueueProcess( gen( "completeAttack" ) );
			}
		}
		
		private function dealCombatDamageDirect( attacker:Card, attackee:Player ):void
		{
			enqueueProcess( gen( "dealCombatDamageDirect", onComplete ) );
			
			function onComplete():void
			{
				attackee.takeDirectDamage( attacker.behaviourC.attack );
			}
		}
		
		private function dealCombatDamage( attacker:Card, attackee:Card ):void
		{
			enqueueProcess( gen( "dealCombatDamage", onComplete ) );
			
			function onComplete():void
			{
				if ( attackee.behaviourC.attack <= attacker.behaviourC.attack )
					attackee.die();
			}
		}
		
		private function combatFlip( c:Card ):void
		{
			c.faceDown = false;
			//c.behaviourC.onCombatFlip();
			interruptCurrentProcess( gen( "combatFlip", c.behaviourC.onCombatFlip ) );
		}
		
		
		
		//
		
		
		
		//
		protected function get game():Game { return Game.current }
	}

}