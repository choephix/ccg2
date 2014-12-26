package duel {
	import adobe.utils.CustomActions;
	import duel.cards.Card;
	import duel.cards.CardList;
	import starling.events.Event;
	/**
	 * ...
	 * @author choephix
	 */
	public class Player 
	{
		public var name:String;
		public var lp:int;
		
		public var tableSide:TableSide;
		public var controllable:Boolean = true;
		
		public var deck:CardList;
		public var hand:CardList;
		public var grave:CardList;
		
		public var fieldsC:Vector.<CardList>;
		public var fieldsT:Vector.<CardList>;
		
		public function Player() 
		{
			deck = new CardList();
			hand = new CardList();
			grave = new CardList();
			
			fieldsC = new Vector.<CardList>();
			fieldsT = new Vector.<CardList>();
			while ( fieldsC.length < G.FIELD_COLUMNS ) fieldsC.push( new CardList() );
			while ( fieldsT.length < G.FIELD_COLUMNS ) fieldsT.push( new CardList() );
		}
		
		public function draw():void 
		{
			var c:Card = deck.at( deck.count - 1 );
			deck.remove( c );
			hand.add( c );
			c.faceDown = false;
			
			trace( name + " drew a card." );
		}
		
		public function discard( c:Card ):void 
		{
			grave.add( c );
			c.faceDown = true;
			
			trace( name + " put a card to the grave." );
		}
	}
}