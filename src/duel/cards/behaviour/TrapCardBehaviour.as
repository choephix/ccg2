package duel.cards.behaviour 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class TrapCardBehaviour extends CardBehaviour 
	{
		
		public var onActivateFunc:Function;
		
		public function TrapCardBehaviour() 
		{
			startFaceDown = true;
		}
		
		public function activate():void
		{
			if ( onActivateFunc != null )
				onActivateFunc();
		}
		
	}

}