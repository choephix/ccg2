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
		
		public var hand:CardList;
		public var deck:CardList;
		
		public function Player() 
		{
			hand = new CardList();
			deck = new CardList();
		}
		
	}

}