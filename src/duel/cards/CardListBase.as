package duel.cards {
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
		
		public function findByName( name:String ):Card
		{
			for ( var i:int = 0; i < _count; i++ ) 
				if ( name == _list[ i ].name )
					return _list[ i ];
			return null;
		}
		
		//
		public function containsCard( card:Card ):Boolean
		{
			return _list.indexOf( card ) >= 0;
		}
		
		public function addCard( card:Card, toBottom:Boolean = false ):void
		{
			if ( card.lot != null ) 
				card.lot.removeCard( card );
			card.lot = this;
			
			_count++;
			
			if ( toBottom )
				_list.push( card );
			else
				_list.unshift( card );
			
			onCardAdded( card );
		}
		
		public function removeCard( card:Card ):void
		{
			card.lot = null;
			
			_count--;
			_list.splice( _list.indexOf( card ), 1 );
			
			onCardRemoved( card );
		}
		
		////
		public function indexOfCard( searchElement:Card, fromIndex:int = 0 ):int
		{
			return _list.indexOf( searchElement, fromIndex );
		}
		
		public function reverseCards():void
		{
			_list.reverse();
			onCardsReorder();
		}
		
		public function sortCards( compareFunction:Function ):void
		{
			_list.sort( compareFunction );
			onCardsReorder();
		}
		
		public function moveCardToTop(c:Card):void 
		{
			_list.splice( _list.indexOf( c ), 1 );
			_list.unshift( c );
			onCardsReorder();
		}
		
		public function moveCardToBottom(c:Card):void 
		{
			_list.splice( _list.indexOf( c ), 1 );
			_list.push( c );
			onCardsReorder();
		}
		
		//// GETTIES 'N SETTIES
		public function get cardsCount():int
		{
			return _count;
		}
		
		public function get isEmpty():Boolean
		{
			return _count == 0;
		}
		
		//// EVENTS
		protected function onCardAdded( c:Card ):void
		{ dispatchEventWith( Event.ADDED, false, c ) }
		
		protected function onCardRemoved( c:Card ):void
		{ dispatchEventWith( Event.REMOVED, false, c ) }
		
		protected function onCardsReorder():void
		{ dispatchEventWith( Event.CHANGE ) }
		
		// REST
		public function toString():String { return _list.join( "," ); }
	}
}