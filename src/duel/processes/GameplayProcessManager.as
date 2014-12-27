package duel.processes
{
	import duel.cards.behaviour.CreatureCardBehaviour;
	import duel.cards.Card;
	import duel.Game;
	import duel.Player;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameplayProcessManager extends ProcessManager
	{
		
		
		
		
		
		// ATTACKS
		
		public function startChain_Attack( attacker:Card ):void
		{
			attacker.faceDown = false;
			enqueueProcess( gen( "declareAttack", performAttack, attacker ) );
		}
		
		private function performAttack( attacker:Card ):void
		{
			if ( !attacker.canAttack )
			{
				return;
			}
			else
			{
				if ( attacker.field.opposingCreature == null )
				{
					dealCombatDamageDirect( attacker, attacker.controller.opponent );
				}
				else
				{
					if ( attacker.field.opposingCreature.faceDown )
					{
						attacker.field.opposingCreature.faceDown = false;
						attacker.field.opposingCreature.behaviourC.onCombatFlip();
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
				if ( attacker.behaviourC.attack <= attacker.behaviourC.attack )
					attackee.die();
			}
		}
		
		///
		protected function get game():Game { return Game.current }
	}

}