package duel 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class GameState 
	{
		public static const WAITING:GameState	= new GameState();
		public static const ONGOING:GameState	= new GameState();
		public static const OVER:GameState		= new GameState();
		
		public function get isWaiting():Boolean		{ return this == WAITING }
		public function get isOngooing():Boolean	{ return this == ONGOING }
		public function get isOver():Boolean		{ return this == OVER }
	}

}