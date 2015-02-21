package duel.cards {
	import duel.cards.Card;
	import duel.players.Player;
	import duel.table.CardLotType;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	[Event( name = "added", type = "starling.events.Event" )]
	[Event( name = "removed", type = "starling.events.Event" )]
	[Event( name = "change", type = "starling.events.Event" )]
	/**
	 * ...
	 * @author choephix
	 */
	public class CardListBase extends EventDispatcher
	{
		public var owner:Player;
		
		protected const _list:Vector.<Card> = new Vector.<Card>();
		protected var _count:int;
		protected var _type:CardLotType = CardLotType.UNKNOWN;
		
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
		
		// FIND
		
		/// Returns the first card found with the specified UID
		public function findByUid( uid:int ):Card
		{
			for ( var i:int = 0; i < _count; i++ ) 
				if ( uid == _list[ i ].uid )
					return _list[ i ];
			return null;
		}
		
		/// Returns the first card found with the specified slug. 
		public function findBySlug( slug:String, exact:Boolean = true ):Card
		{
			var i:int;
			if ( exact )
			{
				for ( i = 0; i < _count; i++ ) 
					if ( slug == _list[ i ].slug )
						return _list[ i ];
			}
			else
			{
				for ( i = 0; i < _count; i++ ) 
					if ( _list[ i ].slug.indexOf( slug ) == 0 )
						return _list[ i ];
			}
			return null;
		}
		
		public function findFirstCard( f:Function ):Card
		{
			for ( var i:int = 0; i < _count; i++ )
				if ( f( _list[ i ] ) )
					return _list[ i ];
			return null;
		}
		
		//
		public function containsCard( card:Card ):Boolean
		{
			return _list.indexOf( card ) >= 0;
		}
		
		public function addCard( card:Card, toBottom:Boolean = false ):Card
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
			
			return card;
		}
		
		public function removeCard( card:Card ):Card
		{
			card.lot = null;
			
			_count--;
			_list.splice( _list.indexOf( card ), 1 );
			
			onCardRemoved( card );
			
			return card;
		}
		
		////
		public function indexOfCard( searchElement:Card, fromIndex:int = 0 ):int
		{
			return _list.indexOf( searchElement, fromIndex );
		}
		
		public function forEachCard( f:Function ):void
		{
			for ( var i:int = 0; i < _count; i++ )
			{
				f( _list[ i ] );
			}
		}
		
		////
		
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
		
		public function shuffleCards():void
		{
			/* ** ** /// METHOD 1
			
			_list.sort( compareFunction );
			
			function compareFunction( a:Card, b:Card ):Number
			{
				return Math.random() < .5 ? -1 : 1;
			}
			
			/* ** **/// METHOD 2
			
			var _nu:Vector.<Card> = new Vector.<Card>();
			var i:int;
			while ( _list.length > 0 )
				_nu.push( _list.pop() );
			while ( _nu.length > 0 )
			{
				i = Math.random() * ( _nu.length - 1 );
				_list[ Math.random() * ( _list.length - 1 ) ] = _nu[ i ];
				_nu.splice( i, 1 );
			}
			
			/* ** **/
			
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
		{ return _count }
		
		public function get isEmpty():Boolean
		{ return _count == 0 }
		
		public function get type():CardLotType
		{ return _type }
		
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