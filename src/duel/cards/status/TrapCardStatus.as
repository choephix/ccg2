package duel.cards.status 
{
	import duel.cards.Card;
	import duel.cards.properties.TrapCardProperties;
	import duel.processes.GameplayProcess;
	import duel.processes.gameprocessing;
	
	use namespace gameprocessing;
	
	public class TrapCardStatus extends CardStatus 
	{
		public var persistenceLink:Card = null;
		
		public function get propsT():TrapCardProperties
		{ return props as TrapCardProperties }
		
		override public function initialize():void
		{ super.initialize() }
		
		override public function onGameProcess( p:GameplayProcess ):void
		{
			if ( !card.isInPlay )
			{
				persistenceLink = null;
				return;
			}
			
			// PERSISTENCE LINK
			if ( persistenceLink != null )
			{
				if ( !persistenceLink.isInPlay )
				{
					persistenceLink = null;
					processes.prepend_DestroyTrap( card, null );
					return;
				}
			}
			
			if ( p.isComplete )
				return;
			
			if ( propsT.effect.isBusy )
				return;
			
			if ( propsT.isPersistent && propsT.effect.isActive )
			{
				// ONGOING EFFECT
				if ( propsT.effect.watcherOngoing.doesProcessPassCheck( p ) )
				{
					propsT.effect.watcherOngoing.funcEffect( p );
				}
				// TRIGGERED EFFECT
				if ( propsT.effect.watcherTriggered.doesProcessPassCheck( p ) )
				{
					p.interrupt();
					propsT.effect.watcherTriggered.lastInterruptedProcess = p;
					propsT.effect.watcherTriggered.funcEffect( p );
					card.sprite.animTrapEffect();
					return;
				}
				// DEACTIVATION
				if ( propsT.effect.watcherDeactivate.doesProcessPassCheck( p ) )
				{
					p.interrupt();
					propsT.effect.watcherDeactivate.lastInterruptedProcess = p;
					processes.prepend_DestroyTrap( card, null );
					return;
				}
			}
			else
			if ( !propsT.effect.isActive )
			{
				// ACTIVATION
				if ( propsT.effect.watcherActivate.doesProcessPassCheck( p ) )
				{
					p.interrupt();
					propsT.effect.watcherActivate.lastInterruptedProcess = p;
					processes.prepend_TrapActivation( card );
					return;
				}
			}
		}
	}
}