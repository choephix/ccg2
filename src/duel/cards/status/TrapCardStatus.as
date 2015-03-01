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
				return;
			
			// PERSISTENCE LINK
			if ( persistenceLink != null )
			{
				if ( !card.isInPlay )
				{
					persistenceLink = null;
					return;
				}
				
				if ( !persistenceLink.isInPlay )
				{
					persistenceLink = null;
					processes.prepend_DestroyTrap( card );
					return;
				}
			}
			
			// UPDATE PERSITENT EFFECT
			if ( propsT.isPersistent && propsT.effect.isActive )
			{
				propsT.effect.update( p );
			}
			
			if ( propsT.effect.isBusy )
				return;
			
			// ACTIVATION / DEACTIVATION
			if ( propsT.effect.mustInterrupt( p ) )
			{
				p.interrupt();
				if ( propsT.isPersistent && propsT.effect.isActive )
					processes.prepend_DestroyTrap( card );
				else
					processes.prepend_TrapActivation( card );
				return;
			}
			
		}
	}
}