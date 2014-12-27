package duel.cards.behaviour 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapCardBehaviour extends CardBehaviour 
	{
		public var onActivateFunc:Function;
		
		public var persistent:Boolean = false;
		
		public function TrapCardBehaviour() 
		{
			startFaceDown = true;
		}
	}
}