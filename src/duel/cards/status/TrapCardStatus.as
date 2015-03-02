package duel.cards.status 
{
	import duel.cards.Card;
	import duel.cards.properties.TrapCardProperties;
	import duel.processes.GameplayProcess;
	import duel.processes.gameprocessing;
	
	use namespace gameprocessing;
	/**
	 * ...
	 * @author choephix
	 */
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
					processes.prepend_DestroyTrap( card );
					return;
				}
			}
			
			if ( p.isComplete )
				return;
			
			if ( propsT.effect.isBusy )
				return;
			
			// UPDATE PERSITENT EFFECT
			if ( propsT.effect.isActive && propsT.effect.watcherOngoing.doesProcessPassCheck( p ) )
			{
				propsT.effect.watcherOngoing.funcEffect( p );
			}
			
			// UPDATE PERSITENT EFFECT
			if ( propsT.effect.isActive && propsT.effect.watcherTriggered.doesProcessPassCheck( p ) )
			{
				p.interrupt();
				propsT.effect.watcherTriggered.funcEffect( p );
				return;
			}
			
			// ACTIVATION / DEACTIVATION
			if ( !propsT.effect.isActive && propsT.effect.watcherActivate( p ).doesProcessPassCheck )
			{
				p.interrupt();
				processes.prepend_TrapActivation( card );
				return;
			}
			
		}
	}
}