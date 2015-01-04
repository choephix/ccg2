package duel.cards.status 
{
	import duel.cards.Card;
	import duel.cards.properties.CardProperties;
	import duel.GameEntity;
	import duel.processes.GameplayProcess;
	/**
	 * ...
	 * @author choephix
	 */
	public class CardStatus extends GameEntity
	{
		public var card:Card;
		public var props:CardProperties;
		
		public function onGameProcess( p:GameplayProcess ):void
		{}
		
		public function initialize():void
		{ props = card.props }
	}
}