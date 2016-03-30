package duel 
{
	import data.decks.DeckBean;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameMeta 
	{
		public var isMultiplayer:Boolean = false; // true false
		public var roomName:String;
		
		public var myUserName:String;
		public var myUserColor:uint;
		
		public var deck1:DeckBean;
		public var deck2:DeckBean;
	}
}