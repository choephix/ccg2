package duel.cardlots
{
	import duel.cards.Card;
	import duel.Player;
	import flash.display3D.textures.VideoTexture;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class CardListBase extends EventDispatcher
	{
		public var owner:Player;
		
		private const _list:Vector.<Card> = new Vector.<Card>();
		private var _count:int;
		
		// GETTERS
		public function getCardAt( index:int ):Card
		{
			return _list[ index ];
		}
		
		public function getFirstCard():Card
		{
			return _list[ 0 ];
		}
		
		public function getLastCard():Card
		{
			return _list[ _count - 1 ];
		}
		
		//
		public function containsCard( card:Card ):Boolean
		{
			return _list.indexOf( card ) >= 0;
		}
		
		public function addCard( card:Card ):void
		{
			if ( card.lot != null ) 
				card.lot.removeCard( card );
			card.lot = this;
			
			_count++;
			_list.unshift( card );
			
			onCardAdded( card );
			onCardsChange();
		}
		
		public function removeCard( card:Card ):void
		{
			card.lot = null;
			
			_count--;
			_list.splice( _list.indexOf( card ), 1 );
			
			onCardRemoved( card );
			onCardsChange();
		}
		
		////
		public function get cardsCount():int
		{
			return _count;
		}
		
		////
		public function indexOfCard( searchElement:Card, fromIndex:int = 0 ):int
		{
			return _list.indexOf( searchElement, fromIndex );
		}
		
		public function sortCards( compareFunction:Function ):Vector.<Card>
		{
			return _list.sort( compareFunction );
			onCardsChange();
		}
		
		//// EVENTS
		protected function onCardAdded( c:Card ):void	{ dispatchEventWith( Event.ADDED, false, c ) }
		protected function onCardRemoved( c:Card ):void	{ dispatchEventWith( Event.REMOVED, false, c ) }
		protected function onCardsChange():void 		{ dispatchEventWith( Event.CHANGE ) }
		
		// REST
		public function toString():String { return _list.join( "," ); }
	}
}