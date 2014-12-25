package duel {
	import duel.cards.CardList;
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
		
		public function Player() 
		{
			deck = new CardList();
			hand = new CardList();
			grave = new CardList();
		}
	}
}