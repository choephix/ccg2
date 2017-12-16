package duel.cards {
	import duel.cards.Card;
	import duel.players.Player;
	import duel.table.CardLotType;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	[Event( name = "added", type = "starling.events.Event" )]
	[Event( name = "removed", type = "starling.events.Event" )]
	[Event( name = "change", type = "starling.events.Event" )]
	
	public class CardListBase extends EventDispatcher
	{
		public var owner:Player;
		
		protected const mCards:Vector.<Card> = new Vector.<Card>();
		protected var mCount:int;
		protected var _type:CardLotType = CardLotType.UNKNOWN;
		
		// GETTERS
		public function getCardAt( index:int ):Card
		{
			return mCards[ index ];
		}
		
		public function getFirstCard():Card
		{
			return mCards[ 0 ];
		}
		
		public function getLastCard():Card
		{
			return mCards[ mCount - 1 ];
		}
		
		// FIND
		
		/// Returns the first card found with the specified UID
		public function findByUid( uid:int ):Card
		{
			for ( var i:int = 0; i < mCount; i++ ) 
				if ( uid == mCards[ i ].uid )
					return mCards[ i ];
			return null;
		}
		
		/// Returns the first card found with the specified slug. 
		public function findBySlug( slug:String, exact:Boolean = true ):Card
		{
			var i:int;
			if ( exact )
			{
				for ( i = 0; i < mCount; i++ ) 
					if ( slug == mCards[ i ].slug )
						return mCards[ i ];
			}
			else
			{
				for ( i = 0; i < mCount; i++ ) 
					if ( mCards[ i ].slug.indexOf( slug ) == 0 )
						return mCards[ i ];
			}
			return null;
		}
		
		public function findFirstCard( f:Function ):Card
		{
			for ( var i:int = 0; i < mCount; i++ )
				if ( f( mCards[ i ] ) )
					return mCards[ i ];
			return null;
		}
		
		////
		public function indexOfCard( searchElement:Card, fromIndex:int = 0 ):int
		{
			return mCards.indexOf( searchElement, fromIndex );
		}
		
		public function forEachCard( f:Function ):void
		{
			for ( var i:int = 0; i < mCount; i++ )
			{
				f( mCards[ i ] );
			}
		}
		
		/// f must accept 1 arg of type Card and return Boolean
		public function countCardsThat( f:Function ):int
		{
			var r:int = 0;
			for ( var i:int = 0; i < mCount; i++ )
				if ( f( mCards[ i ] ) )
					r++;
			return r;
		}
		
		public function containsCard( card:Card ):Boolean
		{
			return mCards.indexOf( card ) >= 0;
		}
		
		////
		
		public function addCard( card:Card, toBottom:Boolean = false ):Card
		{
			if ( card.lot != null ) 
				card.lot.removeCard( card );
			card.lot = this;
			
			mCount++;
			
			if ( toBottom )
				mCards.push( card );
			else
				mCards.unshift( card );
			
			onCardAdded( card );
			
			return card;
		}
		
		public function removeCard( card:Card ):Card
		{
			card.lot = null;
			
			mCount--;
			mCards.splice( mCards.indexOf( card ), 1 );
			
			onCardRemoved( card );
			
			return card;
		}
		
		//
		
		public function reverseCards():void
		{
			mCards.reverse();
			onCardsReorder();
		}
		
		public function sortCards( compareFunction:Function ):void
		{
			mCards.sort( compareFunction );
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
			while ( mCards.length > 0 )
				_nu.push( mCards.pop() );
			while ( _nu.length > 0 )
			{
				i = Math.random() * ( _nu.length - 1 );
				mCards[ Math.random() * ( mCards.length - 1 ) ] = _nu[ i ];
				_nu.splice( i, 1 );
			}
			
			/* ** **/
			
			onCardsReorder();
		}
		
		public function moveCardToTop(c:Card):void 
		{
			mCards.splice( mCards.indexOf( c ), 1 );
			mCards.unshift( c );
			onCardsReorder();
		}
		
		public function moveCardToBottom(c:Card):void 
		{
			mCards.splice( mCards.indexOf( c ), 1 );
			mCards.push( c );
			onCardsReorder();
		}
		
		//// GETTIES 'N SETTIES
		public function get cardsCount():int
		{ return mCount }
		
		public function get isEmpty():Boolean
		{ return mCount == 0 }
		
		public function get type():CardLotType
		{ return _type }
		
		//// EVENTS
		protected function onCardAdded( c:Card ):void
		{  dispatchEventWith( Event.ADDED, false, c ) }
		
		protected function onCardRemoved( c:Card ):void
		{ dispatchEventWith( Event.REMOVED, false, c ) }
		
		protected function onCardsReorder():void
		{ dispatchEventWith( Event.CHANGE ) }
		
		// REST
		public function toString():String { return mCards.join( "," ); }
	}
}